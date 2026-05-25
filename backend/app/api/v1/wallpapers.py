
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.database import User, Wallpaper

router = APIRouter()


@router.get("/")
async def list_wallpapers(
    page: int = 1,
    limit: int = 20,
    style: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    query = select(Wallpaper).where(Wallpaper.is_public == True)
    if style:
        query = query.where(Wallpaper.style == style)
    query = query.order_by(Wallpaper.created_at.desc())
    
    offset = (page - 1) * limit
    result = await db.execute(query.offset(offset).limit(limit))
    wallpapers = result.scalars().all()
    
    return {
        "wallpapers": [
            {
                "id": str(w.id),
                "prompt": w.prompt,
                "style": w.style,
                "image_url": w.image_url,
                "thumbnail_url": w.thumbnail_url,
                "likes": w.likes,
                "downloads": w.downloads,
                "is_animated": w.is_animated,
                "effects": w.effects,
            }
            for w in wallpapers
        ],
        "page": page,
    }


@router.get("/{wallpaper_id}")
async def get_wallpaper(wallpaper_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Wallpaper).where(Wallpaper.id == wallpaper_id))
    w = result.scalar_one_or_none()
    if not w:
        raise HTTPException(status_code=404, detail="Wallpaper not found")
    
    return {
        "id": str(w.id),
        "prompt": w.prompt,
        "style": w.style,
        "image_url": w.image_url,
        "video_url": w.video_url,
        "effects": w.effects,
        "settings": w.settings,
        "likes": w.likes,
        "downloads": w.downloads,
    }


@router.post("/{wallpaper_id}/animations")
async def apply_animations(
    wallpaper_id: str,
    effects: List[dict],
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Wallpaper).where(
            Wallpaper.id == wallpaper_id,
            Wallpaper.user_id == user.id,
        )
    )
    w = result.scalar_one_or_none()
    if not w:
        raise HTTPException(status_code=404, detail="Wallpaper not found")
    
    w.effects = effects
    w.is_animated = True
    await db.commit()
    
    return {"id": str(w.id), "effects": w.effects, "is_animated": True}
