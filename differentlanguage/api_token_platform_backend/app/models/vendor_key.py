"""
厂商密钥模型 — ORM 数据库映射

存储各 AI 厂商的 API Key（Fernet 对称加密）。
- encrypted_key: 使用 Fernet（AES-128-CBC + HMAC）加密的厂商 API Key
- 密钥仅在内存中解密使用，用完立即丢弃
- 支持自定义 base_url（对接代理或私有部署）
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime
from app.database import Base
from datetime import datetime, timezone


class VendorKey(Base):
    """厂商密钥表 — Fernet 加密存储厂商 API Key"""

    __tablename__ = "vendor_keys"

    id = Column(Integer, primary_key=True, index=True)
    vendor_name = Column(
        String(50), unique=True, index=True, nullable=False
    )  # 厂商标识名（如 "openai", "anthropic"），唯一
    display_name = Column(
        String(100), nullable=False
    )  # 显示名称（如 "OpenAI", "Anthropic Claude"）
    encrypted_key = Column(
        String(512), nullable=False
    )  # Fernet 加密后的密钥密文
    base_url = Column(
        String(256), nullable=True
    )  # 可选的自定义 API 端点（如使用代理）
    is_active = Column(Boolean, default=True)   # 厂商密钥是否启用
    created_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
