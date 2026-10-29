import json
import os
import random
from typing import List, Optional, Union
from fastapi import HTTPException, Request, UploadFile, status
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from app.helpers.format_helper import format_api_response
from app.models.chapter import chapter
from app.schemas.chapterSchema import ChapterCreate, ChapterUpdate

UPLOAD_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "static",
    "videos",
)


def saveUploadedVideo(file: UploadFile):
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    fileLocation = os.path.join(UPLOAD_DIR, file.filename)

    with open(fileLocation, "wb") as buffer:
        buffer.write(file.file.read())

    return file.filename


def formatSingleVideoUrl(rawVideoPath: str, base_url: str) -> str:
    """Formats a single video path into a full HTTP static URL."""
    if not rawVideoPath:
        return ""
    if rawVideoPath.startswith(("http://", "https://")):
        return rawVideoPath

    fileName = (
        rawVideoPath if rawVideoPath.endswith(".mp4") else f"{rawVideoPath}.mp4"
    )
    return f"{base_url}/static/videos/{fileName}"


def formatVideoUrl(
    rawVideoPath: Union[str, List[str]], request: Request = None
) -> Union[str, List[str]]:
    """Flexibly formats video URLs whether questionVideo is a string or a list of strings."""
    if not rawVideoPath:
        return [] if isinstance(rawVideoPath, list) else ""

    env_base_url = os.getenv("BASE_URL")
    if env_base_url:
        base_url = env_base_url.rstrip("/")
    elif request:
        base_url = str(request.base_url).rstrip("/")
    else:
        base_url = "http://103.71.176.196"

    if isinstance(rawVideoPath, list):
        return [formatSingleVideoUrl(v, base_url) for v in rawVideoPath if v]

    return formatSingleVideoUrl(rawVideoPath, base_url)


def extractAndFormatStory(story_dict: dict, request: Request = None) -> dict:
    if not isinstance(story_dict, dict):
        return story_dict

    content = story_dict.get("chapterContent", [])
    for lesson in content:
        questions = lesson.get("lessonQuestions", [])
        for q in questions:
            if "questionVideo" in q and q["questionVideo"]:
                q["questionVideo"] = formatVideoUrl(q["questionVideo"], request)

    return story_dict


def resolveAnswerText(q: dict) -> str:
    """Dynamically resolves the correct answer string from questionText or video filename(s)."""
    q_text = q.get("questionText")
    if q_text and str(q_text).strip().lower() != "null":
        return str(q_text).strip()

    # Fallback: Extract title from video path (handles both string and list formats)
    video_data = q.get("questionVideo", "")
    target_video = ""
    if isinstance(video_data, list) and len(video_data) > 0:
        target_video = video_data[0]
    elif isinstance(video_data, str):
        target_video = video_data

    if target_video:
        base_name = os.path.basename(target_video)
        name_only = os.path.splitext(base_name)[0]
        clean_text = name_only.replace("_", " ").replace("-", " ").title()
        return clean_text

    return "Unknown"


# --- Controller Endpoints ---


def getAllChapters(
    db: Session, request: Request = None, skip: int = 0, limit: int = 100
):
    chapters = (
        db.query(chapter)
        .filter(chapter.chapterStatus == 1)
        .offset(skip)
        .limit(limit)
        .all()
    )
    for chap in chapters:
        if isinstance(chap.chapterStory, dict):
            chap.chapterStory = extractAndFormatStory(
                chap.chapterStory, request
            )
    return chapters


def getChaptersByID(chapterID: int, db: Session, request: Request = None):
    chapterByID = (
        db.query(chapter).filter(chapter.chapterID == chapterID).first()
    )
    if not chapterByID:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chapter with ID {chapterID} not found",
        )
    if isinstance(chapterByID.chapterStory, dict):
        chapterByID.chapterStory = extractAndFormatStory(
            chapterByID.chapterStory, request
        )
    return chapterByID


def createChapter(
    chapterData: ChapterCreate,
    video_files: Optional[List[UploadFile]] = None,
    request: Request = None,
    db: Session = None,
):
    if video_files:
        for video in video_files:
            if video.filename:
                saveUploadedVideo(video)

    story_dict = chapterData.chapterStory.model_dump()

    newChapter = chapter(
        chapterLevel=chapterData.chapterLevel,
        chapterStory=story_dict,
        chapterStatus=(
            chapterData.chapterStatus
            if chapterData.chapterStatus is not None
            else 1
        ),
    )

    db.add(newChapter)
    db.commit()
    db.refresh(newChapter)

    if isinstance(newChapter.chapterStory, dict):
        newChapter.chapterStory = extractAndFormatStory(
            dict(newChapter.chapterStory), request
        )

    return newChapter


def updateChapter(
    chapterID: int,
    chapterData: ChapterUpdate,
    video_files: Optional[List[UploadFile]] = None,
    request: Request = None,
    db: Session = None,
):
    chapterByID = getChaptersByID(chapterID, db, request=None)
    if not chapterByID:
        return None

    if video_files:
        for video in video_files:
            if video.filename:
                saveUploadedVideo(video)

    updateData = chapterData.model_dump(exclude_unset=True)

    for key, value in updateData.items():
        if key == "chapterStory" and value is not None:
            chapterByID.chapterStory = value
            flag_modified(chapterByID, "chapterStory")
        else:
            setattr(chapterByID, key, value)

    db.commit()
    db.refresh(chapterByID)

    if isinstance(chapterByID.chapterStory, dict):
        chapterByID.chapterStory = extractAndFormatStory(
            dict(chapterByID.chapterStory), request
        )

    return chapterByID


def deleteChapter(chapterID: int, db: Session):
    chapterByID = getChaptersByID(chapterID, db, request=None)
    chapterByID.chapterStatus = 2

    db.commit()
    db.refresh(chapterByID)
    return format_api_response(
        True, f"Chapter {chapterID} disabled successfully", chapterByID
    )


def getRandomQuizQuestion(db: Session, request: Request = None, count: int = 6):
    activeChapters = db.query(chapter).filter(chapter.chapterStatus == 1).all()
    if not activeChapters:
        raise HTTPException(status_code=404, detail="No active chapters found.")

    rawQuestions = []

    for chap in activeChapters:
        story = chap.chapterStory
        if isinstance(story, str):
            try:
                story = json.loads(story)
            except json.JSONDecodeError:
                continue

        if isinstance(story, dict):
            lessons = story.get("chapterContent", [])
            for lesson in lessons:
                for q in lesson.get("lessonQuestions", []):
                    rawQuestions.append(q)

    if not rawQuestions:
        raise HTTPException(status_code=404, detail="No questions found.")

    sample_size = min(count, len(rawQuestions))
    selectedQuestions = random.sample(rawQuestions, sample_size)

    finalQuestions = []
    for q in selectedQuestions:
        correct_answer = resolveAnswerText(q)
        formatted_video = formatVideoUrl(q.get("questionVideo", ""), request)

        item = {
            "questionNo": q.get("questionNo"),
            "questionTitle": q.get("questionTitle") or "What sign is shown?",
            "questionText": q.get("questionText"),
            "questionVideo": formatted_video,
        }

        # Include custom questionQuiz options if provided and non-empty
        q_quiz = q.get("questionQuiz")
        if isinstance(q_quiz, list) and len(q_quiz) > 0:
            choices = list(q_quiz)
            if correct_answer not in choices and correct_answer != "Unknown":
                choices.append(correct_answer)
            random.shuffle(choices)
            item["questionQuiz"] = choices
        else:
            item["questionQuiz"] = [] if isinstance(q_quiz, list) else None

        finalQuestions.append(item)

    return {
        "status": "success",
        "total": len(finalQuestions),
        "questions": finalQuestions,
    }