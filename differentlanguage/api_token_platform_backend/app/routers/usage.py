"""
用量统计路由模块 — /usage

提供用户级别的用量统计和配额查询端点：
- GET /usage/stats   — 综合用量统计总览（含图表数据）
- GET /usage/quotas  — 各厂商配额状态
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.dependencies import get_platform_api_key
from app.schemas.usage import UsageSummary, QuotaStatus
from app.models.user import User
from app.models.request_log import RequestLog
from app.models.usage_quota import UsageQuota

router = APIRouter(prefix="/usage", tags=["Usage"])


@router.get("/stats", response_model=UsageSummary)
def get_usage_stats(
    db: Session = Depends(get_db),
    user: User = Depends(get_platform_api_key),
    days: int = Query(30, ge=1, le=365),
):
    """
    获取用户综合用量统计

    查询参数:
        days: 统计最近N天的数据（默认30天，范围1-365）

    返回内容:
        - 总请求数（total_requests）
        - 总Token消耗（total_tokens）
        - 总费用估算（total_cost_estimate，美元）
        - 各厂商配额状态列表（quotas）
        - 最近20条请求记录（recent_requests）
    """
    from datetime import datetime, timedelta, timezone
    截止时间 = datetime.now(timezone.utc) - timedelta(days=days)

    # 统计总请求数
    总请求数 = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
        RequestLog.created_at >= 截止时间,
    ).count()

    # 统计总 Token 消耗
    Token记录列表 = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
        RequestLog.created_at >= 截止时间,
    ).with_entities(RequestLog.tokens_used).all()
    总Token数 = sum(r[0] or 0 for r in Token记录列表)

    # 统计总费用
    费用记录列表 = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
        RequestLog.created_at >= 截止时间,
    ).with_entities(RequestLog.cost_estimate).all()
    总费用 = sum(r[0] or 0.0 for r in 费用记录列表)

    # 各厂商配额状态
    配额列表 = db.query(UsageQuota).filter(UsageQuota.user_id == user.id).all()
    配额状态列表 = [
        QuotaStatus(
            vendor=q.vendor, period=q.period,
            max_tokens=q.max_tokens, used_tokens=q.used_tokens,
            remaining=max(0, q.max_tokens - q.used_tokens),
            reset_at=q.reset_at,
        ) for q in 配额列表
    ]

    # 最近20条请求记录
    最近请求 = db.query(RequestLog).filter(
        RequestLog.user_id == user.id,
    ).order_by(RequestLog.created_at.desc()).limit(20).all()
    最近请求列表 = [
        {
            "id": r.id, "vendor": r.vendor, "model": r.model,
            "tokens_used": r.tokens_used, "cost": r.cost_estimate,
            "latency_ms": r.latency_ms, "status": r.status_code,
            "created_at": r.created_at.isoformat(),
        } for r in 最近请求
    ]

    return UsageSummary(
        total_requests=总请求数,
        total_tokens=总Token数,
        total_cost_estimate=round(总费用, 6),
        quotas=配额状态列表,
        recent_requests=最近请求列表,
    )


@router.get("/quotas")
def get_quotas(
    db: Session = Depends(get_db),
    user: User = Depends(get_platform_api_key),
):
    """
    获取各厂商的配额状态

    返回每个厂商的：
        - vendor: 厂商名称
        - max_tokens: 月度Token预算
        - used_tokens: 已消耗Token数
        - remaining: 剩余可用Token数
        - reset_at: 配额重置时间
    """
    配额列表 = db.query(UsageQuota).filter(UsageQuota.user_id == user.id).all()
    return [
        {
            "vendor": q.vendor, "period": q.period,
            "max_tokens": q.max_tokens, "used_tokens": q.used_tokens,
            "remaining": max(0, q.max_tokens - q.used_tokens),
            "reset_at": q.reset_at.isoformat(),
        } for q in 配额列表
    ]
