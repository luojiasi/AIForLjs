"""
请求审计日志模型 — ORM 数据库映射

记录每一次 API 中继请求的完整信息，用于：
- 用量统计和费用核算
- 问题排查（哪个厂商、哪个模型出错）
- 安全审计（谁在什么时间调用了什么）
- 性能监控（每次调用的延迟）

不论请求成功还是失败，都会记录一条日志。
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone


class RequestLog(Base):
    """请求审计日志表 — 每次中继请求的完整记录"""

    __tablename__ = "request_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    vendor = Column(String(50), nullable=False)          # 调用的厂商（openai / anthropic）
    endpoint = Column(String(200), nullable=False)       # 调用的端点路径
    model = Column(String(100), nullable=True)           # 使用的模型名
    status_code = Column(Integer, nullable=True)         # 响应状态码（200=成功，500=失败）
    latency_ms = Column(Float, nullable=True)            # 响应延迟（毫秒）
    tokens_used = Column(Integer, default=0)             # 消耗的 Token 数
    cost_estimate = Column(Float, default=0.0)           # 费用估算（美元）
    error_message = Column(String(500), nullable=True)   # 错误信息（仅失败时记录）
    created_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    # 反向关联到用户
    user = relationship("User", back_populates="request_logs")
