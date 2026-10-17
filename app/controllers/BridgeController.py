from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.bridge import bridge
from app.models.user import User
from app.schemas.bridgeSchema import BridgeCreate, BridgeUpdate
from datetime import datetime, timezone, timedelta

MYT = timezone(timedelta(hours=8))

def get_myt_time():
    return datetime.now(MYT)

def getUserChapterBridge(userID: int, chapterID: int, db: Session):
    bridgeRecord = db.query(bridge).filter(
        bridge.bridgeUserID == userID,
        bridge.bridgeChapterID == chapterID
    ).first()
    
    if not bridgeRecord:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Bridge record for User ID {userID} and Chapter ID {chapterID} not found."
        )
        
def createBridge(payload: BridgeCreate, db: Session):
    existingUser = db.query(User).filter(User.userID == payload.bridgeUserID).first()
    if not existingUser:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {payload.bridgeUserID} not found."
        )
        
    existingBridge = db.query(bridge).filter(
        bridge.bridgeUserID == payload.bridgeUserID,
        bridge.bridgeChapterID == payload.bridgeChapterID
    ).first()
    
    if existingBridge:
       raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bridge record already exists for User ID {payload.bridgeUserID} and Chapter ID {payload.bridgeChapterID}."
        )
       
    newBridge = bridge(
        bridgeUserID=payload.bridgeUserID,
        bridgeChapterID=payload.bridgeChapterID,
        bridgeProgress=payload.bridgeProgress
    )
    
    db.add(newBridge)
    db.commit()
    db.refresh()
    return newBridge

def updateBridgeProgress(userID: int, chapterID: int, bridgeData: BridgeUpdate, db: Session):
    bridgeRecord = getUserChapterBridge(userID, chapterID, db)
    
    if bridgeData.bridgeProgress is not None:
        bridgeRecord.bridgeProgress = bridgeData.bridgeProgress
        bridgeRecord.bridgeDateUpdated = get_myt_time()
        
    db.commit()
    db.refresh(bridgeRecord)
    return bridgeRecord