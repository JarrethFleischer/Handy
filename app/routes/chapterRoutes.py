import json
from typing import List, Optional
from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    Request,
    UploadFile,
    status,
)
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
def readChapters(
    request: Request,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(getDB),
):
    return Chapter.getAllChapters(db, request=request, skip=skip, limit=limit)


# 2. Random Quiz (Must remain above /{chapterID})
@router.get("/random-quiz", status_code=status.HTTP_200_OK)
def getRandomQuizQuestion(
    request: Request, count: int = 6, db: Session = Depends(getDB)
):
    return Chapter.getRandomQuizQuestion(db, request=request, count=count)


# 3. Create Chapter (Handles both application/json AND multipart/form-data with video files)
@router.post(
    "/create",
    response_model=ChapterResponse,
    status_code=status.HTTP_201_CREATED,
)
async def createChapter(
    request: Request,
    chapterData: Optional[str] = Form(None),
    video_files: Optional[List[UploadFile]] = File(None),
    db: Session = Depends(getDB),
):
    content_type = request.headers.get("content-type", "")

    # Handle standard application/json requests
    if "application/json" in content_type:
        try:
            body = await request.json()
            validated_payload = ChapterCreate(**body)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid JSON body: {str(e)}",
            )
    # Handle multipart/form-data requests with video files
    elif chapterData:
        try:
            parsed_data = json.loads(chapterData)
            validated_payload = ChapterCreate(**parsed_data)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid JSON format in chapterData form field: {str(e)}",
            )
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing chapterData payload.",
        )

    return Chapter.createChapter(
        chapterData=validated_payload,
        video_files=video_files,
        request=request,
        db=db,
    )


# 4. Update Chapter (Handles both application/json AND multipart/form-data)
@router.post(
    "/update/{chapterID}",
    response_model=ChapterResponse,
    status_code=status.HTTP_200_OK,
)
async def updateChapter(
    chapterID: int,
    request: Request,
    chapterData: Optional[str] = Form(None),
    video_files: Optional[List[UploadFile]] = File(None),
    db: Session = Depends(getDB),
):
    content_type = request.headers.get("content-type", "")

    if "application/json" in content_type:
        try:
            body = await request.json()
            validated_payload = ChapterUpdate(**body)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid JSON body: {str(e)}",
            )
    elif chapterData:
        try:
            parsed_data = json.loads(chapterData)
            validated_payload = ChapterUpdate(**parsed_data)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid JSON format in chapterData form field: {str(e)}",
            )
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing chapterData payload.",
        )

    return Chapter.updateChapter(
        chapterID=chapterID,
        chapterData=validated_payload,
        video_files=video_files,
        request=request,
        db=db,
    )


# 5. Delete Chapter
@router.post("/delete/{chapterID}", status_code=status.HTTP_200_OK)
def deleteChapter(chapterID: int, db: Session = Depends(getDB)):
    return Chapter.deleteChapter(chapterID, db)


# 6. Read Chapter by ID (Keep static string routes like /random-quiz above this route)
@router.get(
    "/{chapterID}",
    response_model=ChapterResponse,
    status_code=status.HTTP_200_OK,
)
def readChapterByID(
    chapterID: int, request: Request, db: Session = Depends(getDB)
):
    return Chapter.getChaptersByID(chapterID, db, request=request)