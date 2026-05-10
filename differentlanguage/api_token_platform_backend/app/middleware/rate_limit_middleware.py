"""
限流中间件（预留扩展点）

当前版本的具体限流逻辑在 relay 层实现（用户级令牌桶）。
此中间件作为预留扩展点，用于将来实现：
- 全局限流（所有请求共享的限流桶）
- IP 级别限流
- 在响应头中注入限流状态信息（X-RateLimit-*）
"""

from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from app.services.rate_limiter import rate_limiter


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    简易限流中间件（预留扩展）

    当前实现为透传（pass-through），具体的用户级限流在 relay_service 中处理。
    生产环境可在此处实现：
    - Redis 分布式限流
    - IP 级别 QPS 限制
    - 响应头注入（X-RateLimit-Limit / X-RateLimit-Remaining）
    """

    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        # TODO: 在响应头中加入限流信息
        return response
