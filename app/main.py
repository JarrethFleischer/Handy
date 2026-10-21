from fastapi import FastAPI
from app.routes import chapterRoutes, userRoutes, feedbackRoutes
from fastapi.staticfiles import StaticFiles
import os
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware

app = FastAPI(title="Story Application API")
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts=["*"])

# Main Routes
app.include_router(chapterRoutes.router)
app.include_router(userRoutes.router)
app.include_router(feedbackRoutes.router)

# Video purpose
# Calculate path to app/static/videos
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_VIDEOS_DIR = os.path.join(BASE_DIR, "static", "videos")

# Ensure app/static/videos exists on server startup
os.makedirs(STATIC_VIDEOS_DIR, exist_ok=True)

# Mount app/static to point to static file server
app.mount("/static", StaticFiles(directory=os.path.join(BASE_DIR, "static")), name="static")