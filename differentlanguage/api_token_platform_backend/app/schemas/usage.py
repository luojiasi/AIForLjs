"""
用量统计相关的 Pydantic 数据模型

用于用量查询 API 的响应格式定义。
"""

from pydantic import BaseModel
from datetime import datetime


class QuotaStatus(BaseModel):
    """单个厂商的配额状态"""
    vendor: str             # 厂商名
    period: str             # 配额周期（monthly / daily）
    max_tokens: int         # Token 预算上限
    used_tokens: int        # 已消耗 Token 数
    remaining: int          # 剩余可用 Token 数
    reset_at: datetime      # 配额重置时间

    class Config:
        from_attributes = True


class UsageSummary(BaseModel):
    """用户用量综合统计总览"""
    total_requests: int         # 总请求数
    total_tokens: int           # 总 Token 消耗
    total_cost_estimate: float  # 总费用估算（美元）
    quotas: list[QuotaStatus]   # 各厂商配额状态
    recent_requests: list[dict] # 最近请求记录列表
