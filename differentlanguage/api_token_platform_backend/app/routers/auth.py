"""
认证路由模块 — /auth

提供用户认证和 API Key 管理的 REST API 端点：
- POST /auth/register  — 用户注册
- POST /auth/login     — 用户登录（返回JWT）
- POST /auth/api-keys  — 创建平台 API Key（需认证）
- GET  /auth/api-keys  — 列出所有 API Key
- DELETE /auth/api-keys/{key_id} — 撤销指定 API Key
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.dependencies import create_access_token, get_platform_api_key, get_current_user
from app.schemas.auth import (
    UserRegister, UserLogin, TokenResponse, UserResponse,
    ApiKeyCreate, ApiKeyResponse, ApiKeyCreatedResponse,
)
from app.services import auth_service
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])


def _user_to_response(user: User) -> UserResponse:
    """将 ORM User 对象转换为 UserResponse"""
    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        role=user.role or "user",
        is_active=user.is_active,
        is_approved=user.is_approved if user.is_approved is not None else False,
        quota_total=user.quota_total or 1_000_000,
        quota_used=user.quota_used or 0,
        quota_reset_at=user.quota_reset_at,
        created_at=user.created_at,
    )


@router.post("/register", response_model=TokenResponse)
def register(req: UserRegister, db: Session = Depends(get_db)):
    """用户注册（注册即登录，返回 JWT + 用户信息）"""
    已存在用户 = db.query(User).filter(User.username == req.username).first()
    if 已存在用户:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username already exists"
        )
    user = auth_service.create_user(db, req.username, req.password, req.email)
    token = create_access_token({"sub": str(user.id), "username": user.username})
    return TokenResponse(access_token=token, user=_user_to_response(user))


@router.post("/login", response_model=TokenResponse)
def login(req: UserLogin, db: Session = Depends(get_db)):
    """用户登录（返回 JWT + 用户信息）"""
    user = auth_service.authenticate_user(db, req.username, req.password)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    if not user.is_approved:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account pending approval. Please wait for admin approval."
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account has been disabled"
        )
    token = create_access_token({"sub": str(user.id), "username": user.username})
    return TokenResponse(access_token=token, user=_user_to_response(user))


# 注意：此端点使用 JWT 认证（get_current_user），非平台 API Key
@router.post("/api-keys", response_model=ApiKeyCreatedResponse)
def create_api_key(
    req: ApiKeyCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    创建新的平台 API Key（需认证）

    返回的 raw_key 是完整的 API Key 明文（atp_ + 64位hex），
    ⚠️ 仅在此时返回一次，请务必妥善保存！之后无法从数据库恢复。

    请求参数:
        name: 为此 Key 取一个别名（如"开发环境"、"生产环境"）
    """
    api_key, raw_key = auth_service.create_api_key(db, user, req.name)
    return ApiKeyCreatedResponse(
        id=api_key.id,
        name=api_key.name,
        key_prefix=api_key.key_prefix,   # 只返回前缀，完整Key在 raw_key 中
        is_active=api_key.is_active,
        created_at=api_key.created_at,
        last_used_at=api_key.last_used_at,
        raw_key=raw_key,                 # ⚠️ 唯一一次返回完整Key
    )


@router.get("/api-keys", response_model=list[ApiKeyResponse])
def list_api_keys(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    列出当前用户的所有 API Key（不返回完整Key）

    返回每个 Key 的基本信息：ID、名称、前缀、状态、创建/最后使用时间
    """
    keys = auth_service.list_api_keys(db, user)
    return [ApiKeyResponse(
        id=k.id, name=k.name, key_prefix=k.key_prefix,
        is_active=k.is_active, created_at=k.created_at, last_used_at=k.last_used_at,
    ) for k in keys]


@router.delete("/api-keys/{key_id}")
def revoke_api_key(
    key_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    撤销（软删除）指定的 API Key

    Key 被撤销后立即失效，但记录保留在数据库中用于审计。

    错误: 404 — Key 不存在或不属于当前用户
    """
    ok = auth_service.revoke_api_key(db, user, key_id)
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="API key not found"
        )
    return {"message": "API key revoked"}
