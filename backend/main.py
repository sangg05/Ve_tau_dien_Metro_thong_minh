from fastapi import FastAPI
from backend import database, models
from backend.routers import user

app = FastAPI()

# Khởi tạo DB
models.Base.metadata.create_all(bind=database.engine)

# Đăng ký router
app.include_router(user.router)

@app.get("/")
def home():
    return {"message": "Backend is running!"}
