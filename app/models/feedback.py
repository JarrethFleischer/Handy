from datetime import datetime, timezone, timedelta
from sqlalchemy import Column, Integer, String, DateTime
from app.config.database import Base

MYT = timezone(timedelta(hours=8))

def get_myt_time():
    return datetime.now(MYT)

class Feedback(Base): 
    __tablename__ = "mod_feedback"
    
    feedbackID = Column("mod_feedback_id", Integer, primary_key=True, index=True)
    feedbackUserID = Column("mod_feedback_user_id", Integer, nullable=False)
    feedbackContent = Column("mod_feedback_content", String(255), nullable=False)
    feedbackDateCreated = Column(
        "mod_feedback_date_created",
        DateTime,
        default=get_myt_time,
        nullable=False,
    )