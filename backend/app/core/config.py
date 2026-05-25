
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # App
    APP_NAME: str = "AURA OS"
    DEBUG: bool = False
    SECRET_KEY: str = "change-me-in-production"
    
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://aura:aura@localhost:5432/auraos"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Auth
    JWT_SECRET: str = "change-me"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_HOURS: int = 72
    
    # AI Generation
    STABILITY_API_KEY: str = ""
    OPENAI_API_KEY: str = ""
    COMFYUI_URL: str = "http://localhost:8188"
    LUMA_API_KEY: str = ""
    
    # Storage
    S3_BUCKET: str = "auraos-wallpapers"
    S3_REGION: str = "us-east-1"
    AWS_ACCESS_KEY: str = ""
    AWS_SECRET_KEY: str = ""
    
    # Stripe
    STRIPE_SECRET_KEY: str = ""
    STRIPE_WEBHOOK_SECRET: str = ""
    
    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    
    # CORS
    CORS_ORIGINS: List[str] = ["*"]
    
    # Rate Limiting
    FREE_GENERATIONS_PER_DAY: int = 3
    PRO_GENERATIONS_PER_DAY: int = 999
    
    # Workers
    GPU_WORKER_URL: str = "http://localhost:8001"
    
    class Config:
        env_file = ".env"


settings = Settings()
