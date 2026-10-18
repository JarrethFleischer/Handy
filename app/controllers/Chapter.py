import json
import random
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.chapter import chapter 
from app.schemas.chapterSchema import ChapterCreate, ChapterUpdate
from app.helpers.format_helper import format_api_response

def getAllChapters(db: Session, skip: int = 0, limit: int = 100):
    return db.query(chapter).filter(chapter.chapterStatus == 1).offset(skip).limit(limit).all()


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
        chapterLevel=chapterData.chapterLevel,
        chapterStory=chapterData.chapterStory.model_dump(),  # Convert Pydantic object to JSON-serializable dict
        chapterStatus=chapterData.chapterStatus or 1
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
    
# ---------------------------------------------------------
# Random Quiz Question Generator
# ---------------------------------------------------------

def extractQuestionsFromChapterStory(story_data: dict):
    """
    Traverses the chapterStory JSON and pulls all questions from each lesson.
    """
    questions = []
    
    if not isinstance(story_data, dict):
        return questions

    chapter_title = story_data.get("chapterTitle", "")
    lessons = story_data.get("chapterContent", [])

    for lesson in lessons:
        lesson_no = lesson.get("lessonNo")
        lesson_desc = lesson.get("lessonDesc")
        for q in lesson.get("lessonQuestions", []):
            questions.append({
                "questionNo": q.get("questionNo"),
                "questionTitle": q.get("questionTitle"),
                "questionText": q.get("questionText"),
                "questionVideo": q.get("questionVideo"),
                "lessonNo": lesson_no,
                "lessonDesc": lesson_desc,
                "chapterTitle": chapter_title
            })

    return questions

def getRandomQuizQuestion(db: Session, count: int = 6):
    """
    Retrieves all active chapters, aggregates questions across all lessons,
    and returns a randomized set of questions (default: 6).
    """
    activeChapters = db.query(chapter).filter(chapter.chapterStatus == 1).all()
    
    if not activeChapters:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active chapters found in database."
        )

    allQuestions = []

    for chap in activeChapters:
        story = chap.chapterStory
        
        # Parse string if database returned JSON as string
        if isinstance(story, str):
            try:
                story = json.loads(story)
            except json.JSONDecodeError:
                continue

        extracted = extractQuestionsFromChapterStory(story)
        
        # Attach chapter context metadata
        for q in extracted:
            q["chapterID"] = chap.chapterID
            q["chapterLevel"] = chap.chapterLevel
            allQuestions.append(q)

    if not allQuestions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No questions found inside chapter story records."
        )

    # Pick up to `count` unique random questions (or all if total < count)
    sample_size = min(count, len(allQuestions))
    randomQuestions = random.sample(allQuestions, sample_size)

    return {
        "status": "success",
        "total": len(randomQuestions),
        "questions": randomQuestions
    }