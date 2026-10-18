from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

class FeedbackBase(BaseModel):
    feedbackContent: str = Field(..., min_length=1, max_length=255)

class FeedbackCreate(FeedbackBase):
    feedbackUserID: int

class FeedbackResponse(FeedbackBase):
    feedbackID: int
    feedbackUserID: int
    userName: str
    feedbackDateCreated: datetime

    model_config = ConfigDict(from_attributes=True)