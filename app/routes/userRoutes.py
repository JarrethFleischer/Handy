from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.config.database import getDB
from app.controllers import User
from app.schemas.userSchema import (
    UserCreate,
    UserResponse,
    UserUpdate,
    AddXPRequest,
    UpdateStreakRequest,
    UserDetailsResponse,
    StreakUpdateResponse,
    Token,
    LoginSchema,
    AddXPResponse
)
from app.helpers.security import oauth2_scheme, decodeAccessToken
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(prefix="/api/user", tags=["Users"])

# Get all users
@router.get(
    "/",
    response_model=List[UserResponse],
    status_code=status.HTTP_200_OK
)
def readUsers(skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
    return User.getAllUsers(db, skip=skip, limit=limit)

# Get user by ID
@router.get(
    "/{userID}",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK
)
def getUserByID(userID: int, db: Session = Depends(getDB)):
    return User.getUserByID(userID, db)

# Create new user
@router.post(
    "/create",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED
)
def createUser(userData: UserCreate, db: Session = Depends(getDB)):
    return User.createUser(userData, db)

# Update user
@router.post(
    "/update/{userID}",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK
)
def updateUser(userID: int, userData: UserUpdate, db: Session = Depends(getDB)):
    return User.updateUser(userID, userData, db)

# Delete (disable) a user
@router.post(
    "/delete/{userID}",
    status_code=status.HTTP_200_OK
)
def deleteUser(userID: int, db: Session = Depends(getDB)):
    return User.deleteUser(userID, db)

# Add XP to a user
@router.post(
    "/{userID}/xp",
    response_model=AddXPResponse,
    status_code=status.HTTP_200_OK,
    summary="Add XP and process automatic level-up"
)
def addXP(userID: int, payload: AddXPRequest, db: Session = Depends(getDB)):
    return User.addUserXP(userID, payload.xp_gained, db)

@router.post(
    "/{userID}/streak",
    response_model=UserDetailsResponse,
    status_code=status.HTTP_200_OK,
    summary="Update user streak count"
)

def updateStreak(userID: int, payload: UpdateStreakRequest, db: Session = Depends(getDB)):
    return User.updateUserStreak(userID, payload.streak_count, db)

@router.post(
    "/{userID}/log-activity",
    response_model=StreakUpdateResponse,
    status_code=status.HTTP_200_OK,
    summary="Log daily user activity to maintain or increment streak"
)

def logDailyActivity(userID: int, db: Session = Depends(getDB)):
    return User.logDailyActivity(userID, db)

# Login & Logout
@router.post(
    "/login",
    response_model=Token,
    status_code=status.HTTP_200_OK,
    summary="Authenticate user and obtain JWT token"
)
def login(credential: LoginSchema, db: Session = Depends(getDB)):
    return User.loginUser(credential, db)

@router.post(
    "/logout",
    status_code=status.HTTP_200_OK,
    summary="Logout user and revoke active JWT token"
)

def logout(token: str = Depends(oauth2_scheme)):
    return User.logoutUser(token)

@router.get(
    "/me",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Get details of currently authenticated user"
)

def get_current_logged_in_user(token_payload: dict = Depends(decodeAccessToken), db: Session = Depends(getDB)):
    return User.getCurrentUser(token_payload, db)