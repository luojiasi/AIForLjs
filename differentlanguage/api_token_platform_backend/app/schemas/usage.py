"""
用量统计相关的 Pydantic 数据模型
"""

from pydantic import BaseModel
from datetime import datetime


class QuotaInfo(BaseModel):
    total: int
    used: int
    remaining: int
    reset_at: datetime
    usage_percent: float


class TodayStats(BaseModel):
    tokens: int
    cost: float
    requests: int


class TotalStats(BaseModel):
    tokens: int
    cost: float
    requests: int


class VendorUsage(BaseModel):
    vendor: str
    total_tokens: int
    cost: float
    requests: int


class ModelUsage(BaseModel):
    model: str
    vendor: str
    total_tokens: int
    cost: float
    requests: int


class DailyUsage(BaseModel):
    date: str
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    cost: float
    requests: int


class UsageStats(BaseModel):
    quota: QuotaInfo
    today: TodayStats
    total: TotalStats
    by_vendor: list[VendorUsage]
    by_model: list[ModelUsage]
    daily: list[DailyUsage]


class RequestLogItem(BaseModel):
    id: int
    model: str | None
    vendor: str
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    cost: float
    latency_ms: float | None
    status: str
    created_at: str


class PaginatedRequests(BaseModel):
    items: list[RequestLogItem]
    total: int
    page: int
    page_size: int
    total_pages: int
