"""
用量配额管理服务

管理每个用户对每个厂商的 Token 消耗配额，实现成本控制。

配额机制：
- 按月周期：每个自然月有固定的 Token 预算
- 按厂商维度：同一用户对不同厂商有独立配额
- 自动重置：每月1日自动将 used_tokens 归零
- 首次使用：首次调用某厂商时自动创建配额记录
"""

from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from app.models.usage_quota import UsageQuota
from app.config import settings


def 获取或创建配额(db: Session, user_id: int, vendor: str) -> UsageQuota:
    """
    获取用户的配额记录，不存在则自动创建，月底自动重置

    配额重置逻辑：
    - 新用户首次使用 → 创建配额，reset_at = 下月1日
    - 已过重置时间 → used_tokens 归零，reset_at 推进到下月1日
    - 未到重置时间 → 直接返回当前配额
    """
    当前时间 = datetime.now(timezone.utc)
    配额记录 = db.query(UsageQuota).filter(
        UsageQuota.user_id == user_id,
        UsageQuota.vendor == vendor,
        UsageQuota.period == "monthly",
    ).first()

    if 配额记录 is None:
        # 新用户或新厂商：创建初始配额
        下月首日 = (当前时间.replace(day=1) + timedelta(days=32)).replace(
            day=1, hour=0, minute=0, second=0, microsecond=0
        )
        配额记录 = UsageQuota(
            user_id=user_id,
            vendor=vendor,
            period="monthly",
            max_tokens=settings.rate_limit_tokens_per_month,
            used_tokens=0,
            reset_at=下月首日,
        )
        db.add(配额记录)
        db.commit()
        db.refresh(配额记录)
    elif 当前时间 >= 配额记录.reset_at:
        # 配额周期到了，自动重置
        配额记录.used_tokens = 0
        下月首日 = (当前时间.replace(day=1) + timedelta(days=32)).replace(
            day=1, hour=0, minute=0, second=0, microsecond=0
        )
        配额记录.reset_at = 下月首日
        db.commit()

    return 配额记录


get_or_create_quota = 获取或创建配额


def 检查配额(db: Session, user_id: int, vendor: str, 请求消耗量: int) -> bool:
    """
    检查用户对指定厂商的配额是否足够

    返回: True=配额充足，请求可以通过；False=配额耗尽，应返回429
    """
    配额记录 = 获取或创建配额(db, user_id, vendor)
    return (配额记录.used_tokens + 请求消耗量) <= 配额记录.max_tokens


check_quota = 检查配额


def 增加用量(db: Session, user_id: int, vendor: str, 消耗Token数: int):
    """
    请求成功后更新用户配额中的已用量

    应在每次 AI 调用成功返回后调用，确保用量统计准确。
    """
    配额记录 = 获取或创建配额(db, user_id, vendor)
    配额记录.used_tokens += 消耗Token数
    db.commit()


add_usage = 增加用量
