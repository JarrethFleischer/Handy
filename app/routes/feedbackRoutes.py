from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.config.database import getDB
from app.schemas.feedbackSchema import FeedbackCreate, FeedbackResponse
from app.controllers import FeedbackController

router = APIRouter(prefix="/api/feedbacks", tags=["Feedbacks"])

@router.post("/create", response_model=FeedbackResponse, status_code=status.HTTP_201_CREATED)
def create_user_feedback(payload: FeedbackCreate, db: Session = Depends(getDB)):
    return FeedbackController.createFeedback(payload, db)

@router.get("/", response_model=List[FeedbackResponse])
def get_all_feedbacks(skip: int = 0, limit: int = 100, db: Session = Depends(getDB)):
    return FeedbackController.getAllFeedbacks(db, skip=skip, limit=limit)