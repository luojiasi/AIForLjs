"""
平台 API Key 模型 — ORM 数据库映射

存储用户创建的 API Key 的安全信息。
- key_hash: bcrypt 单向哈希（不可逆），用于安全验证
- key_prefix: 前缀 "atp_" + 8位hex，用于快速索引缩小查找范围
- 完整 Key 永不存储，仅在创建时返回一次给用户
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone


class PlatformApiKey(Base):
    """平台 API Key 表 — bcrypt 哈希存储，前缀索引"""

    __tablename__ = "platform_api_keys"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    key_hash = Column(String(128), nullable=False)           # bcrypt 单向哈希值
    key_prefix = Column(String(12), nullable=False, index=True)  # "atp_" + 8位hex，用于快速索引
    name = Column(String(100), nullable=False)               # 用户给 Key 取的别名（如"开发环境"）
    is_active = Column(Boolean, default=True)                # Key 是否有效（撤销后设为 False）
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    last_used_at = Column(DateTime, nullable=True)           # 最后一次使用时间

    # 反向关联到用户
    user = relationship("User", back_populates="api_keys")
