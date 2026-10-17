from datetime import datetime, timezone, timedelta
from sqlalchemy import Column, Integer, JSON, DateTime, func
from app.config.database import Base


MYT = timezone(timedelta(hours=8))

def get_myt_time():
    return datetime.now(MYT)


class chapter(Base):
    __tablename__ = "core_chapter"

    chapterID = Column("core_chapter_id", Integer, primary_key=True)
    chapterLevel = Column("core_chapter_level", Integer, nullable=False)
    chapterStory = Column("core_chapter_story", JSON, nullable=False)
    chapterStatus = Column(
        "core_chapter_status", Integer, nullable=False, default=1
    )
    chapterDateCreated = Column(
        "core_chapter_date_created",
        DateTime,
        default=get_myt_time,
        nullable=False,
    )