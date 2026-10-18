from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class QuestionSchema(BaseModel):
    questionNo: int
    questionTitle: str
    questionText: str
    questionVideo: Optional[str] = None


class LessonSchema(BaseModel):
    lessonNo: int
    lessonDesc: str
    lessonQuestions: List[QuestionSchema]


class ChapterStorySchema(BaseModel):
    chapterTitle: str
    chapterContent: List[LessonSchema]


class ChapterBase(BaseModel):
    chapterLevel: int
    chapterStory: ChapterStorySchema


class ChapterCreate(ChapterBase):
    chapterStatus: Optional[int] = 1


class ChapterUpdate(BaseModel):
    chapterLevel: Optional[int] = None
    chapterStory: Optional[ChapterStorySchema] = None
    chapterStatus: Optional[int] = None


class ChapterResponse(BaseModel):
    chapterID: int
    chapterLevel: int
    chapterStory: ChapterStorySchema
    chapterStatus: int
    chapterDateCreated: datetime

    class Config:
        from_attributes = True