from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user import User, UserDetails
from app.schemas.userSchema import UserCreate, UserUpdate, LoginSchema, UserDetailsResponse
from app.helpers.format_helper import format_api_response
from app.helpers.security import hashPassword, verifyPassword, createAccessToken, revokeToken
from datetime import datetime, timezone, timedelta
from fastapi.security import OAuth2PasswordRequestForm

def getAllUsers(db: Session, skip: int = 0, limit: int = 100):
    users = db.query(User).filter(User.userStatus == 1).offset(skip).limit(limit).all()
    return users

def getUserByID(userID: int, db: Session):
    userByID = db.query(User).filter(User.userID == userID).first()
    if not userByID:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {userID} not found",
        )
    return userByID

def createUser(userData: UserCreate, db: Session):
    # Check for existing user
    existingUser = db.query(User).filter(User.userUsername == userData.userUsername).first()
    
    if existingUser:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"An account with username/email '{userData.userUsername}' already exists."
        )
    
    # Hashed password
    hashedPwd = hashPassword(userData.userPassword)
    
    # Create new user
    newUser = User(
        userUsername = userData.userUsername,
        userPassword = hashedPwd,
        userStatus = userData.userStatus or 1
    )
    
    db.add(newUser)
    db.flush()
    
    # Create user details
    newUserDetails = UserDetails(
        userDetailsUserID = newUser.userID,
        userDetailsLevel = 0,
        userDetailsXP = 0,
        userDetailsStreakCount = 0
    )
    
    db.add(newUserDetails)
    db.commit()
    db.refresh(newUser)
    return newUser

def updateUser(userID: int, userData: UserUpdate, db: Session):
    userByID = getUserByID(userID, db)
    updateUserData = userData.model_dump(exclude_unset=True) 
    
    # If update username, check existing
    if "userUsername" in updateUserData and updateUserData["userUsername"] != userByID.userUsername:
        existing = db.query(User).filter(User.userUsername == updateUserData["userUsername"]).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Username/email '{updateUserData['userUsername']}' is already in use."
            )
    
    # Hash password if password update
    if "userPassword" in updateUserData and updateUserData["userPassword"]:
        updateUserData["userPassword"] = hashPassword(updateUserData["userPassword"])
        
    for key, value in updateUserData.items():
        setattr(userByID, key, value)
        
    db.commit()
    db.refresh(userByID)
    return userByID

def deleteUser(userID: int, db: Session):
    userByID = getUserByID(userID, db)
    userByID.userStatus = 2
    
    db.commit()
    db.refresh(userByID)
    return format_api_response(
        True,
        f"User {userID} disabled successfully",
        userByID
    )
    
def verifyUserCredentials(username: str, plain_password: str, db: Session):
    user = db.query(User).filter(User.userUsername == username).first()
    if not user or not verifyPassword(plain_password, user.userPassword):
        return False
    return user

# Calculation for user XP and Level
def calculateLevelFromTotalXP(totalXP: int) -> int:
    return (totalXP // 500) + 1

def addUserXP(userID: int, xpGained: int, db: Session):
    details = db.query(UserDetails).filter(UserDetails.userDetailsUserID == userID).first()
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User details for user ID {userID} not found"
        )
        
    old_level = int(details.userDetailsLevel or 1)
    details.userDetailsXP = int(details.userDetailsXP or 0) + xpGained
    new_level = calculateLevelFromTotalXP(details.userDetailsXP)
    
    leveledUp = new_level > old_level
    details.userDetailsLevel = new_level
    
    db.commit()
    db.refresh(details)
    
    return {
        "status": "success",
        "message": "XP updated successfully",
        "levelUp": leveledUp,
        "details": UserDetailsResponse.model_validate(details)
    }
    
def updateUserStreak(userID: int, streakCount: int, db: Session):
    details = db.query(UserDetails).filter(UserDetails.userDetailsUserID == userID).first()
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User details for user ID {userID} not found"
        )
        
    details.userDetailsStreakCount = streakCount
    db.commit()
    db.refresh(details)
    return details

# Update streak automatically

MYT = timezone(timedelta(hours=8))
def getMyyTime():
    return datetime.now(MYT)

def logDailyActivity(userID: int, db: Session):
    details = db.query(UserDetails).filter(UserDetails.userDetailsUserID == userID).first()
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User details for user ID {userID} not found"
        )

    now = getMyyTime()
    todayDate = now.date()
    
    if details.userDetailsLastActivity is None:
        details.userDetailsStreakCount = 1
        statusFlag = "incremented"
        message = "Streak started!"
        
    else:
        lastDate = details.userDetailsLastActivity.date()
        daysDiff = (todayDate - lastDate).days
        
        if daysDiff == 0:
            return {
                "message": "Activity already logged today. Streak remains unchanged.",
                "streak_count": details.streakCount,
                "status": "already_logged"
            }
        elif daysDiff == 1:
            details.userDetailsStreakCount += 1
            statusFlag = "incremented"
            message = "Streak maintained and incremented!"
            
        else:
            details.userDetailsStreakCount = 1
            statusFlag = "reset_and_incremented"
            message = "Streak reset due to missed days"
            
    details.userDetailsLastActivity = now
    db.commit()
    db.refresh(details)
    
    return {
        "message": message,
        "streak_count": details.userDetailsStreakCount,
        "status": statusFlag
    }
    
# Login & Logout
def loginUser(credential: LoginSchema, db: Session):
    user = db.query(User).filter(User.userUsername == credential.username).first()
    
    # Verify user exists and password is valid
    if not user or not verifyPassword(credential.password, user.userPassword):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    # Check if account is disabled (userStatus = 2)
    if user.userStatus != 1:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )
        
    tokenData = {"sub": str(user.userID), "username": user.userUsername}
    accessToken = createAccessToken(data = tokenData)
    
    return {
        "status": "success",
        "message": "Login successfully",
        "access_token": accessToken,
        "token_type": "bearer"
    }
    
def logoutUser(token: str):
    revokeToken(token)
    return {
        "status": "success",
        "message": "Logged out successfully"
    }
    
def getCurrentUser(payload: dict, db: Session):
    userID = int(payload.get("sub"))
    user = db.query(User).filter(User.userID == userID).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user