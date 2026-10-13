from datetime import datetime, timezone, timedelta
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.config.database import Base

MYT = timezone(timedelta(hours=8))

def get_myt_time():
    return datetime.now(MYT)

class User(Base):
    __tablename__ = "core_user"
    
    userID = Column("core_user_id", Integer, primary_key=True, index=True)
    userUsername = Column("core_user_username", String(255), unique=True, nullable=False, index=True)
    userPassword = Column("core_user_password", String(255), nullable=False)
    userStatus = Column("core_user_status", Integer, nullable=False, default=1)
    userDateCreated = Column(
        "core_user_date_created",
        DateTime,
        default=get_myt_time,
        nullable=False,
    )
    userDateUpdated = Column(
        "core_user_date_updated",
        DateTime,
        default=get_myt_time,
        onupdate=get_myt_time,
        nullable=False,
    )
    
    details = relationship("UserDetails", back_populates="user", uselist=False, cascade="all, delete-orphan")

class UserDetails(Base):
    __tablename__ = "core_user_details"
    
    userDetailsID = Column("core_user_details_id", Integer, primary_key=True, index=True)
    userDetailsUserID = Column("core_user_id", Integer, ForeignKey("core_user.core_user_id"), nullable=False, unique=True)
    userDetailsLevel = Column("core_user_details_level", Integer, nullable=False, default=0)
    userDetailsXP = Column("core_user_details_xp", Integer, nullable=False, default=0)
    userDetailsStreakCount = Column("core_user_details_streak_count", Integer, nullable=False, default=0)
    userDetailsDateCreated = Column(
        "core_user_details_date_created",
        DateTime,
        default=get_myt_time,
        nullable=False,
    )
    userDetailsDateUpdated = Column(
        "core_user_details_date_updated",
        DateTime,
        default=get_myt_time,
        onupdate=get_myt_time,
        nullable=False,
    )
    userDetailsLastActivity = Column("core_user_details_last_activity", DateTime, nullable=True)
    user = relationship("User", back_populates="details")
    