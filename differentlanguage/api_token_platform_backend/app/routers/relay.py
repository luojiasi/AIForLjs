"""
AI 中继路由模块 — /v1

核心端点：
- POST /v1/chat/completions — AI 请求转发
- GET  /v1/models — 列出可用模型

认证方式: API Key（atp_ 前缀）或 JWT Bearer Token
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.dependencies import get_current_user_or_api_key
from app.schemas.relay import RelayRequest, RelayResponse
from app.services.relay_service import execute_relay
from app.adapters.factory import get_all_adapters
from app.models.user import User
from app.models.pricing import PricingConfig
from app.models.vendor_key import VendorKey

router = APIRouter(prefix="/v1", tags=["Relay"])


@router.post("/chat/completions", response_model=RelayResponse)
async def chat_completions(
    request: RelayRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user_or_api_key),
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


# ── 厂商/模型定价（每百万Token，USD） ──
_VENDOR_MODELS = {
    "openai": {
        "display_name": "OpenAI",
        "models": {
            "gpt-4o": {"name": "GPT-4o", "input_price": 2.50, "output_price": 10.00, "max_tokens": 128000},
            "gpt-4o-mini": {"name": "GPT-4o Mini", "input_price": 0.15, "output_price": 0.60, "max_tokens": 128000},
            "gpt-4-turbo": {"name": "GPT-4 Turbo", "input_price": 10.00, "output_price": 30.00, "max_tokens": 128000},
        },
    },
    "anthropic": {
        "display_name": "Anthropic Claude",
        "models": {
            "claude-sonnet-4-6": {"name": "Claude Sonnet 4.6", "input_price": 3.00, "output_price": 15.00, "max_tokens": 200000},
            "claude-opus-4-7": {"name": "Claude Opus 4.7", "input_price": 15.00, "output_price": 75.00, "max_tokens": 200000},
            "claude-haiku-4-5": {"name": "Claude Haiku 4.5", "input_price": 0.80, "output_price": 4.00, "max_tokens": 200000},
        },
    },
}


@router.get("/models")
def list_models(
    user: User = Depends(get_current_user_or_api_key),
    db: Session = Depends(get_db),
):
    """列出所有可用模型及销售定价"""
    pricing_map = {c.model_id: c for c in db.query(PricingConfig).filter(PricingConfig.is_active == True).all()}
    result = []
    for vendor_key, vendor_data in _VENDOR_MODELS.items():
        for model_id, model_data in vendor_data["models"].items():
            cfg = pricing_map.get(model_id)
            result.append({
                "id": model_id,
                "vendor": vendor_key,
                "vendor_name": vendor_data["display_name"],
                "name": model_data["name"],
                "input_price": cfg.sell_input_price if cfg and cfg.sell_input_price > 0 else model_data["input_price"],
                "output_price": cfg.sell_output_price if cfg and cfg.sell_output_price > 0 else model_data["output_price"],
                "max_tokens": model_data["max_tokens"],
            })
    return {"data": result, "count": len(result)}


@router.get("/pricing")
def public_pricing(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user_or_api_key),
):
    """公开定价查询 — 客户可查看当前价格"""
    configs = db.query(PricingConfig).filter(PricingConfig.is_active == True).all()
    config_map = {c.model_id: c for c in configs}
    result = []
    for vendor_key, vendor_data in _VENDOR_MODELS.items():
        for model_id, model_data in vendor_data["models"].items():
            cfg = config_map.get(model_id)
            result.append({
                "model_id": model_id,
                "model_name": model_data["name"],
                "vendor": vendor_key,
                "input_price": cfg.sell_input_price if cfg and cfg.sell_input_price > 0 else model_data["input_price"],
                "output_price": cfg.sell_output_price if cfg and cfg.sell_output_price > 0 else model_data["output_price"],
                "unit": "per 1M tokens",
            })
    return {"data": result}
