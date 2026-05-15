"""
用户钱包模型 — ORM 数据库映射

存储用户账户余额和充值记录。
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone


class UserWallet(Base):
    """用户钱包表 — 账户余额"""

    __tablename__ = "user_wallets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    balance = Column(Float, default=0.0)  # 余额（美元）
    total_charged = Column(Float, default=0.0)  # 累计充值
    total_spent = Column(Float, default=0.0)  # 累计消费
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = relationship("User")


class WalletTransaction(Base):
    """钱包交易记录"""

    __tablename__ = "wallet_transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Float, nullable=False)  # 正数=充值，负数=消费
    type = Column(String(20), nullable=False)  # topup / consume / refund
    description = Column(String(200))
    balance_after = Column(Float, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
