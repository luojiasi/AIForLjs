"""
管理路由模块 — /admin

提供平台管理员的核心管理功能：
- 系统概览统计
- 厂商密钥管理（CRUD）
- 用户管理（列表、创建、编辑、禁用、配额设置）
- 请求日志全局查看
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from app.database import get_db
from app.dependencies import get_current_admin, get_current_super_admin
from app.models.user import User
from app.models.vendor_key import VendorKey
from app.models.api_key import PlatformApiKey
from app.models.request_log import RequestLog
from app.models.pricing import PricingConfig
from app.models.wallet import UserWallet, WalletTransaction
from app.services.relay_service import encrypt_vendor_key, decrypt_vendor_key
from app.services.auth_service import hash_password
from app.adapters.factory import get_all_adapters
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel, Field

router = APIRouter(prefix="/admin", tags=["Admin"])


# ── Request/Response Schemas ──────────────────────────────────────────────

class SystemStatsResponse(BaseModel):
    total_users: int
    total_api_keys: int
    total_vendors: int
    total_requests: int
    total_tokens: int
    total_cost: float
    active_users_24h: int
    requests_24h: int
    errors_24h: int
    avg_latency_ms: float


class VendorInfo(BaseModel):
    id: int
    vendor_name: str
    display_name: str
    has_key: bool
    is_active: bool
    base_url: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


class VendorKeySet(BaseModel):
    api_key: str = Field(..., min_length=1)
    base_url: str | None = None


class VendorKeyUpdate(BaseModel):
    api_key: str | None = None
    base_url: str | None = None
    is_active: bool | None = None


class UserInfo(BaseModel):
    id: int
    username: str
    email: str | None = None
    role: str
    is_active: bool
    is_approved: bool = False
    quota_total: int
    quota_used: int
    created_at: datetime


class UserCreateRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=6, max_length=100)
    email: str | None = None
    role: str = "user"
    is_approved: bool = False
    quota_total: int = 1_000_000


class UserUpdateRequest(BaseModel):
    email: str | None = None
    role: str | None = None
    is_active: bool | None = None
    is_approved: bool | None = None
    quota_total: int | None = None
    password: str | None = None


class UserListResponse(BaseModel):
    items: list[UserInfo]
    total: int


# ── System Stats ──────────────────────────────────────────────────────────

@router.get("/stats", response_model=SystemStatsResponse)
def system_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    now = datetime.now(timezone.utc)
    last_24h = now - timedelta(hours=24)

    total_users = db.query(User).count()
    total_api_keys = db.query(PlatformApiKey).filter(PlatformApiKey.is_active == True).count()
    total_vendors = db.query(VendorKey).count()

    all_logs = db.query(RequestLog).all()
    total_requests = len(all_logs)
    total_tokens = sum(r.tokens_used or 0 for r in all_logs)
    total_cost = sum(r.cost_estimate or 0.0 for r in all_logs)

    recent_logs = db.query(RequestLog).filter(RequestLog.created_at >= last_24h).all()
    errors_24h = sum(1 for r in recent_logs if r.status_code and r.status_code >= 400)

    active_user_ids = {r.user_id for r in recent_logs}
    active_users_24h = len(active_user_ids)
    requests_24h = len(recent_logs)

    latencies = [r.latency_ms for r in recent_logs if r.latency_ms is not None and r.latency_ms > 0]
    avg_latency_ms = round(sum(latencies) / len(latencies), 1) if latencies else 0.0

    return SystemStatsResponse(
        total_users=total_users,
        total_api_keys=total_api_keys,
        total_vendors=total_vendors,
        total_requests=total_requests,
        total_tokens=total_tokens,
        total_cost=round(total_cost, 6),
        active_users_24h=active_users_24h,
        requests_24h=requests_24h,
        errors_24h=errors_24h,
        avg_latency_ms=avg_latency_ms,
    )


# ── Vendor Management ─────────────────────────────────────────────────────

@router.get("/vendors", response_model=list[VendorInfo])
def list_vendors(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    adapters = get_all_adapters()
    stored = {v.vendor_name: v for v in db.query(VendorKey).all()}

    result = []
    for name, adapter in adapters.items():
        vk = stored.get(name)
        result.append(VendorInfo(
            id=vk.id if vk else 0,
            vendor_name=name,
            display_name=adapter.display_name,
            has_key=vk is not None and bool(vk.encrypted_key),
            is_active=vk.is_active if vk else False,
            base_url=vk.base_url if vk else None,
            created_at=vk.created_at if vk else None,
            updated_at=vk.updated_at if vk else None,
        ))

    # also include vendors that have keys stored but no adapter registered
    for vk in stored.values():
        if vk.vendor_name not in adapters:
            result.append(VendorInfo(
                id=vk.id,
                vendor_name=vk.vendor_name,
                display_name=vk.display_name,
                has_key=bool(vk.encrypted_key),
                is_active=vk.is_active,
                base_url=vk.base_url,
                created_at=vk.created_at,
                updated_at=vk.updated_at,
            ))

    return result


@router.post("/vendors/{vendor_name}/key")
def set_vendor_key(
    vendor_name: str,
    body: VendorKeySet,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    adapters = get_all_adapters()
    adapter = adapters.get(vendor_name)
    if adapter is None:
        raise HTTPException(status_code=404, detail=f"Unknown vendor: {vendor_name}")

    encrypted = encrypt_vendor_key(body.api_key)

    vk = db.query(VendorKey).filter(VendorKey.vendor_name == vendor_name).first()
    if vk:
        vk.encrypted_key = encrypted
        vk.base_url = body.base_url
        vk.is_active = True
        vk.updated_at = datetime.now(timezone.utc)
    else:
        vk = VendorKey(
            vendor_name=vendor_name,
            display_name=adapter.display_name,
            encrypted_key=encrypted,
            base_url=body.base_url,
        )
        db.add(vk)
    db.commit()
    db.refresh(vk)
    return {"message": f"Vendor key for '{vendor_name}' updated", "vendor_name": vendor_name, "id": vk.id}


@router.put("/vendors/{vendor_name}")
def update_vendor(
    vendor_name: str,
    body: VendorKeyUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    vk = db.query(VendorKey).filter(VendorKey.vendor_name == vendor_name).first()
    if vk is None:
        raise HTTPException(status_code=404, detail="Vendor not found")

    if body.api_key is not None:
        vk.encrypted_key = encrypt_vendor_key(body.api_key)
    if body.base_url is not None:
        vk.base_url = body.base_url
    if body.is_active is not None:
        vk.is_active = body.is_active

    vk.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(vk)
    return {"message": f"Vendor '{vendor_name}' updated"}


@router.delete("/vendors/{vendor_name}")
def delete_vendor(
    vendor_name: str,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    vk = db.query(VendorKey).filter(VendorKey.vendor_name == vendor_name).first()
    if vk is None:
        raise HTTPException(status_code=404, detail="Vendor not found")
    db.delete(vk)
    db.commit()
    return {"message": f"Vendor '{vendor_name}' deleted"}


@router.get("/vendors/supported")
def supported_vendors(admin: User = Depends(get_current_super_admin)):
    adapters = get_all_adapters()
    return [
        {"vendor_name": name, "display_name": a.display_name}
        for name, a in adapters.items()
    ]


# ── User Management ───────────────────────────────────────────────────────

def _user_to_info(u: User) -> UserInfo:
    return UserInfo(
        id=u.id,
        username=u.username,
        email=u.email,
        role=u.role or "user",
        is_active=u.is_active,
        is_approved=u.is_approved if u.is_approved is not None else False,
        quota_total=u.quota_total or 1_000_000,
        quota_used=u.quota_used or 0,
        created_at=u.created_at,
    )


@router.get("/users", response_model=UserListResponse)
def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    query = db.query(User)
    total = query.count()
    users = query.order_by(User.created_at.desc()).offset(
        (page - 1) * page_size
    ).limit(page_size).all()
    return UserListResponse(
        items=[_user_to_info(u) for u in users],
        total=total,
    )


@router.post("/users", response_model=UserInfo)
def create_user(
    body: UserCreateRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if body.role == "super_admin" and admin.role != "super_admin":
        raise HTTPException(status_code=403, detail="Only super admin can create super admin users")
    existing = db.query(User).filter(User.username == body.username).first()
    if existing:
        raise HTTPException(status_code=409, detail="Username already exists")
    user = User(
        username=body.username,
        hashed_password=hash_password(body.password),
        email=body.email,
        role=body.role,
        is_approved=body.is_approved,
        quota_total=body.quota_total,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return _user_to_info(user)


@router.get("/users/{user_id}", response_model=UserInfo)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return _user_to_info(user)


@router.put("/users/{user_id}", response_model=UserInfo)
def update_user(
    user_id: int,
    body: UserUpdateRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    # Regular admin cannot modify super_admin users
    if user.role == "super_admin" and admin.role != "super_admin":
        raise HTTPException(status_code=403, detail="Cannot modify super admin user")
    # Only super admin can grant super_admin role
    if body.role == "super_admin" and admin.role != "super_admin":
        raise HTTPException(status_code=403, detail="Only super admin can grant super_admin role")
    # Prevent self-demotion
    if user.id == admin.id and body.role is not None and body.role != "super_admin" and admin.role == "super_admin":
        raise HTTPException(status_code=403, detail="Cannot demote your own super admin role")

    if body.email is not None:
        user.email = body.email
    if body.role is not None:
        user.role = body.role
    if body.is_active is not None:
        user.is_active = body.is_active
    if body.is_approved is not None:
        was_approved = user.is_approved
        user.is_approved = body.is_approved
        if body.is_approved and not was_approved and user.email:
            from app.services.email_service import send_approval_notification
            send_approval_notification(user.email, user.username)
    if body.quota_total is not None:
        user.quota_total = body.quota_total
    if body.password is not None:
        user.hashed_password = hash_password(body.password)

    db.commit()
    db.refresh(user)
    return _user_to_info(user)


@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="Cannot delete yourself")
    if user.role == "super_admin" and admin.role != "super_admin":
        raise HTTPException(status_code=403, detail="Cannot delete super admin user")
    if user.role in ("admin", "super_admin") and admin.role != "super_admin":
        raise HTTPException(status_code=403, detail="Cannot delete admin users")
    db.delete(user)
    db.commit()
    return {"message": f"User '{user.username}' deleted"}


# ── Global Request Logs ───────────────────────────────────────────────────

@router.get("/requests")
def global_request_logs(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user_id: int | None = None,
    vendor: str | None = None,
    status_filter: str | None = Query(None, alias="status"),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    query = db.query(RequestLog)
    if user_id is not None:
        query = query.filter(RequestLog.user_id == user_id)
    if vendor is not None:
        query = query.filter(RequestLog.vendor == vendor)
    if status_filter == "success":
        query = query.filter(RequestLog.status_code.between(200, 299))
    elif status_filter == "error":
        query = query.filter(
            (RequestLog.status_code >= 400) | (RequestLog.status_code == None)
        )

    total = query.count()
    import math
    total_pages = max(1, math.ceil(total / page_size))

    logs = query.order_by(RequestLog.created_at.desc()).offset(
        (page - 1) * page_size
    ).limit(page_size).all()

    return {
        "items": [
            {
                "id": r.id,
                "user_id": r.user_id,
                "model": r.model,
                "vendor": r.vendor,
                "total_tokens": r.tokens_used or 0,
                "cost": round(r.cost_estimate or 0.0, 6),
                "latency_ms": r.latency_ms,
                "status": "success" if (r.status_code and 200 <= r.status_code < 300) else "error",
                "created_at": r.created_at.isoformat() if r.created_at else "",
            }
            for r in logs
        ],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": total_pages,
    }


# ── Pricing Management ────────────────────────────────────────────────────

class PricingItem(BaseModel):
    id: int | None = None
    model_id: str
    model_name: str
    vendor: str
    cost_input_price: float = 0.0
    cost_output_price: float = 0.0
    sell_input_price: float = 0.0
    sell_output_price: float = 0.0
    is_active: bool = True


class PricingBatchUpdate(BaseModel):
    items: list[PricingItem]


@router.get("/pricing", response_model=list[PricingItem])
def list_pricing(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    configs = db.query(PricingConfig).order_by(PricingConfig.vendor, PricingConfig.model_id).all()
    return [
        PricingItem(
            id=c.id,
            model_id=c.model_id,
            model_name=c.model_name,
            vendor=c.vendor,
            cost_input_price=c.cost_input_price,
            cost_output_price=c.cost_output_price,
            sell_input_price=c.sell_input_price,
            sell_output_price=c.sell_output_price,
            is_active=c.is_active,
        )
        for c in configs
    ]


@router.put("/pricing")
def update_pricing(
    body: PricingBatchUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    for item in body.items:
        existing = db.query(PricingConfig).filter(
            PricingConfig.model_id == item.model_id
        ).first()
        if existing:
            existing.cost_input_price = item.cost_input_price
            existing.cost_output_price = item.cost_output_price
            existing.sell_input_price = item.sell_input_price
            existing.sell_output_price = item.sell_output_price
            existing.is_active = item.is_active
        else:
            db.add(PricingConfig(
                model_id=item.model_id,
                model_name=item.model_name,
                vendor=item.vendor,
                cost_input_price=item.cost_input_price,
                cost_output_price=item.cost_output_price,
                sell_input_price=item.sell_input_price,
                sell_output_price=item.sell_output_price,
                is_active=item.is_active,
            ))
    db.commit()
    return {"message": f"Updated {len(body.items)} pricing configs"}


# ── Revenue Stats ─────────────────────────────────────────────────────────

@router.get("/revenue")
def revenue_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    logs = db.query(RequestLog).all()
    total_cost = sum(r.cost_estimate or 0.0 for r in logs)
    total_tokens = sum(r.tokens_used or 0 for r in logs)

    # Estimate revenue using pricing configs
    configs = {c.model_id: c for c in db.query(PricingConfig).all()}
    total_revenue = 0.0
    total_profit = 0.0
    for r in logs:
        cfg = configs.get(r.model or "")
        if cfg and cfg.sell_input_price > 0:
            # Simplified: assume 50/50 split of input/output
            sell_price = (cfg.sell_input_price + cfg.sell_output_price) / 2
            total_revenue += (r.tokens_used or 0) / 1_000_000 * sell_price
            cost_price = (cfg.cost_input_price + cfg.cost_output_price) / 2
            total_profit += (r.tokens_used or 0) / 1_000_000 * (sell_price - cost_price)

    return {
        "total_cost": round(total_cost, 6),
        "total_revenue": round(total_revenue, 6),
        "total_profit": round(total_profit, 6),
        "total_tokens": total_tokens,
        "profit_margin": round((total_profit / total_revenue * 100) if total_revenue > 0 else 0, 1),
    }


# ── Wallet Management ─────────────────────────────────────────────────────

class WalletTopUp(BaseModel):
    amount: float = Field(..., gt=0)
    description: str = "管理员充值"


@router.get("/wallets/{user_id}")
def get_wallet(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    wallet = db.query(UserWallet).filter(UserWallet.user_id == user_id).first()
    if wallet is None:
        # Auto-create wallet if not exists
        wallet = UserWallet(user_id=user_id, balance=0.0)
        db.add(wallet)
        db.commit()
        db.refresh(wallet)

    transactions = db.query(WalletTransaction).filter(
        WalletTransaction.user_id == user_id
    ).order_by(WalletTransaction.created_at.desc()).limit(50).all()

    return {
        "user_id": user_id,
        "balance": wallet.balance,
        "total_charged": wallet.total_charged,
        "total_spent": wallet.total_spent,
        "transactions": [
            {
                "id": t.id,
                "amount": t.amount,
                "type": t.type,
                "description": t.description,
                "balance_after": t.balance_after,
                "created_at": t.created_at.isoformat() if t.created_at else "",
            }
            for t in transactions
        ],
    }


@router.post("/wallets/{user_id}/topup")
def topup_wallet(
    user_id: int,
    body: WalletTopUp,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_super_admin),
):
    wallet = db.query(UserWallet).filter(UserWallet.user_id == user_id).first()
    if wallet is None:
        wallet = UserWallet(user_id=user_id, balance=0.0)
        db.add(wallet)
        db.flush()

    wallet.balance += body.amount
    wallet.total_charged += body.amount

    txn = WalletTransaction(
        user_id=user_id,
        amount=body.amount,
        type="topup",
        description=body.description,
        balance_after=wallet.balance,
    )
    db.add(txn)
    db.commit()
    db.refresh(wallet)

    return {"message": f"成功充值 ${body.amount:.2f}", "balance": wallet.balance}
