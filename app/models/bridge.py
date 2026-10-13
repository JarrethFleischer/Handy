from sqlalchemy import Column, Integer, String, DateTime, FetchedValue,func
from app.config.database import Base

class bridge(Base):
    __tablename__ = "mod_bridge"
    
    bridgeID = Column(Integer, primary_key=True)
    bridgeUserID = Column(Integer, nullable=False)
    bridgeChapterID = Column(Integer, nullable=False)
    bridgeProgress = Column(String(255), nullable=False, default=1)
    bridgeDateCreated = Column(
        DateTime,
        server_default=func.now(),
        nullable=False
    )
    bridgeDateUpdated = Column(
        DateTime,
        server_default=func.now(),
        server_onupdate=FetchedValue(),
        nullable=False
    )
    