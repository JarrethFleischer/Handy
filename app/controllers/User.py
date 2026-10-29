from sqlalchemy import desc
from sqlalchemy.orm import Session
import random
from fastapi import HTTPException, status
from app.models.user import User, UserDetails
from app.schemas.userSchema import UserCreate, UserUpdate, LoginSchema, UserDetailsResponse, VerifyOTPAndResetPassword
from app.helpers.format_helper import format_api_response
from app.helpers.security import hashPassword, verifyPassword, createAccessToken, revokeToken
from datetime import datetime, timezone, timedelta
from fastapi.security import OAuth2PasswordRequestForm
from app.models.bridge import bridge
from fastapi_mail import FastMail, MessageSchema, MessageType
from app.config.email import mail_config

MYT = timezone(timedelta(hours=8))

def getMyyTime():
    return datetime.now(MYT)

def getAllUsers(db: Session, skip: int = 0, limit: int = 100):
    return db.query(User).filter(User.userStatus == 1).offset(skip).limit(limit).all()

def getUserByID(userID: int, db: Session):
    userByID = db.query(User).filter(User.userID == userID).first()
    if not userByID:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {userID} not found",
        )
    return userByID

def createUser(userData: UserCreate, db: Session):
    existingUser = db.query(User).filter(User.userUsername == userData.userUsername).first()
    if existingUser:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"An account with username/email '{userData.userUsername}' already exists."
        )
    
    hashedPwd = hashPassword(userData.userPassword)
    newUser = User(
        userName=userData.userName,
        userUsername=userData.userUsername,
        userPassword=hashedPwd,
        userStatus=userData.userStatus or 1
    )
    db.add(newUser)
    db.flush()
    
    newUserDetails = UserDetails(
        userDetailsUserID=newUser.userID,
        userDetailsLevel=1,
        userDetailsXP=0,
        userDetailsStreakCount=0
    )
    db.add(newUserDetails)
    
    initialBridge = bridge(
        bridgeUserID=newUser.userID,
        bridgeChapterID=1,
        bridgeProgress="0"
    )
    db.add(initialBridge)
    
    db.commit()
    db.refresh(newUser)
    return newUser

def updateUser(userID: int, userData: UserUpdate, db: Session):
    userByID = getUserByID(userID, db)
    updateUserData = userData.model_dump(exclude_unset=True) 
    
    if "userUsername" in updateUserData and updateUserData["userUsername"] != userByID.userUsername:
        existing = db.query(User).filter(User.userUsername == updateUserData["userUsername"]).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Username/email '{updateUserData['userUsername']}' is already in use."
            )
    
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
    
    currentChapter = new_level
    progressWithinChapter = str(details.userDetailsXP % 500)
    
    existingBridge = db.query(bridge).filter(
        bridge.bridgeUserID == userID,
        bridge.bridgeChapterID == currentChapter
    ).first()
    
    if existingBridge:
        existingBridge.bridgeProgress = progressWithinChapter
        existingBridge.bridgeDateUpdated = getMyyTime()  # Fixed typo and tuple
    else:
        newBridge = bridge(
            bridgeUserID=userID,
            bridgeChapterID=currentChapter,
            bridgeProgress=progressWithinChapter,
            bridgeDateCreated=getMyyTime(),
            bridgeDateUpdated=getMyyTime()
        )
        db.add(newBridge)
    
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
                "streak_count": details.userDetailsStreakCount,  # Fixed bug: was details.streakCount
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

def loginUser(credential: LoginSchema, db: Session):
    user = db.query(User).filter(User.userUsername == credential.username).first()
    
    if not user or not verifyPassword(credential.password, user.userPassword):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    if user.userStatus != 1:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )
        
    tokenData = {"sub": str(user.userID), "username": user.userUsername}
    accessToken = createAccessToken(data=tokenData)
    
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

# Email OTP Store
otpStore = {}

async def sendPasswordResetOTP(username: str, db: Session):
    user = db.query(User).filter(User.userUsername == username).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Account with email '{username}' does not exist."
        )
        
    otpCode = f"{random.randint(100000, 999999)}"  # Recommend 6-digit OTP
    expiresAt = getMyyTime() + timedelta(minutes=10)
    
    otpStore[username] = {
        "otp": otpCode,
        "expiresAt": expiresAt
    }
    
    htmlContent = f"""
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
        <h2>Password Reset Request</h2>
        <p>You requested a password reset for your account.</p>
        <p>Your One-Time Password (OTP) is:</p>
        <h1 style="color: #4CAF50; letter-spacing: 4px;">{otpCode}</h1>
        <p>This code will expire in <strong>10 minutes</strong>.</p>
        <p>If you did not request this, please ignore this email.</p>
    </div>
    """
    
    message = MessageSchema(
        subject="Your Password Reset OTP",
        recipients=[username],
        body=htmlContent,
        subtype=MessageType.html
    )
    
    fm = FastMail(mail_config)
    await fm.send_message(message)
    
    return {
        "status": "success",
        "message": f"OTP successfully sent to {username}"
    }

def resetPasswordWithOTP(payload: VerifyOTPAndResetPassword, db: Session):
    username = payload.userUsername
    record = otpStore.get(username)
    
    if not record:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No OTP requested for this email or OTP has expired."
        )
        
    if getMyyTime() > record["expiresAt"]:
        del otpStore[username]
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="OTP code has expired. Please request a new one."
        )
        
    if record["otp"] != payload.otpCode:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP code."
        )
        
    user = db.query(User).filter(User.userUsername == username).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found."
        )
        
    # --- CRITICAL FIX: Hash & Update Password ---
    user.userPassword = hashPassword(payload.newPassword)
    
    if hasattr(user, "userDateUpdated"):
        user.userDateUpdated = getMyyTime()
        
    db.commit()
    del otpStore[username]
    
    return {
        "status": "success",
        "message": "Password successfully reset. You can now log in with your new password."
    }
    
# Additional Features (Leaderboard, Quiz Title Randomizer, Restore Streak using EXP)
def leaderboardList(db: Session, skip: int = 0, limit: int = 100):
    results = (
        db.query(User, UserDetails)
        .join(UserDetails, User.userID == UserDetails.userDetailsUserID)
        .filter(User.userStatus == 1)
        .order_by(
            desc(UserDetails.userDetailsLevel),
            desc(UserDetails.userDetailsXP)
        )
        .offset(skip)
        .limit(limit)
        .all()
    )
    
    leaderboard = []
    for rank, (user,details) in enumerate(results, start = skip + 1):
        leaderboard.append({
            "userRank": rank,
            "userID": user.userID,
            "userName": getattr(user, "userName", user.userName),
            "userLevel": details.userDetailsLevel,
            "userXP": details.userDetailsXP,
            "userStreakCount": details.userDetailsStreakCount
        })
    
    return leaderboard

def restoreStreakWithXP(userID: int, xpCost: int, db: Session):
    details = db.query(UserDetails).filter(UserDetails.userDetailsUserID == userID).first()
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User details for user ID {userID} not found."
        )
        
    currentXP = details.userDetailsXP or 0
    
    # Check if enough XP
    if currentXP < xpCost:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Insufficient XP. You need {xpCost} XP to restore your streak, but only have {current_xp} XP."
        )
    
    # Deduct XP and update dynamically
    details.userDetailsXP = currentXP - xpCost
    details.userDetailsLevel = calculateLevelFromTotalXP(details.userDetailsXP)
    
    # Restore streak count to 1 and update activity date
    details.userDetailsStreakCount = 1
    details.userDetailsLastActivity = getMyyTime()
    
    # Sync bridge progress with updated level/XP
    currentChapter = details.userDetailsLevel
    progressWithinChapter = str(details.userDetailsXP % 500)
    
    existingBridge = db.query(bridge).filter(
        bridge.bridgeUserID == userID,
        bridge.bridgeChapterID == currentChapter
    ).first()
    
    if existingBridge:
        existingBridge.bridgeProgress = progressWithinChapter
        existingBridge.bridgeDateUpdated = getMyyTime()
        
    db.commit()
    db.refresh(details)
    
    return {
        "status": "success",
        "message": f"Streak restored successfully! Deducted {xpCost} XP.",
        "remainingXP": details.userDetailsXP,
        "currentLevel": details.userDetailsLevel,
        "streakCount": details.userDetailsStreakCount
    }
    
    
def resetUserXP(userID: int, db: Session):
    details = db.query(UserDetails).filter(UserDetails.userDetailsUserID == userID).first()
    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User details for user ID {userID} not found."
        )

    # 1. Reset XP and Level
    details.userDetailsXP = 0
    details.userDetailsLevel = calculateLevelFromTotalXP(0)  # Resolves to Level 1

    # 2. Sync active chapter bridge progress to Chapter 1, progress "0"
    currentChapter = details.userDetailsLevel
    progressWithinChapter = "0"

    existingBridge = db.query(bridge).filter(
        bridge.bridgeUserID == userID,
        bridge.bridgeChapterID == currentChapter
    ).first()

    if existingBridge:
        existingBridge.bridgeProgress = progressWithinChapter
        existingBridge.bridgeDateUpdated = getMyyTime()
    else:
        newBridge = bridge(
            bridgeUserID=userID,
            bridgeChapterID=currentChapter,
            bridgeProgress=progressWithinChapter,
            bridgeDateCreated=getMyyTime(),
            bridgeDateUpdated=getMyyTime()
        )
        db.add(newBridge)

    db.commit()
    db.refresh(details)

    return {
        "status": "success",
        "message": f"XP and level for user ID {userID} have been reset successfully.",
        "details": UserDetailsResponse.model_validate(details)
    }