from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class BridgeBase(BaseModel):
    bridgeUserID: int
    bridgeChapterID: int
    bridgeProgress: str = Field("1", max_length=255)

class BridgeCreate(BridgeBase):
    pass

class BridgeUpdate(BaseModel):
    bridgeProgress: Optional[str] = Field(None, max_length=255)

class BridgeResponse(BridgeBase):
    bridgeID: int
    bridgeDateCreated: datetime
    bridgeDateUpdated: datetime

    class Config:
        from_attributes = True