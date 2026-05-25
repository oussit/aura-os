
from fastapi import APIRouter
from app.api.v1 import auth, wallpapers, ai, social, subscriptions, users

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(wallpapers.router, prefix="/wallpapers", tags=["Wallpapers"])
api_router.include_router(ai.router, prefix="/ai", tags=["AI Generation"])
api_router.include_router(social.router, prefix="/social", tags=["Social"])
api_router.include_router(subscriptions.router, prefix="/subscription", tags=["Subscriptions"])
