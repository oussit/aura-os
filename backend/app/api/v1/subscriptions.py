
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.config import settings
from app.core.auth import get_current_user
from app.models.database import User, Subscription, SubscriptionTier

router = APIRouter()

PRICES = {
    "pro_monthly": 9.99,
    "pro_yearly": 79.99,
    "ultra_monthly": 19.99,
    "ultra_yearly": 149.99,
}

TIER_LIMITS = {
    SubscriptionTier.FREE: 3,
    SubscriptionTier.PRO: 999,
    SubscriptionTier.ULTRA: 999,
}


class PurchaseRequest(BaseModel):
    product_id: str
    payment_method: str = "stripe"


@router.get("/status")
async def get_subscription_status(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Subscription).where(Subscription.user_id == user.id)
    )
    sub = result.scalar_one_or_none()
    
    return {
        "tier": user.tier.value,
        "subscription": {
            "id": str(sub.id),
            "tier": sub.tier.value,
            "status": sub.status,
            "start_date": sub.start_date.isoformat(),
            "end_date": sub.end_date.isoformat(),
            "auto_renew": sub.auto_renew,
        } if sub else None,
        "generations_used": user.generations_used,
        "generations_limit": user.generations_limit,
    }


@router.post("/purchase")
async def purchase_subscription(
    req: PurchaseRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if req.product_id not in PRICES:
        raise HTTPException(status_code=400, detail="Invalid product")
    
    # Determine tier
    tier = SubscriptionTier.PRO if "pro" in req.product_id else SubscriptionTier.ULTRA
    
    # Create subscription
    now = datetime.utcnow()
    duration = timedelta(days=365 if "yearly" in req.product_id else 30)
    
    sub = Subscription(
        user_id=user.id,
        tier=tier,
        status="active",
        start_date=now,
        end_date=now + duration,
        auto_renew=True,
    )
    db.add(sub)
    
    # Update user
    user.tier = tier
    user.generations_limit = TIER_LIMITS[tier]
    await db.commit()
    
    return {"status": "active", "tier": tier.value, "message": "Subscription activated!"}


@router.post("/restore")
async def restore_purchases(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == user.id,
            Subscription.status == "active",
            Subscription.end_date > datetime.utcnow(),
        )
    )
    sub = result.scalar_one_or_none()
    
    if sub:
        user.tier = sub.tier
        user.generations_limit = TIER_LIMITS[sub.tier]
        await db.commit()
        return {"restored": True, "tier": sub.tier.value}
    
    return {"restored": False}


@router.post("/webhook/stripe")
async def stripe_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    # Handle Stripe webhook events
    body = await request.body()
    # Verify signature and process event
    return {"received": True}
