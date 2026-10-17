from sqlalchemy import Column, Integer, String, DateTime, FetchedValue,func
from app.config.database import Base

class userDetails(Base):
    __tablename__ = "core_user_details"
    
    userDetailsID = Column(Integer, primary_key=True)
    userDetailsUserID = Column(Integer, nullable=False)
    userDetailsLevel = Column(String(255), nullable=False)
    userDetailsXP = Column(String(255), nullable=False)
    userDetailsStreakCount = Column(String(255), nullable=False)
    userDetailsDateCreated = Column(
        DateTime,
        server_default=func.now(),
        nullable=False
    )
        
    userDetailsDateUpdated = Column(
        DateTime,
        server_default=func.now(),
        server_onupdate=FetchedValue(),
        nullable=False
    )