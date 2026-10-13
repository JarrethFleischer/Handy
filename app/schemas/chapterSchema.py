from datetime import datetime
from typing import Any, Dict, List, Optional, Union
from pydantic import BaseModel, Field

class ChapterBase(BaseModel):
    chapterLevel: int
    chapterStory: Union[Dict[str, Any], List[Any]] = Field(
        ..., description="JSON structure containing chapter story payload"
    )

class ChapterCreate(ChapterBase):
    chapterStatus: Optional[int] = 1

class ChapterUpdate(BaseModel):
    chapterLevel: Optional[int] = None
    chapterStory: Optional[Union[Dict[str, Any], List[Any]]] = None
    chapterStatus: Optional[int] = None

class ChapterResponse(ChapterBase):
    chapterID: int
    chapterStatus: int
    chapterDateCreated: datetime

    class Config:
        from_attributes = True