from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.chapter import chapter 
from app.schemas.chapterSchema import ChapterCreate, ChapterUpdate
from app.helpers.format_helper import format_api_response

def getAllChapters(db: Session, skip: int = 0, limit = 100):
    # Retrieve a list of all chapters with pagination
    chapters = db.query(chapter).filter(chapter.chapterStatus == 1).offset(skip).limit(limit).all()
    return chapters

def getChaptersByID(chapterID: int, db: Session):
    chapterByID = db.query(chapter).filter(chapter.chapterID == chapterID).first()
    
    if not chapterByID:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chapter with ID {chapterID} not found",
        )
    return chapterByID

def createChapter(chapterData: ChapterCreate, db: Session):
    newChapter = chapter(
        chapterLevel = chapterData.chapterLevel,
        chapterStory = chapterData.chapterStory,
        chapterStatus = chapterData.chapterStatus or 1
    )
    
    db.add(newChapter)
    db.commit()
    db.refresh(newChapter)
    return newChapter

def updateChapter(chapterID: int, chapterData: ChapterUpdate, db: Session):
    chapterByID = getChaptersByID(chapterID, db)
    updateData = chapterData.model_dump(exclude_unset=True)
    
    for key, value in updateData.items():
        setattr(chapterByID, key, value)
    
    db.commit()
    db.refresh(chapterByID)
    return chapterByID

def deleteChapter(chapterID: int, db: Session):
    chapterByID = getChaptersByID(chapterID, db)
    chapterByID.chapterStatus = 2
    
    db.commit()
    db.refresh(chapterByID)
    return format_api_response(
        True,
        f"Chapter {chapterID} disabled successfully", 
        chapterByID
    )
