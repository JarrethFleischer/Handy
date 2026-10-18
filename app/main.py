from fastapi import FastAPI
from app.routes import chapterRoutes, userRoutes, feedbackRoutes

app = FastAPI(title="Story Application API")

# Register chapter router
app.include_router(chapterRoutes.router)
app.include_router(userRoutes.router)
app.include_router(feedbackRoutes.router)