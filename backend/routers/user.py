from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend import database, models

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

# Dependency để lấy session DB
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Lấy danh sách tất cả user
