from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class BridgeBase(BaseModel):
    bridgeUserID: int
    bridgeChapterID: int
    bridgeProgress: str = Field("0", max_length=255)

class BridgeCreate(BridgeBase):
    pass

class BridgeUpdate(BaseModel):
    bridgeProgress: Optional[str] = Field(None, max_length=255)

class BridgeResponse(BridgeBase):
    bridgeID: int
    bridgeDateCreated: datetime
    bridgeDateUpdated: datetime

    model_config = ConfigDict(from_attributes=True)