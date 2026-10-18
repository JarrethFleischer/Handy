from typing import List
from fastapi import APIRouter, Depends, Query, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.config.database import getDB
from app.controllers import User
from app.helpers.security import decodeAccessToken, oauth2_scheme
from app.schemas.userSchema import (
    AddXPRequest,
    AddXPResponse,
    LoginSchema,
    SendOTPRequest,
    StreakUpdateResponse,
    Token,
    UpdateStreakRequest,
    UserCreate,
    UserDetailsResponse,
    UserResponse,
    UserUpdate,
    VerifyOTPAndResetPassword,
)

router = APIRouter(prefix="/api/user", tags=["Users"])


# ==========================================
# 1. STATIC & SPECIFIC GET ROUTES (Top Priority)
# ==========================================


@router.get(
    "/", response_model=List[UserResponse], status_code=status.HTTP_200_OK
)
def readUsers(skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
    return User.getAllUsers(db, skip=skip, limit=limit)


@router.get(
    "/me",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Get details of currently authenticated user",
)
def get_current_logged_in_user(
    token_payload: dict = Depends(decodeAccessToken),
    db: Session = Depends(getDB),
):
    return User.getCurrentUser(token_payload, db)


@router.get("/leaderboard")
def get_leaderboard(
    skip: int = 0, limit: int = 100, db: Session = Depends(getDB)
):
    return User.leaderboardList(db, skip=skip, limit=limit)


# ==========================================
# 2. AUTHENTICATION & PASSWORD RESET ROUTES
# ==========================================


@router.post(
    "/create",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def createUser(userData: UserCreate, db: Session = Depends(getDB)):
    return User.createUser(userData, db)


@router.post(
    "/login",
    response_model=Token,
    status_code=status.HTTP_200_OK,
    summary="Authenticate user and obtain JWT token",
)
def login(credential: LoginSchema, db: Session = Depends(getDB)):
    return User.loginUser(credential, db)


@router.post(
    "/logout",
    status_code=status.HTTP_200_OK,
    summary="Logout user and revoke active JWT token",
)
def logout(token: str = Depends(oauth2_scheme)):
    return User.logoutUser(token)


@router.post("/forgot-password/send-otp")
async def send_otp(payload: SendOTPRequest, db: Session = Depends(getDB)):
    return await User.sendPasswordResetOTP(payload.userUsername, db)


@router.post("/forgot-password/reset")
def reset_password(
    payload: VerifyOTPAndResetPassword, db: Session = Depends(getDB)
):
    return User.resetPasswordWithOTP(payload, db)


@router.post("/streak/restore/{userID}")
def restore_streak(
    userID: int, xpCost: int = Query(200, ge=50), db: Session = Depends(getDB)
):
    return User.restoreStreakWithXP(userID=userID, xpCost=xpCost, db=db)


# ==========================================
# 3. DYNAMIC USER ID ROUTES (Bottom)
# ==========================================


@router.get(
    "/{userID}", response_model=UserResponse, status_code=status.HTTP_200_OK
)
def getUserByID(userID: int, db: Session = Depends(getDB)):
    return User.getUserByID(userID, db)


@router.post(
    "/update/{userID}",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
)
def updateUser(
    userID: int, userData: UserUpdate, db: Session = Depends(getDB)
):
    return User.updateUser(userID, userData, db)


@router.post("/delete/{userID}", status_code=status.HTTP_200_OK)
def deleteUser(userID: int, db: Session = Depends(getDB)):
    return User.deleteUser(userID, db)


@router.post(
    "/{userID}/xp",
    response_model=AddXPResponse,
    status_code=status.HTTP_200_OK,
    summary="Add XP and process automatic level-up",
)
def addXP(userID: int, payload: AddXPRequest, db: Session = Depends(getDB)):
    return User.addUserXP(userID, payload.xp_gained, db)


@router.post(
    "/{userID}/streak",
    response_model=UserDetailsResponse,
    status_code=status.HTTP_200_OK,
    summary="Update user streak count",
)
def updateStreak(
    userID: int, payload: UpdateStreakRequest, db: Session = Depends(getDB)
):
    return User.updateUserStreak(userID, payload.streak_count, db)


@router.post(
    "/{userID}/log-activity",
    response_model=StreakUpdateResponse,
    status_code=status.HTTP_200_OK,
    summary="Log daily user activity to maintain or increment streak",
)
def logDailyActivity(userID: int, db: Session = Depends(getDB)):
    return User.logDailyActivity(userID, db)