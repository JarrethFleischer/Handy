from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, EmailStr

# Schema for UserDetails Response
class UserDetailsResponse(BaseModel):
    userDetailsID: int
    userDetailsLevel: int
    userDetailsXP: int
    userDetailsStreakCount: int
    userDetailsDateCreated: datetime
    userDetailsDateUpdated: datetime

    class Config:
        from_attributes = True

# Base User Schema
class UserBase(BaseModel):
    userUsername: EmailStr = Field(..., max_length=255, description="Email address for login")

class UserCreate(UserBase):
    userName: str = Field(None, max_length=255)
    userPassword: str = Field(..., min_length=6, max_length=255, description="Plain text password")
    userStatus: Optional[int] = 1

class UserUpdate(BaseModel):
    userName: Optional[str] = Field(None, max_length=255)
    userUsername: Optional[EmailStr] = Field(None, max_length=255)
    userPassword: Optional[str] = Field(None, min_length=6, max_length=255)
    userStatus: Optional[int] = Field(None, description="1 - Active, 2 - Disabled")

class UserResponse(UserBase):
    userID: int
    userName: str
    userStatus: int
    userDateCreated: datetime
    userDateUpdated: datetime
    details: Optional[UserDetailsResponse] = None  # Includes nested details in responses

    class Config:
        from_attributes = True
        
# Schema for adding XP
class AddXPResponse(BaseModel):
    status: str
    message: str
    levelUp: bool
    details: UserDetailsResponse

class AddXPRequest(BaseModel):
    xp_gained: int = Field(..., gt=0, description="Amount of XP gained")

# Schema for updating streak count
class UpdateStreakRequest(BaseModel):
    streak_count: int = Field(..., ge=0, description="New streak count")
    
class StreakUpdateResponse(BaseModel):
    message: str
    streak_count: int
    status: str
    
# To handle user login
class Token(BaseModel):
    status: str
    message: str
    access_token: str
    token_type: str

class TokenData(BaseModel):
    userID: int
    userUsername: str
    
class LoginSchema(BaseModel):
    username: str
    password: str
    
# Email
class SendOTPRequest(BaseModel):
    userUsername: EmailStr

class VerifyOTPAndResetPassword(BaseModel):
    userUsername: EmailStr
    otpCode: str
    newPassword: str