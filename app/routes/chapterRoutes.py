from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.config.database import getDB
from app.controllers import Chapter
from app.schemas.chapterSchema import (
    ChapterCreate,
    ChapterResponse,
    ChapterUpdate,
)

router = APIRouter(prefix="/api/chapters", tags=["Chapters"])

# 1. Get All Chapters
@router.get("/", response_model=List[ChapterResponse], status_code=status.HTTP_200_OK)
def readChapters(skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
    return Chapter.getAllChapters(db, skip=skip, limit=limit)

# 2. Dynamic Random Quiz (MUST BE ABOVE /{chapterID})
@router.get("/random-quiz", status_code=status.HTTP_200_OK)
def getRandomQuizQuestion(count: int = 6, db: Session = Depends(getDB)):
    return Chapter.getRandomQuizQuestion(db, count=count)

# 3. Create Chapter
@router.post("/create", response_model=ChapterResponse, status_code=status.HTTP_201_CREATED)
def createChapter(chapterData: ChapterCreate, db: Session = Depends(getDB)):
    return Chapter.createChapter(chapterData, db)

# 4. Update Chapter
@router.post("/update/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
def updateChapter(chapterID: int, chapterData: ChapterUpdate, db: Session = Depends(getDB)):
    return Chapter.updateChapter(chapterID, chapterData, db)

# 5. Delete Chapter
@router.post("/delete/{chapterID}", status_code=status.HTTP_200_OK)
def deleteChapter(chapterID: int, db: Session = Depends(getDB)):
    return Chapter.deleteChapter(chapterID, db)

# 6. Get Chapter by ID (MUST BE AT THE BOTTOM OF GET ROUTES)
@router.get("/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
def readChapterByID(chapterID: int, db: Session = Depends(getDB)):
    return Chapter.getChaptersByID(chapterID, db)