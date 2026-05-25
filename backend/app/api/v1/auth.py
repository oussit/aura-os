
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr
from datetime import datetime, timedelta
import jwt

from app.core.database import get_db
from app.core.config import settings
from app.models.database import User

router = APIRouter()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    display_name: str = ""


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    tier: str


class FirebaseLoginRequest(BaseModel):
    firebase_token: str


@router.post("/register", response_model=TokenResponse)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    # Check existing
    existing = await db.execute(select(User).where(User.email == req.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Email already registered")
    
    user = User(
        email=req.email,
        display_name=req.display_name or req.email.split("@")[0],
        generations_limit=settings.FREE_GENERATIONS_PER_DAY,
        generations_reset_at=datetime.utcnow() + timedelta(days=1),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    
    token = _create_token(str(user.id))
    return TokenResponse(
        access_token=token,
        user_id=str(user.id),
        email=user.email,
        tier=user.tier.value,
    )


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # In production: verify hashed password
    token = _create_token(str(user.id))
    return TokenResponse(
        access_token=token,
        user_id=str(user.id),
        email=user.email,
        tier=user.tier.value,
    )


@router.post("/firebase", response_model=TokenResponse)
async def firebase_login(req: FirebaseLoginRequest, db: AsyncSession = Depends(get_db)):
    # Verify Firebase token and create/update user
    # Placeholder - would use firebase_admin.auth.verify_id_token
    raise HTTPException(status_code=501, detail="Firebase auth not configured")


def _create_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRY_HOURS),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
