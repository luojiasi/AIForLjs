"""
管理路由模块 — /admin

提供平台管理员对厂商密钥的管理端点：
- GET  /admin/vendors                  — 查看所有厂商状态
- POST /admin/vendors/{name}/key       — 设置/更新厂商 API Key
- GET  /admin/vendors/supported        — 查看支持的厂商列表
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.vendor_key import VendorKey
from app.services.relay_service import encrypt_vendor_key
from app.adapters.factory import get_all_adapters

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/vendors")
def list_vendors(db: Session = Depends(get_db)):
    """
    列出所有已注册的厂商及其密钥配置状态

    返回每个厂商的:
        - vendor_name: 厂商标识名
        - display_name: 显示名称
        - has_key: 是否已配置 API Key
        - is_active: 密钥是否激活
        - base_url: 自定义 API 端点（如有）
    """
    所有适配器 = get_all_adapters()
    已存储密钥 = {v.vendor_name: v for v in db.query(VendorKey).all()}

    结果列表 = []
    for 厂商名, 适配器 in 所有适配器.items():
        厂商密钥 = 已存储密钥.get(厂商名)
        结果列表.append({
            "vendor_name": 厂商名,
            "display_name": 适配器.display_name,
            "has_key": 厂商密钥 is not None and bool(厂商密钥.encrypted_key),
            "is_active": 厂商密钥.is_active if 厂商密钥 else False,
            "base_url": 厂商密钥.base_url if 厂商密钥 else None,
        })
    return 结果列表


@router.post("/vendors/{vendor_name}/key")
def set_vendor_key(
    vendor_name: str,
    api_key: str,
    base_url: str | None = None,
    db: Session = Depends(get_db),
):
    """
    设置或更新指定厂商的 API Key

    路径参数:
        vendor_name: 厂商标识名（如 "openai", "anthropic"）

    请求体:
        api_key: 厂商的 API Key 明文（将使用 Fernet 加密存储）
        base_url: 可选的自定义 API 端点（如使用代理或私有部署）

    注意: 设置后会自动激活该厂商的密钥
    """
    # 验证厂商是否已注册适配器
    所有适配器 = get_all_adapters()
    适配器 = 所有适配器.get(vendor_name)
    if 适配器 is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unknown vendor: {vendor_name}"
        )

    # Fernet 加密存储厂商密钥
    加密后密钥 = encrypt_vendor_key(api_key)

    # 更新已有记录或创建新记录
    厂商密钥记录 = db.query(VendorKey).filter(
        VendorKey.vendor_name == vendor_name
    ).first()
    if 厂商密钥记录:
        厂商密钥记录.encrypted_key = 加密后密钥
        厂商密钥记录.base_url = base_url
        厂商密钥记录.is_active = True
    else:
        厂商密钥记录 = VendorKey(
            vendor_name=vendor_name,
            display_name=适配器.display_name,
            encrypted_key=加密后密钥,
            base_url=base_url,
        )
        db.add(厂商密钥记录)
    db.commit()
    return {
        "message": f"Vendor key for '{vendor_name}' updated",
        "vendor_name": vendor_name
    }


@router.get("/vendors/supported")
def supported_vendors():
    """
    返回所有已注册支持的厂商列表

    这些厂商的适配器已在 factory.py 中注册，可以通过 /admin/vendors/{name}/key 配置密钥。
    """
    所有适配器 = get_all_adapters()
    return [
        {"vendor_name": 厂商名, "display_name": 适配器.display_name}
        for 厂商名, 适配器 in 所有适配器.items()
    ]
