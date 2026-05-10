"""
AI 中继路由模块 — /v1

核心端点：POST /v1/chat/completions
这是整个平台的"心脏"端点 — 接收客户端的 AI 请求，转发到对应厂商，返回统一格式响应。

认证方式: API Key（atp_ 前缀，通过 Authorization: Bearer 头传递）
请求格式: 兼容 OpenAI Chat Completions API 格式
响应格式: 平台统一的 RelayResponse 格式
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.dependencies import get_platform_api_key
from app.schemas.relay import RelayRequest, RelayResponse
from app.services.relay_service import execute_relay
from app.models.user import User

router = APIRouter(prefix="/v1", tags=["Relay"])


@router.post("/chat/completions", response_model=RelayResponse)
async def chat_completions(
    request: RelayRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_platform_api_key),
):
    """
    核心 AI 中继端点 — 统一转发 AI Chat 请求

    处理流程:
    1. 验证平台 API Key（由 get_platform_api_key 依赖自动完成）
    2. 根据 model 字段自动识别目标厂商（或使用 vendor 参数手动指定）
    3. 解密厂商 API Key（Fernet 解密）
    4. 适配请求格式并转发到厂商 API
    5. 标准化响应、记录审计日志、更新用量

    错误码:
        400 — 无法识别模型或厂商
        401 — API Key 无效
        429 — 请求频率超限或配额耗尽（由中间件处理）
        502 — 上游厂商 API 调用失败
    """
    try:
        response = await execute_relay(db, request, user)
        return response
    except ValueError as e:
        # 参数错误：不支持的厂商、无法识别的模型
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        # 厂商 API 调用失败（超时、认证失败、服务不可用等）
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Vendor API error: {e}"
        )
