from datetime import datetime, timezone, timedelta
from sqlalchemy import Column, Integer, String, DateTime, UniqueConstraint
from app.config.database import Base

MYT = timezone(timedelta(hours=8))

def get_myt_time():
    return datetime.now(MYT)

class bridge(Base):
    __tablename__ = "mod_bridge"
    
    bridgeID = Column("mod_bridge_id",Integer, primary_key=True)
    bridgeUserID = Column("mod_bridge_user_id",Integer, nullable=False)
    bridgeChapterID = Column("mod_bridge_chapter_id",Integer, nullable=False)
    bridgeProgress = Column("mod_bridge_progress",String(255), nullable=False, default=1)
    bridgeDateCreated = Column(
        "mod_bridge_date_created",
        DateTime,
        default=get_myt_time,
        nullable=False,
    )
    bridgeDateUpdated = Column(
        "mod_bridge_date_updated",
        DateTime,
        default=get_myt_time,
        onupdate=get_myt_time,
        nullable=False,
    )
    
    __table_args__ = (
        UniqueConstraint("mod_bridge_user_id", "mod_bridge_chapter_id", name="uq_user_chapter"),
    )