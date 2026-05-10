"""
请求日志中间件

每次 HTTP 请求进入时，自动记录请求方法、路径、响应状态和延迟。
日志输出为结构化格式，方便后续接入 ELK / Splunk 等日志系统。

注意：此中间件只记录 HTTP 层面的信息，API Key、Token 用量等业务日志
由 relay_service 中的 execute_relay() 函数写入 request_logs 数据库表。
"""

import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger("api_gateway")


class LoggingMiddleware(BaseHTTPMiddleware):
    """
    HTTP 请求日志中间件

    记录每个请求的：
    - HTTP 方法（GET/POST/DELETE）
    - 请求路径
    - 响应状态码
    - 请求延迟（毫秒）
    - 客户端 IP
    """

    async def dispatch(self, request: Request, call_next):
        开始时间 = time.monotonic()
        response = await call_next(request)
        延迟毫秒 = (time.monotonic() - 开始时间) * 1000

        logger.info(
            "request",
            extra={
                "method": request.method,
                "path": request.url.path,
                "status": response.status_code,
                "latency_ms": round(延迟毫秒, 2),
                "client": request.client.host if request.client else "unknown",
            },
        )
        return response
