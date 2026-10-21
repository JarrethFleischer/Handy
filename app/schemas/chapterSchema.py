from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class QuestionSchema(BaseModel):
    questionNo: int
    questionTitle: str
    questionText: Optional[str] = None  # Made optional for quiz-type questions
    questionQuiz: Optional[List[str]] = (
        None  # Fixed syntax error (replaced 'as' with ':')
    )
    questionVideo: Optional[str] = None


class LessonSchema(BaseModel):
    lessonNo: int
    lessonTitle: Optional[str] = None
    lessonDesc: Optional[str] = (
        None  # Made optional to prevent strict validation failures
    )
    lessonQuestions: List[QuestionSchema]


class ChapterStorySchema(BaseModel):
    chapterTitle: str
    chapterDesc: Optional[str] = None
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