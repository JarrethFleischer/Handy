import json
import os
import random
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status, Request, UploadFile
from app.models.chapter import chapter 
from app.schemas.chapterSchema import ChapterCreate, ChapterUpdate
from app.helpers.format_helper import format_api_response

# Video extraction for frontend
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "static", "videos")

def saveUploadedVideo(file: UploadFile):
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    fileLocation = os.path.join(UPLOAD_DIR, file.filename)
    
    with open(fileLocation, "wb") as buffer:
        buffer.write(file.file.read())
    
    return file.filename
    
def formatVideoUrl(rawVideoPath: str, request: Request = None) -> str:
    if not rawVideoPath:
        return ""
    
    if rawVideoPath.startswith("http://") or rawVideoPath.startswith("https://"):
        return rawVideoPath
    
    fileName = rawVideoPath if rawVideoPath.endswith(".mp4") else f"{rawVideoPath}.mp4"
    
    if request:
        baseUrl = str(request.base_url).rstrip("/")
        return f"{baseUrl}/static/videos/{fileName}"
    
    # Fallback
    return f"/static/videos/{fileName}"

def extractAndFormatStory(storyData: dict, request: Request = None) -> dict:
    if not isinstance(storyData, dict):
        return storyData
    
    lessons = storyData.get("chapterContent", [])
    for lesson in lessons:
        for q in lesson.get("lessonQuestions", []):
            if "questionVideo" in q:
                q["questionVideo"] = formatVideoUrl(q["questionVideo"], request)
                
    return storyData

# --- Controller Endpoints ---

def getAllChapters(db: Session, request: Request = None, skip: int = 0, limit: int = 100):
    chapters = db.query(chapter).filter(chapter.chapterStatus == 1).offset(skip).limit(limit).all()
    for chap in chapters:
        if isinstance(chap.chapterStory, dict):
            chap.chapterStory = extractAndFormatStory(chap.chapterStory, request)
    return chapters


def getChaptersByID(chapterID: int, db: Session, request: Request = None):
    chapterByID = db.query(chapter).filter(chapter.chapterID == chapterID).first()
    if not chapterByID:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chapter with ID {chapterID} not found",
        )
    if isinstance(chapterByID.chapterStory, dict):
        chapterByID.chapterStory = extractAndFormatStory(chapterByID.chapterStory, request)
    return chapterByID


def createChapter(
    chapterData: ChapterCreate, 
    video_files: Optional[List[UploadFile]] = None, 
    request: Request = None, 
    db: Session = None
):
    # 1. Save uploaded video files to disk
    if video_files:
        for video in video_files:
            if video.filename:
                saveUploadedVideo(video)

    # 2. Extract and format story payload
    story_dict = chapterData.chapterStory.model_dump()

    newChapter = chapter(
        chapterLevel=chapterData.chapterLevel,
        chapterStory=story_dict,
        chapterStatus=chapterData.chapterStatus or 1
    )
    
    db.add(newChapter)
    db.commit()
    db.refresh(newChapter)
    
    # Format URLs for returned output
    newChapter.chapterStory = extractAndFormatStory(newChapter.chapterStory, request)
    return newChapter


def updateChapter(
    chapterID: int, 
    chapterData: ChapterUpdate, 
    video_files: Optional[List[UploadFile]] = None, 
    request: Request = None, 
    db: Session = None
):
    chapterByID = getChaptersByID(chapterID, db, request=None)
    
    if video_files:
        for video in video_files:
            if video.filename:
                saveUploadedVideo(video)

    updateData = chapterData.model_dump(exclude_unset=True)
    for key, value in updateData.items():
        setattr(chapterByID, key, value)
    
    db.commit()
    db.refresh(chapterByID)
    
    if isinstance(chapterByID.chapterStory, dict):
        chapterByID.chapterStory = extractAndFormatStory(chapterByID.chapterStory, request)
        
    return chapterByID


def deleteChapter(chapterID: int, db: Session):
    chapterByID = getChaptersByID(chapterID, db, request=None)
    chapterByID.chapterStatus = 2
    
    db.commit()
    db.refresh(chapterByID)
    return format_api_response(
        True,
        f"Chapter {chapterID} disabled successfully", 
        chapterByID
    )


def getRandomQuizQuestion(db: Session, request: Request = None, count: int = 6):
    activeChapters = db.query(chapter).filter(chapter.chapterStatus == 1).all()
    if not activeChapters:
        raise HTTPException(status_code=404, detail="No active chapters found.")

    allQuestions = []

    for chap in activeChapters:
        story = chap.chapterStory
        if isinstance(story, str):
            try:
                story = json.loads(story)
            except json.JSONDecodeError:
                continue

        if isinstance(story, dict):
            chapter_title = story.get("chapterTitle", "")
            lessons = story.get("chapterContent", [])
            for lesson in lessons:
                lesson_no = lesson.get("lessonNo")
                lesson_desc = lesson.get("lessonDesc")
                for q in lesson.get("lessonQuestions", []):
                    allQuestions.append({
                        "questionNo": q.get("questionNo"),
                        "questionTitle": q.get("questionTitle"),
                        "questionText": q.get("questionText"),
                        "questionVideo": formatVideoUrl(q.get("questionVideo", ""), request),
                        "lessonNo": lesson_no,
                        "lessonDesc": lesson_desc,
                        "chapterTitle": chapter_title,
                        "chapterID": chap.chapterID,
                        "chapterLevel": chap.chapterLevel
                    })

    if not allQuestions:
        raise HTTPException(status_code=404, detail="No questions found.")

    sample_size = min(count, len(allQuestions))
    randomQuestions = random.sample(allQuestions, sample_size)

    return {
        "status": "success",
        "total": len(randomQuestions),
        "questions": randomQuestions
    }