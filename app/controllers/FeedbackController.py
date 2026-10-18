from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.feedback import Feedback
from app.models.user import User
from app.schemas.feedbackSchema import FeedbackCreate

def createFeedback(payload: FeedbackCreate, db: Session):
    user = db.query(User).filter(User.userID == payload.feedbackUserID).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {payload.feedbackUserID} not found."
        )
        
    newFeedback = Feedback(
        feedbackUserID = payload.feedbackUserID,
        feedbackContent = payload.feedbackContent
    )
    
    db.add(newFeedback)
    db.commit()
    db.refresh(newFeedback)
    
    return {
        "status": "success",
        "message": "Thank you for your feedback!",
        "feedbackID": newFeedback.feedbackID,
        "feedbackUserID": newFeedback.feedbackUserID,
        "userName": user.userName,
        "feedbackContent": newFeedback.feedbackContent,
        "feedbackDateCreated": newFeedback.feedbackDateCreated,
    }

def getAllFeedbacks(db: Session, skip: int = 0, limit: int = 100):
    results = (
        db.query(Feedback, User.userName)
        .join(User, Feedback.feedbackUserID == User.userID)
        .order_by(Feedback.feedbackDateCreated.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    
    feedbacks = []
    for feedbackItem, userName in results:
        feedbacks.append({
            "feedbackID": feedbackItem.feedbackID,
            "feedbackUserID": feedbackItem.feedbackUserID,
            "userName": userName,
            "feedbackContent": feedbackItem.feedbackContent,
            "feedbackDateCreated": feedbackItem.feedbackDateCreated,
        })
        
    return feedbacks