"""
用户模型 — ORM 数据库映射

每个平台用户拥有独立的 API Key 集合、请求日志和用量配额。
删除用户时级联删除其所有关联数据（API Key、日志、配额）。
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, BigInteger
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone


class User(Base):
    """用户表 — 存储平台用户的基本信息"""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), nullable=True)
    hashed_password = Column(String(128), nullable=False)
    role = Column(String(20), default="user")
    is_active = Column(Boolean, default=True)
    is_approved = Column(Boolean, default=False)  # 管理员审批后设为 True
    quota_total = Column(BigInteger, default=1_000_000)
    quota_used = Column(BigInteger, default=0)
    quota_reset_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # 关联关系（级联删除：删除用户时自动删除其所有 Key、日志和配额）
    api_keys = relationship(
        "PlatformApiKey", back_populates="user",
        cascade="all, delete-orphan"
    )
    request_logs = relationship(
        "RequestLog", back_populates="user",
        cascade="all, delete-orphan"
    )
    usage_quotas = relationship(
        "UsageQuota", back_populates="user",
        cascade="all, delete-orphan"
    )
