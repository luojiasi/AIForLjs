"""
核心中继服务模块

这是整个 API Token 中转平台的"心脏"——execute_relay() 函数编排了
一次 AI 请求转发的完整流程：

1. 厂商识别 → 2. 获取厂商密钥 → 3. 调用适配器 → 4. 估算费用 → 5. 记录审计日志

同时提供厂商密钥的 Fernet 加密/解密功能。
Fernet = AES-128-CBC 加密 + HMAC-SHA256 签名，保证机密性和完整性。
"""

import logging
import base64
import hashlib
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet
from app.config import settings
from app.schemas.relay import RelayRequest, RelayResponse
from app.adapters.factory import get_adapter, detect_vendor
from app.models.request_log import RequestLog
from app.models.pricing import PricingConfig
from app.models.wallet import UserWallet, WalletTransaction

logger = logging.getLogger(__name__)


def _派生Fernet密钥() -> Fernet:
    """
    从平台 SECRET_KEY 派生 Fernet 对称加密密钥

    派生路径: SECRET_KEY → SHA256哈希(32字节) → Base64 URL-safe编码 → Fernet密钥
    这样做的优势：只需要保护一个 SECRET_KEY，无需额外存储加密密钥
    """
    密钥字节 = hashlib.sha256(settings.secret_key.encode()).digest()
    return Fernet(base64.urlsafe_b64encode(密钥字节))


_fernet = _派生Fernet密钥()


def 加密厂商密钥(原始密钥: str) -> str:
    """
    使用 Fernet 对称加密厂商 API Key

    加密后的密文存储在数据库 vendor_keys.encrypted_key 字段中。
    加密算法 = AES-128-CBC + HMAC-SHA256 签名
    """
    return _fernet.encrypt(原始密钥.encode()).decode()


encrypt_vendor_key = 加密厂商密钥


def 解密厂商密钥(已加密密钥: str) -> str:
    """
    解密厂商 API Key，仅在内存中使用，调用完成后立即丢弃

    解密过程会验证 HMAC 签名（防篡改）和时间戳（防重放）。
    """
    return _fernet.decrypt(已加密密钥.encode()).decode()


decrypt_vendor_key = 解密厂商密钥


async def 执行中继(
    db: Session,
    request: RelayRequest,
    user,
) -> RelayResponse:
    """
    核心中继编排函数 — 一次 AI 请求转发的完整流程

    处理步骤（共5步）：
    1. 厂商识别：根据 model 字段自动检测或使用 vendor 参数手动指定
    2. 获取密钥：从数据库取出加密的厂商 API Key，Fernet 解密
    3. 调用适配器：通过适配器将请求转发到对应的 AI 厂商
    4. 估算费用：根据 Token 用量和定价表计算本次调用成本
    5. 记录日志：将请求详情写入 request_logs 审计表

    异常处理：
    - 无法识别厂商 → ValueError
    - 厂商未配置密钥 → ValueError
    - 厂商 API 调用失败 → 记录错误日志后重新抛出
    """
    # ===== 第1步：确定目标厂商 =====
    厂商名称 = request.vendor
    adapter = None
    内部模型名 = request.model

    if 厂商名称:
        # 请求中显式指定了厂商
        adapter = get_adapter(厂商名称)
        if adapter is None:
            raise ValueError(f"Unknown vendor: {厂商名称}")
    else:
        # 根据模型名自动检测厂商
        adapter, 检测到的模型 = detect_vendor(request.model)
        if adapter and 检测到的模型:
            内部模型名 = 检测到的模型
        else:
            raise ValueError(
                f"Cannot detect vendor for model: {request.model}. "
                f"Please specify 'vendor' field."
            )

    # ===== 第2步：获取并解密厂商 API Key =====
    from app.models.vendor_key import VendorKey
    厂商密钥记录 = db.query(VendorKey).filter(
        VendorKey.vendor_name == adapter.vendor_name,
        VendorKey.is_active == True,
    ).first()
    if 厂商密钥记录 is None:
        raise ValueError(
            f"No active API key configured for vendor: {adapter.vendor_name}"
        )

    厂商原始密钥 = 解密厂商密钥(厂商密钥记录.encrypted_key)

    # ===== 第3步：通过适配器调用厂商 API =====
    try:
        响应 = await adapter.chat_completion(request, 厂商原始密钥)
    except Exception as 错误:
        logger.error(f"Vendor API error [{adapter.vendor_name}]: {错误}")
        # 记录失败日志到审计表
        失败日志 = RequestLog(
            user_id=user.id,
            vendor=adapter.vendor_name,
            endpoint="/v1/chat/completions",
            model=request.model,
            status_code=500,
            latency_ms=0,
            error_message=str(错误)[:500],       # 截断过长的错误信息
        )
        db.add(失败日志)
        db.commit()
        raise

    # ===== 第4步：估算费用（优先使用数据库定价配置） =====
    定价配置 = db.query(PricingConfig).filter(
        PricingConfig.model_id == request.model,
        PricingConfig.is_active == True,
    ).first()

    if 定价配置 and 定价配置.sell_input_price > 0:
        # 使用管理员配置的售价
        费用估算 = round(
            (响应.usage.prompt_tokens / 1_000_000) * 定价配置.sell_input_price +
            (响应.usage.completion_tokens / 1_000_000) * 定价配置.sell_output_price,
            6,
        )
    else:
        # 使用适配器内置的厂商成本价估算
        费用估算 = adapter.estimate_cost(响应)

    响应.cost = 费用估算

    # ===== 第5步：从钱包扣款 =====
    if 费用估算 > 0:
        钱包 = db.query(UserWallet).filter(UserWallet.user_id == user.id).first()
        if 钱包 and 钱包.balance >= 费用估算:
            钱包.balance -= 费用估算
            钱包.total_spent += 费用估算
            db.add(WalletTransaction(
                user_id=user.id,
                amount=-费用估算,
                type="consume",
                description=f"API Call: {request.model}",
                balance_after=钱包.balance,
            ))

    # ===== 第6步：记录成功审计日志 =====
    成功日志 = RequestLog(
        user_id=user.id,
        vendor=adapter.vendor_name,
        endpoint="/v1/chat/completions",
        model=request.model,
        status_code=200,
        latency_ms=响应.latency_ms,
        tokens_used=响应.usage.total_tokens,
        cost_estimate=费用估算,
    )
    db.add(成功日志)
    db.commit()

    return 响应


execute_relay = 执行中继
