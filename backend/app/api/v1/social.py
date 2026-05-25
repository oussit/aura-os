
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from pydantic import BaseModel
from typing import Optional, List
import uuid

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.database import User, SocialPost, Like, Follow, Wallpaper

router = APIRouter()


class CreatePostRequest(BaseModel):
    wallpaper_id: str
    caption: str = ""
    tags: List[str] = []


class FeedResponse(BaseModel):
    posts: list
    has_more: bool


@router.post("/posts")
async def create_post(
    req: CreatePostRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    post = SocialPost(
        user_id=user.id,
        wallpaper_id=uuid.UUID(req.wallpaper_id),
        caption=req.caption,
        tags=req.tags,
    )
    db.add(post)
    user.total_creations += 1
    await db.commit()
    await db.refresh(post)
    
    return {
        "id": str(post.id),
        "caption": post.caption,
        "tags": post.tags,
        "created_at": post.created_at.isoformat(),
    }


@router.get("/feed")
async def get_feed(
    page: int = 1,
    limit: int = 20,
    trending: bool = False,
    db: AsyncSession = Depends(get_db),
):
    query = select(SocialPost).order_by(SocialPost.created_at.desc())
    if trending:
        query = select(SocialPost).order_by(
            (SocialPost.likes + SocialPost.shares * 2 + SocialPost.remixes * 3).desc()
        )
    
    offset = (page - 1) * limit
    result = await db.execute(query.offset(offset).limit(limit + 1))
    posts = result.scalars().all()
    
    return {
        "posts": [
            {
                "id": str(p.id),
                "user_id": str(p.user_id),
                "wallpaper_id": str(p.wallpaper_id),
                "caption": p.caption,
                "tags": p.tags,
                "likes": p.likes,
                "comments": p.comments_count,
                "shares": p.shares,
                "is_featured": p.is_featured,
                "created_at": p.created_at.isoformat(),
            }
            for p in posts[:limit]
        ],
        "has_more": len(posts) > limit,
    }


@router.post("/posts/{post_id}/like")
async def like_post(
    post_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    # Check if already liked
    existing = await db.execute(
        select(Like).where(Like.user_id == user.id, Like.post_id == uuid.UUID(post_id))
    )
    if existing.scalar_one_or_none():
        # Unlike
        like = existing.scalar_one()
        await db.delete(like)
        post = await db.get(SocialPost, uuid.UUID(post_id))
        if post:
            post.likes = max(0, post.likes - 1)
        await db.commit()
        return {"liked": False, "likes": post.likes if post else 0}
    
    # Like
    like = Like(user_id=user.id, post_id=uuid.UUID(post_id))
    db.add(like)
    post = await db.get(SocialPost, uuid.UUID(post_id))
    if post:
        post.likes += 1
    user.total_likes += 1
    await db.commit()
    
    return {"liked": True, "likes": post.likes if post else 0}


@router.post("/users/{user_id}/follow")
async def follow_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if str(user.id) == user_id:
        raise HTTPException(status_code=400, detail="Cannot follow yourself")
    
    existing = await db.execute(
        select(Follow).where(
            Follow.follower_id == user.id,
            Follow.following_id == uuid.UUID(user_id),
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Already following")
    
    follow = Follow(follower_id=user.id, following_id=uuid.UUID(user_id))
    db.add(follow)
    
    target = await db.get(User, uuid.UUID(user_id))
    if target:
        target.followers_count += 1
    user.following_count += 1
    await db.commit()
    
    return {"following": True}


@router.get("/trending")
async def get_trending(limit: int = 20, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(SocialPost)
        .where(SocialPost.is_featured == True)
        .order_by(SocialPost.likes.desc())
        .limit(limit)
    )
    posts = result.scalars().all()
    return {"posts": [{"id": str(p.id), "caption": p.caption, "likes": p.likes} for p in posts]}


@router.get("/creators/top")
async def get_top_creators(limit: int = 20, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User)
        .where(User.is_active == True, User.is_banned == False)
        .order_by(User.total_likes.desc())
        .limit(limit)
    )
    creators = result.scalars().all()
    return {
        "creators": [
            {
                "id": str(u.id),
                "display_name": u.display_name,
                "avatar_url": u.avatar_url,
                "creations": u.total_creations,
                "likes": u.total_likes,
                "followers": u.followers_count,
            }
            for u in creators
        ]
    }
