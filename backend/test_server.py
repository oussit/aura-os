"""
AURA OS Backend - Standalone Test Server (SQLite)
Run: python3 backend/test_server.py
Test: curl http://localhost:8000/health
"""
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import sqlite3
import json
import uuid
from datetime import datetime
from contextlib import asynccontextmanager
from pydantic import BaseModel, EmailStr
from typing import Optional, List

# ===== Simple SQLite-based test server =====
DB_PATH = "auraos_test.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            display_name TEXT DEFAULT '',
            tier TEXT DEFAULT 'free',
            generations_used INTEGER DEFAULT 0,
            generations_limit INTEGER DEFAULT 3,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS generations (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            prompt TEXT NOT NULL,
            style TEXT DEFAULT 'cyberpunk',
            status TEXT DEFAULT 'pending',
            progress REAL DEFAULT 0.0,
            image_url TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS wallpapers (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            prompt TEXT NOT NULL,
            style TEXT DEFAULT 'cyberpunk',
            image_url TEXT,
            is_public INTEGER DEFAULT 0,
            likes INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS social_posts (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            wallpaper_id TEXT NOT NULL,
            caption TEXT DEFAULT '',
            likes INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
    """)
    conn.commit()
    conn.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    print("\n🔮 AURA OS Test Server running at http://localhost:8000")
    print("📖 Docs at http://localhost:8000/docs\n")
    yield

app = FastAPI(
    title="AURA OS API (Test Mode)",
    description="Standalone test server with SQLite",
    version="1.0.0-test",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== Models =====
class RegisterRequest(BaseModel):
    email: str
    display_name: str = ""

class GenerateRequest(BaseModel):
    prompt: str
    style: str = "cyberpunk"
    width: int = 1024
    height: int = 1024
    enhance_prompt: bool = False

class EnhancePromptRequest(BaseModel):
    prompt: str
    style: Optional[str] = None

class CreatePostRequest(BaseModel):
    wallpaper_id: str
    caption: str = ""
    tags: List[str] = []


# ===== Helper =====
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


# ===== Routes =====
@app.get("/health")
async def health():
    return {"status": "healthy", "service": "aura-os-api", "mode": "test", "version": "1.0.0"}


@app.post("/v1/auth/register")
async def register(req: RegisterRequest):
    uid = str(uuid.uuid4())
    conn = get_db()
    try:
        conn.execute(
            "INSERT INTO users (id, email, display_name) VALUES (?, ?, ?)",
            (uid, req.email, req.display_name or req.email.split("@")[0])
        )
        conn.commit()
    except sqlite3.IntegrityError:
        conn.close()
        return {"error": "Email already registered"}
    conn.close()
    return {"user_id": uid, "email": req.email, "tier": "free", "token": f"test-token-{uid[:8]}"}


@app.post("/v1/ai/generate")
async def generate_wallpaper(req: GenerateRequest):
    gid = str(uuid.uuid4())
    
    # Simulate prompt enhancement
    prompt = req.prompt
    if req.enhance_prompt:
        style_tags = {
            "cyberpunk": "neon lights, cyberpunk aesthetic, futuristic, dark atmosphere",
            "anime": "anime style, cel shading, vibrant colors",
            "amoled": "pure black background, AMOLED, deep blacks, high contrast",
            "fantasy": "epic fantasy, magical, detailed environment",
            "sci-fi": "science fiction, space, futuristic technology",
        }
        enhancement = style_tags.get(req.style, "masterpiece, best quality, ultra detailed")
        prompt = f"{req.prompt}, {enhancement}, 8k resolution"
    
    conn = get_db()
    conn.execute(
        "INSERT INTO generations (id, user_id, prompt, style, status, progress) VALUES (?, ?, ?, ?, ?, ?)",
        (gid, "test-user", prompt, req.style, "completed", 1.0)
    )
    conn.commit()
    conn.close()
    
    return {
        "id": gid,
        "status": "completed",
        "progress": 1.0,
        "prompt": prompt,
        "style": req.style,
        "image_url": None,
        "message": "Generation complete! (test mode — connect GPU worker for real images)",
    }


@app.post("/v1/ai/enhance-prompt")
async def enhance_prompt(req: EnhancePromptRequest):
    style_tags = {
        "cyberpunk": "neon lights, cyberpunk aesthetic, futuristic, dark atmosphere, rain-soaked streets",
        "anime": "anime style, cel shading, vibrant colors, manga art, studio ghibli",
        "amoled": "pure black background, AMOLED, deep blacks, high contrast, minimal",
        "fantasy": "epic fantasy, magical, detailed environment, mystical atmosphere",
        "sci-fi": "science fiction, space, futuristic technology, cinematic lighting",
    }
    
    enhancement = style_tags.get(req.style or "cyberpunk", "masterpiece, best quality")
    enhanced = f"{req.prompt}, {enhancement}, ultra detailed, 8k resolution, cinematic lighting"
    
    return {
        "original": req.prompt,
        "enhanced": enhanced,
        "suggested_styles": ["cyberpunk", "anime", "sci-fi", "fantasy"],
        "suggested_effects": ["particles", "rain", "parallax", "glow"],
    }


@app.post("/v1/ai/director")
async def ai_director(req: dict = {}):
    return {
        "response": f"Great vision! I'd recommend:\n\n🎨 Style: Cyberpunk Neon\n✨ Effects: Particles + Fog + Parallax\n🌈 Colors: Cyan, Purple, Deep Black\n🎬 Motion: Gentle drift with glow\n\nShall I generate?",
        "suggested_prompt": f"{req.get("message", "wallpaper")}, cyberpunk, neon, cinematic, AMOLED, masterpiece",
        "suggested_style": "cyberpunk",
        "suggested_effects": ["particles", "parallax", "glow", "fog"],
    }


@app.get("/v1/ai/history")
async def get_history(page: int = 1, limit: int = 20):
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM generations ORDER BY created_at DESC LIMIT ? OFFSET ?",
        (limit, (page - 1) * limit)
    ).fetchall()
    conn.close()
    return {"items": [dict(r) for r in rows], "page": page}


@app.get("/v1/wallpapers")
async def list_wallpapers(style: Optional[str] = None, page: int = 1, limit: int = 20):
    conn = get_db()
    if style:
        rows = conn.execute(
            "SELECT * FROM wallpapers WHERE is_public=1 AND style=? ORDER BY created_at DESC LIMIT ?",
            (style, limit)
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM wallpapers WHERE is_public=1 ORDER BY created_at DESC LIMIT ?",
            (limit,)
        ).fetchall()
    conn.close()
    return {"wallpapers": [dict(r) for r in rows], "page": page}


@app.get("/v1/social/feed")
async def social_feed(page: int = 1, limit: int = 20):
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM social_posts ORDER BY likes DESC LIMIT ?",
        (limit,)
    ).fetchall()
    conn.close()
    return {"posts": [dict(r) for r in rows], "has_more": False}


@app.post("/v1/social/posts/{post_id}/like")
async def like_post(post_id: str):
    conn = get_db()
    conn.execute("UPDATE social_posts SET likes = likes + 1 WHERE id = ?", (post_id,))
    conn.commit()
    row = conn.execute("SELECT likes FROM social_posts WHERE id = ?", (post_id,)).fetchone()
    conn.close()
    return {"liked": True, "likes": row["likes"] if row else 0}


@app.get("/v1/users/me")
async def get_profile():
    return {
        "id": "test-user",
        "email": "test@auraos.app",
        "display_name": "Test Creator",
        "tier": "pro",
        "generations_used": 5,
        "generations_limit": 999,
        "total_creations": 12,
        "followers": 42,
        "following": 18,
    }


@app.get("/v1/subscription/status")
async def subscription_status():
    return {
        "tier": "free",
        "subscription": None,
        "generations_used": 0,
        "generations_limit": 3,
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
