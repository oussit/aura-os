
import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, JSON, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
from app.core.database import Base
import enum


class SubscriptionTier(str, enum.Enum):
    FREE = "free"
    PRO = "pro"
    ULTRA = "ultra"


class GenerationStatus(str, enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    display_name = Column(String(100), default="")
    avatar_url = Column(String(500), default="")
    firebase_uid = Column(String(128), unique=True, index=True)
    
    tier = Column(SQLEnum(SubscriptionTier), default=SubscriptionTier.FREE)
    generations_used = Column(Integer, default=0)
    generations_limit = Column(Integer, default=3)
    generations_reset_at = Column(DateTime)
    
    total_creations = Column(Integer, default=0)
    total_likes = Column(Integer, default=0)
    followers_count = Column(Integer, default=0)
    following_count = Column(Integer, default=0)
    
    is_active = Column(Boolean, default=True)
    is_banned = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    last_active_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    wallpapers = relationship("Wallpaper", back_populates="user")
    subscription = relationship("Subscription", back_populates="user", uselist=False)
    posts = relationship("SocialPost", back_populates="user")


class Wallpaper(Base):
    __tablename__ = "wallpapers"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    prompt = Column(Text, nullable=False)
    enhanced_prompt = Column(Text)
    negative_prompt = Column(Text, default="")
    style = Column(String(50), default="cyberpunk")
    
    image_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500))
    video_url = Column(String(500))
    
    width = Column(Integer, default=1024)
    height = Column(Integer, default=1024)
    
    tags = Column(ARRAY(String), default=[])
    effects = Column(JSON, default=[])
    settings = Column(JSON, default={})
    
    is_public = Column(Boolean, default=False)
    is_premium = Column(Boolean, default=False)
    is_animated = Column(Boolean, default=False)
    
    likes = Column(Integer, default=0)
    downloads = Column(Integer, default=0)
    views = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="wallpapers")


class Generation(Base):
    __tablename__ = "generations"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    wallpaper_id = Column(UUID(as_uuid=True), ForeignKey("wallpapers.id"), nullable=True)
    
    status = Column(SQLEnum(GenerationStatus), default=GenerationStatus.PENDING)
    progress = Column(Float, default=0.0)
    
    prompt = Column(Text, nullable=False)
    negative_prompt = Column(Text, default="")
    style = Column(String(50), default="cyberpunk")
    params = Column(JSON, default={})
    
    image_url = Column(String(500))
    error_message = Column(Text)
    
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)


class SocialPost(Base):
    __tablename__ = "social_posts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    wallpaper_id = Column(UUID(as_uuid=True), ForeignKey("wallpapers.id"), nullable=False)
    
    caption = Column(Text, default="")
    tags = Column(ARRAY(String), default=[])
    
    likes = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    shares = Column(Integer, default=0)
    remixes = Column(Integer, default=0)
    
    is_featured = Column(Boolean, default=False)
    original_post_id = Column(UUID(as_uuid=True), nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="posts")
    wallpaper = relationship("Wallpaper")


class Subscription(Base):
    __tablename__ = "subscriptions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)
    
    tier = Column(SQLEnum(SubscriptionTier), nullable=False)
    status = Column(String(20), default="active")
    
    stripe_subscription_id = Column(String(100))
    stripe_customer_id = Column(String(100))
    
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    auto_renew = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="subscription")


class Like(Base):
    __tablename__ = "likes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    post_id = Column(UUID(as_uuid=True), ForeignKey("social_posts.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Follow(Base):
    __tablename__ = "follows"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    follower_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    following_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class CreatorRevenue(Base):
    __tablename__ = "creator_revenue"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    amount_cents = Column(Integer, default=0)
    source = Column(String(50))  # marketplace, tips, packs
    period = Column(String(20))  # 2024-01
    paid = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
