
from fastapi import APIRouter, Depends
from app.core.auth import get_current_user
from app.models.database import User

router = APIRouter()


@router.get("/me")
async def get_profile(user: User = Depends(get_current_user)):
    return {
        "id": str(user.id),
        "email": user.email,
        "display_name": user.display_name,
        "avatar_url": user.avatar_url,
        "tier": user.tier.value,
        "generations_used": user.generations_used,
        "generations_limit": user.generations_limit,
        "total_creations": user.total_creations,
        "total_likes": user.total_likes,
        "followers": user.followers_count,
        "following": user.following_count,
    }
