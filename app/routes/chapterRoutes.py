# from typing import List
# from fastapi import APIRouter, Depends, status, Request
# from sqlalchemy.orm import Session

# from app.config.database import getDB
# from app.controllers import Chapter
# from app.schemas.chapterSchema import (
#     ChapterCreate,
#     ChapterResponse,
#     ChapterUpdate,
# )

# router = APIRouter(prefix="/api/chapters", tags=["Chapters"])

# # 1. Get All Chapters
# @router.get("/", response_model=List[ChapterResponse], status_code=status.HTTP_200_OK)
# def readChapters(skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
#     return Chapter.getAllChapters(db, skip=skip, limit=limit)

# # 2. Dynamic Random Quiz (MUST BE ABOVE /{chapterID})
# @router.get("/random-quiz", status_code=status.HTTP_200_OK)
# def getRandomQuizQuestion(request: Request, count: int = 6, db: Session = Depends(getDB)):
#     return Chapter.getRandomQuizQuestion(db, request=request, count=count)

# # 3. Create Chapter
# @router.post("/create", response_model=ChapterResponse, status_code=status.HTTP_201_CREATED)
# def createChapter(chapterData: ChapterCreate, db: Session = Depends(getDB)):
#     return Chapter.createChapter(chapterData, db)

# # 4. Update Chapter
# @router.post("/update/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
# def updateChapter(chapterID: int, chapterData: ChapterUpdate, db: Session = Depends(getDB)):
#     return Chapter.updateChapter(chapterID, chapterData, db)

# # 5. Delete Chapter
# @router.post("/delete/{chapterID}", status_code=status.HTTP_200_OK)
# def deleteChapter(chapterID: int, db: Session = Depends(getDB)):
#     return Chapter.deleteChapter(chapterID, db)

# # 6. Get Chapter by ID (MUST BE AT THE BOTTOM OF GET ROUTES)
# @router.get("/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
# def readChapterByID(chapterID: int, db: Session = Depends(getDB)):
#     return Chapter.getChaptersByID(chapterID, db)

import json
from typing import List, Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, Request, status
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
def readChapters(request: Request, skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
    return Chapter.getAllChapters(db, request=request, skip=skip, limit=limit)

# 2. Random Quiz
@router.get("/random-quiz", status_code=status.HTTP_200_OK)
def getRandomQuizQuestion(request: Request, count: int = 6, db: Session = Depends(getDB)):
    return Chapter.getRandomQuizQuestion(db, request=request, count=count)

# 3. Create Chapter (Accepts raw JSON or Multipart Form Uploads with Videos)
@router.post("/create", response_model=ChapterResponse, status_code=status.HTTP_201_CREATED)
def createChapter(
    request: Request,
    chapterData: str = Form(..., description="JSON string containing ChapterCreate payload"),
    video_files: Optional[List[UploadFile]] = File(None),
    db: Session = Depends(getDB)
):
    try:
        parsed_data = json.loads(chapterData)
        validated_payload = ChapterCreate(**parsed_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Invalid JSON format for chapterData: {str(e)}"
        )

    return Chapter.createChapter(
        chapterData=validated_payload, 
        video_files=video_files, 
        request=request, 
        db=db
    )

# 4. Update Chapter
@router.post("/update/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
def updateChapter(
    chapterID: int,
    request: Request,
    chapterData: str = Form(...),
    video_files: Optional[List[UploadFile]] = File(None),
    db: Session = Depends(getDB)
):
    try:
        parsed_data = json.loads(chapterData)
        validated_payload = ChapterUpdate(**parsed_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Invalid JSON format for chapterData: {str(e)}"
        )

    return Chapter.updateChapter(
        chapterID=chapterID, 
        chapterData=validated_payload, 
        video_files=video_files, 
        request=request, 
        db=db
    )

# 5. Delete Chapter
@router.post("/delete/{chapterID}", status_code=status.HTTP_200_OK)
def deleteChapter(chapterID: int, db: Session = Depends(getDB)):
    return Chapter.deleteChapter(chapterID, db)

# 6. Read Chapter by ID (Keep static string routes above this route)
@router.get("/{chapterID}", response_model=ChapterResponse, status_code=status.HTTP_200_OK)
def readChapterByID(chapterID: int, request: Request, db: Session = Depends(getDB)):
    return Chapter.getChaptersByID(chapterID, db, request=request)