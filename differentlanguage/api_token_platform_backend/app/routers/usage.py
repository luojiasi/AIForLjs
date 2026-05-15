"""
用量统计路由模块 — /usage

提供用户级别的用量统计、配额查询和请求日志端点：
- GET /usage/stats    — 综合用量统计总览
- GET /usage/daily    — 每日用量趋势
- GET /usage/requests — 分页请求日志
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.usage import (
    UsageStats, QuotaInfo, TodayStats, TotalStats,
    VendorUsage, ModelUsage, DailyUsage,
    RequestLogItem, PaginatedRequests,
)
from app.models.user import User
from app.models.request_log import RequestLog
from app.models.usage_quota import UsageQuota
from app.models.wallet import UserWallet
from datetime import datetime, timezone, timedelta
import math

router = APIRouter(prefix="/usage", tags=["Usage"])


def _make_stats(db: Session, user_id: int, days: int) -> UsageStats:
    """Build the full UsageStats response."""
    now = datetime.now(timezone.utc)
    window_start = now - timedelta(days=days)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    # --- Quota (aggregate across all vendors) ---
    quotas = db.query(UsageQuota).filter(UsageQuota.user_id == user_id).all()
    if quotas:
        total_quota = sum(q.max_tokens for q in quotas)
        used_quota = sum(q.used_tokens for q in quotas)
        remaining = max(0, total_quota - used_quota)
        usage_percent = round((used_quota / total_quota * 100) if total_quota > 0 else 0, 1)
        reset_at = min(q.reset_at for q in quotas)
    else:
        total_quota = 1_000_000
        used_quota = 0
        remaining = total_quota
        usage_percent = 0.0
        reset_at = now + timedelta(days=30)

    # --- Today stats ---
    today_rows = db.query(RequestLog).filter(
        RequestLog.user_id == user_id,
        RequestLog.created_at >= today_start,
    ).all()
    today_tokens = sum(r.tokens_used or 0 for r in today_rows)
    today_cost = sum(r.cost_estimate or 0.0 for r in today_rows)
    today_requests = len(today_rows)

    # --- Total stats (all time) ---
    all_rows = db.query(RequestLog).filter(
        RequestLog.user_id == user_id,
    ).all()
    total_tokens = sum(r.tokens_used or 0 for r in all_rows)
    total_cost = sum(r.cost_estimate or 0.0 for r in all_rows)
    total_requests = len(all_rows)

    # --- By vendor (within window) ---
    window_rows = db.query(RequestLog).filter(
        RequestLog.user_id == user_id,
        RequestLog.created_at >= window_start,
    ).all()

    vendor_map: dict[str, dict] = {}
    model_map: dict[str, dict] = {}
    for r in window_rows:
        v = r.vendor or "unknown"
        m = r.model or "unknown"
        if v not in vendor_map:
            vendor_map[v] = {"total_tokens": 0, "cost": 0.0, "requests": 0}
        vendor_map[v]["total_tokens"] += (r.tokens_used or 0)
        vendor_map[v]["cost"] += (r.cost_estimate or 0.0)
        vendor_map[v]["requests"] += 1

        key = f"{v}:{m}"
        if key not in model_map:
            model_map[key] = {"model": m, "vendor": v, "total_tokens": 0, "cost": 0.0, "requests": 0}
        model_map[key]["total_tokens"] += (r.tokens_used or 0)
        model_map[key]["cost"] += (r.cost_estimate or 0.0)
        model_map[key]["requests"] += 1

    by_vendor = [
        VendorUsage(vendor=k, **v)
        for k, v in sorted(vendor_map.items(), key=lambda x: x[1]["total_tokens"], reverse=True)
    ]
    by_model = [
        ModelUsage(**v)
        for v in sorted(model_map.values(), key=lambda x: x["total_tokens"], reverse=True)
    ]

    # --- Daily breakdown (within window) ---
    daily_map: dict[str, dict] = {}
    for r in window_rows:
        date_str = r.created_at.strftime("%Y-%m-%d") if r.created_at else now.strftime("%Y-%m-%d")
        if date_str not in daily_map:
            daily_map[date_str] = {"total_tokens": 0, "cost": 0.0, "requests": 0}
        daily_map[date_str]["total_tokens"] += (r.tokens_used or 0)
        daily_map[date_str]["cost"] += (r.cost_estimate or 0.0)
        daily_map[date_str]["requests"] += 1

    daily = [
        DailyUsage(
            date=k,
            prompt_tokens=0,
            completion_tokens=0,
            total_tokens=v["total_tokens"],
            cost=round(v["cost"], 6),
            requests=v["requests"],
        )
        for k, v in sorted(daily_map.items())
    ]

    return UsageStats(
        quota=QuotaInfo(
            total=total_quota,
            used=used_quota,
            remaining=remaining,
            reset_at=reset_at,
            usage_percent=usage_percent,
        ),
        today=TodayStats(tokens=today_tokens, cost=round(today_cost, 6), requests=today_requests),
        total=TotalStats(tokens=total_tokens, cost=round(total_cost, 6), requests=total_requests),
        by_vendor=by_vendor,
        by_model=by_model,
        daily=daily,
    )


@router.get("/stats", response_model=UsageStats)
def get_usage_stats(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    return _make_stats(db, user.id, days)


@router.get("/daily", response_model=list[DailyUsage])
def get_daily_usage(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    now = datetime.now(timezone.utc)
    window_start = now - timedelta(days=days)
    rows = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
        RequestLog.created_at >= window_start,
    ).all()

    daily_map: dict[str, dict] = {}
    for r in rows:
        date_str = r.created_at.strftime("%Y-%m-%d") if r.created_at else now.strftime("%Y-%m-%d")
        if date_str not in daily_map:
            daily_map[date_str] = {"total_tokens": 0, "cost": 0.0, "requests": 0}
        daily_map[date_str]["total_tokens"] += (r.tokens_used or 0)
        daily_map[date_str]["cost"] += (r.cost_estimate or 0.0)
        daily_map[date_str]["requests"] += 1

    return [
        DailyUsage(
            date=k,
            prompt_tokens=0,
            completion_tokens=0,
            total_tokens=v["total_tokens"],
            cost=round(v["cost"], 6),
            requests=v["requests"],
        )
        for k, v in sorted(daily_map.items())
    ]


@router.get("/requests", response_model=PaginatedRequests)
def get_request_logs(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    total = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
    ).count()

    total_pages = max(1, math.ceil(total / page_size))
    offset = (page - 1) * page_size

    rows = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
    ).order_by(RequestLog.created_at.desc()).offset(offset).limit(page_size).all()

    items = [
        RequestLogItem(
            id=r.id,
            model=r.model,
            vendor=r.vendor,
            prompt_tokens=0,
            completion_tokens=0,
            total_tokens=r.tokens_used or 0,
            cost=round(r.cost_estimate or 0.0, 6),
            latency_ms=r.latency_ms,
            status="success" if (r.status_code and 200 <= r.status_code < 300) else "error",
            created_at=r.created_at.isoformat() if r.created_at else "",
        )
        for r in rows
    ]

    return PaginatedRequests(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages,
    )


@router.get("/wallet")
def get_my_wallet(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    wallet = db.query(UserWallet).filter(UserWallet.user_id == user.id).first()
    if wallet is None:
        return {"balance": 0.0, "total_charged": 0.0, "total_spent": 0.0, "transactions": []}

    transactions = db.query(WalletTransaction).filter(
        WalletTransaction.user_id == user.id
    ).order_by(WalletTransaction.created_at.desc()).limit(20).all()

    return {
        "balance": wallet.balance,
        "total_charged": wallet.total_charged,
        "total_spent": wallet.total_spent,
        "transactions": [
            {
                "id": t.id,
                "amount": t.amount,
                "type": t.type,
                "description": t.description,
                "balance_after": t.balance_after,
                "created_at": t.created_at.isoformat() if t.created_at else "",
            }
            for t in transactions
        ],
    }
