"""
用量配额模型 — ORM 数据库映射

管理每个用户对每个厂商的 Token 消耗预算。
- 默认按月度周期（monthly）统计
- 每个厂商独立配额
- reset_at 字段标记配额自动重置时间
"""

from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone


class UsageQuota(Base):
    """用量配额表 — 按用户 + 厂商 + 周期维度管理 Token 预算"""

    __tablename__ = "usage_quotas"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    vendor = Column(
        String(50), nullable=False
    )  # 厂商名（"openai", "anthropic"）或 "*" 表示全局
    period = Column(
        String(20), nullable=False
    )  # 配额周期："monthly"（月度）或 "daily"（日度）
    max_tokens = Column(Integer, default=1_000_000)  # Token 预算上限
    used_tokens = Column(Integer, default=0)         # 已消耗 Token 数
    reset_at = Column(DateTime, nullable=False)       # 下次重置时间

    created_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # 反向关联到用户
    user = relationship("User", back_populates="usage_quotas")
