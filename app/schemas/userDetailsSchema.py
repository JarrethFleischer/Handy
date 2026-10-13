from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class UserDetailsBase(BaseModel):
    userDetailsLevel: str = Field(..., max_length=255)
    userDetailsXP: str = Field(..., max_length=255)
    userDetailsStreakCount: str = Field(..., max_length=255)

class UserDetailsCreate(UserDetailsBase):
    userDetailsUserID: int

class UserDetailsUpdate(BaseModel):
    userDetailsLevel: Optional[str] = Field(None, max_length=255)
    userDetailsXP: Optional[str] = Field(None, max_length=255)
    userDetailsStreakCount: Optional[str] = Field(None, max_length=255)

class UserDetailsResponse(UserDetailsBase):
    userDetailsID: int
    userDetailsUserID: int
    userDetailsDateCreated: datetime
    userDetailsDateUpdated: datetime

    class Config:
        from_attributes = True