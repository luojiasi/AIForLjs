"""
定价配置模型 — ORM 数据库映射

存储每个模型的成本价和售价配置。
- cost_price: 从厂商采购的成本价（美元/百万Token）
- sell_price: 向客户销售的价格（美元/百万Token）
- profit_margin: 自动计算的利润率 = (sell_price - cost_price) / sell_price * 100
"""

from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime
from app.database import Base
from datetime import datetime, timezone


class PricingConfig(Base):
    """模型定价配置表"""

    __tablename__ = "pricing_configs"

    id = Column(Integer, primary_key=True, index=True)
    model_id = Column(String(100), unique=True, index=True, nullable=False)
    model_name = Column(String(100), nullable=False)
    vendor = Column(String(50), nullable=False, index=True)
    cost_input_price = Column(Float, default=0.0)     # 成本输入价 /1M tokens
    cost_output_price = Column(Float, default=0.0)    # 成本输出价 /1M tokens
    sell_input_price = Column(Float, default=0.0)     # 销售输入价 /1M tokens
    sell_output_price = Column(Float, default=0.0)    # 销售输出价 /1M tokens
    is_active = Column(Boolean, default=True)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
