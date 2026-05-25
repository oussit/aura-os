
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import Optional, List
import uuid
import asyncio
import json

from app.core.database import get_db
from app.core.config import settings
from app.core.auth import get_current_user
from app.models.database import User, Generation, GenerationStatus, Wallpaper

router = APIRouter()


class GenerateRequest(BaseModel):
    prompt: str
    negative_prompt: str = ""
    style: str = "cyberpunk"
    width: int = 1024
    height: int = 1024
    guidance_scale: float = 7.5
    steps: int = 30
    seed: int = -1
    enhance_prompt: bool = False
    animation_effects: List[str] = []


class EnhancePromptRequest(BaseModel):
    prompt: str
    style: Optional[str] = None
    enhance_level: str = "creative"


class GenerationResponse(BaseModel):
    id: str
    status: str
    progress: float
    image_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    error_message: Optional[str] = None


class DirectorRequest(BaseModel):
    message: str
    history: List[dict] = []
    context: str = "wallpaper_creation"


@router.post("/generate", response_model=GenerationResponse)
async def generate_wallpaper(
    req: GenerateRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    # Check generation limits
    if user.tier.value == "free" and user.generations_used >= user.generations_limit:
        raise HTTPException(
            status_code=429,
            detail="Daily generation limit reached. Upgrade to Pro for unlimited."
        )
    
    # Enhance prompt if requested
    prompt = req.prompt
    if req.enhance_prompt:
        prompt = await _enhance_prompt(req.prompt, req.style)
    
    # Create generation record
    generation = Generation(
        user_id=user.id,
        prompt=prompt,
        negative_prompt=req.negative_prompt,
        style=req.style,
        params={
            "width": req.width,
            "height": req.height,
            "guidance_scale": req.guidance_scale,
            "steps": req.steps,
            "seed": req.seed,
        },
    )
    db.add(generation)
    await db.commit()
    await db.refresh(generation)
    
    # Update user generation count
    user.generations_used += 1
    await db.commit()
    
    # Start background generation
    background_tasks.add_task(
        _process_generation,
        str(generation.id),
        req,
        prompt,
    )
    
    return GenerationResponse(
        id=str(generation.id),
        status="pending",
        progress=0.0,
    )


@router.get("/generate/{generation_id}")
async def get_generation_status(
    generation_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Generation).where(
            Generation.id == generation_id,
            Generation.user_id == user.id,
        )
    )
    gen = result.scalar_one_or_none()
    if not gen:
        raise HTTPException(status_code=404, detail="Generation not found")
    
    return GenerationResponse(
        id=str(gen.id),
        status=gen.status.value,
        progress=gen.progress,
        image_url=gen.image_url,
        error_message=gen.error_message,
    )


@router.get("/generate/{generation_id}/stream")
async def stream_generation(
    generation_id: str,
    db: AsyncSession = Depends(get_db),
):
    async def event_stream():
        for _ in range(150):  # Max 5 min timeout
            result = await db.execute(
                select(Generation).where(Generation.id == generation_id)
            )
            gen = result.scalar_one_or_none()
            if not gen:
                yield f"data: {json.dumps({'error': 'not found'})}\n\n"
                return
            
            data = {
                "id": str(gen.id),
                "status": gen.status.value,
                "progress": gen.progress,
                "image_url": gen.image_url,
            }
            yield f"data: {json.dumps(data)}\n\n"
            
            if gen.status in [GenerationStatus.COMPLETED, GenerationStatus.FAILED]:
                yield "data: [DONE]\n\n"
                return
            
            await asyncio.sleep(2)
    
    return StreamingResponse(event_stream(), media_type="text/event-stream")


@router.post("/enhance-prompt")
async def enhance_prompt(
    req: EnhancePromptRequest,
    user: User = Depends(get_current_user),
):
    enhanced = await _enhance_prompt(req.prompt, req.style)
    return {
        "original": req.prompt,
        "enhanced": enhanced,
        "suggested_styles": ["cyberpunk", "anime", "sci-fi"],
        "suggested_effects": ["particles", "rain", "parallax"],
        "suggested_tags": [req.style or "cyberpunk", "wallpaper", "ai"],
    }


@router.post("/director")
async def ai_director(
    req: DirectorRequest,
    user: User = Depends(get_current_user),
):
    # AI Director: parse user intent and create generation plan
    # In production, this calls an LLM
    return {
        "response": f"I'll create that for you! Based on your vision, I recommend:\n\n"
                    f"🎨 Style: {req.context}\n"
                    f"✨ Effects: particles, parallax, glow\n"
                    f"🌈 Colors: optimized for AMOLED\n"
                    f"🎬 Motion: cinematic with subtle drift\n\n"
                    f"Shall I generate?",
        "suggested_prompt": f"{req.message}, masterpiece, cinematic, AMOLED, detailed",
        "suggested_style": "cyberpunk",
        "suggested_effects": ["particles", "parallax", "glow"],
        "generate_ready": True,
    }


@router.get("/history")
async def get_generation_history(
    page: int = 1,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    offset = (page - 1) * limit
    result = await db.execute(
        select(Generation)
        .where(Generation.user_id == user.id)
        .order_by(Generation.created_at.desc())
        .offset(offset)
        .limit(limit)
    )
    generations = result.scalars().all()
    
    return {
        "items": [
            {
                "id": str(g.id),
                "status": g.status.value,
                "progress": g.progress,
                "image_url": g.image_url,
                "prompt": g.prompt,
                "style": g.style,
                "created_at": g.created_at.isoformat() if g.created_at else None,
            }
            for g in generations
        ],
        "page": page,
        "limit": limit,
    }


async def _enhance_prompt(prompt: str, style: str = None) -> str:
    """Enhance user prompt with quality tags"""
    style_tags = {
        "cyberpunk": "neon lights, cyberpunk aesthetic, futuristic, dark atmosphere",
        "anime": "anime style, cel shading, vibrant colors, manga art",
        "amoled": "pure black background, AMOLED, deep blacks, high contrast",
        "fantasy": "epic fantasy, magical, detailed environment, mystical",
        "sci-fi": "science fiction, space, futuristic technology, cinematic",
        "realistic": "photorealistic, 8k, detailed, hyper realistic",
        "gaming": "game art, dynamic, high detail, concept art",
        "nature": "nature photography, landscape, beautiful, serene",
    }
    
    enhancement = ", masterpiece, best quality, ultra detailed, 8k resolution"
    if style and style.lower() in style_tags:
        enhancement = f", {style_tags[style.lower()]}{enhancement}"
    
    return prompt + enhancement


async def _process_generation(generation_id: str, request: GenerateRequest, enhanced_prompt: str):
    """Background task: send to GPU worker and process result"""
    # In production: send to ComfyUI/Stable Diffusion GPU worker
    # For now: placeholder
    pass
