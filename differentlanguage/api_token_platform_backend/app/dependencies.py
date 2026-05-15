"""
FastAPI 依赖注入模块

定义全局可复用的认证依赖函数，通过 FastAPI 的 Depends 机制注入到路由处理函数中。

两种认证方式：
1. 平台 API Key（atp_ 前缀）— 用于 AI 中继调用
2. JWT Token — 用于用户管理操作（暂通过 API Key 间接实现）
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from app.config import settings
from app.database import get_db

# HTTP Bearer 认证方案（auto_error=False 允许无认证头的请求到达处理器）
security_scheme = HTTPBearer(auto_error=False)


def get_platform_api_key(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: Session = Depends(get_db),
) -> str:
    """
    验证平台 API Key 并返回对应的用户对象

    验证流程：
    1. 检查 Authorization 头是否存在
    2. 验证 Token 格式（必须以 atp_ 开头）
    3. 提取 key_prefix（前12字符）快速缩小数据库查找范围
    4. bcrypt 逐条验证候选 Key 的哈希值

    用于保护 /v1/chat/completions 等 AI 中继端点。
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
        )
    token = credentials.credentials
    if not token.startswith("atp_"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key format",
        )
    # 延迟导入避免循环依赖
    from app.services.auth_service import verify_api_key
    user = verify_api_key(db, token)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or inactive API key",
        )
    return user


def create_access_token(data: dict) -> str:
    """
    生成 JWT 访问令牌

    参数:
        data: 要编码到 JWT 中的数据字典（如 {"sub": "username"}）

    返回:
        签名的 JWT 字符串，过期时间由 settings.access_token_expire_minutes 控制
    """
    from datetime import datetime, timedelta, timezone
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: Session = Depends(get_db),
):
    """
    验证 JWT Bearer Token 并返回当前用户

    用于保护 /auth/api-keys 等用户管理端点。
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
        )
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        user_id: str | None = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload",
            )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
    from app.models.user import User
    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )
    return user


def get_current_admin(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: Session = Depends(get_db),
):
    """
    验证 JWT 并检查管理员角色 — 用于保护 /admin/* 端点

    admin 和 super_admin 角色均可通过此依赖。
    super_admin 拥有全部权限；admin 只能进行用户管理操作。
    """
    user = get_current_user(credentials, db)
    if user.role not in ("admin", "super_admin"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return user


def get_current_super_admin(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: Session = Depends(get_db),
):
    """
    验证 JWT 并检查超级管理员角色 — 用于保护敏感管理端点

    只有 role == "super_admin" 的用户才能通过此依赖。
    敏感操作包括：厂商管理、定价策略、营收数据、钱包充值、系统统计。
    """
    user = get_current_user(credentials, db)
    if user.role != "super_admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Super admin access required",
        )
    return user


def get_current_user_or_api_key(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: Session = Depends(get_db),
):
    """
    混合认证：先尝试 JWT，再尝试平台 API Key

    用于 /v1/chat/completions 等端点——同时支持前端（JWT）和外部 API 调用者（atp_ Key）。
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
        )
    token = credentials.credentials

    # 尝试 JWT 验证
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        user_id: str | None = payload.get("sub")
        if user_id is not None:
            from app.models.user import User
            user = db.query(User).filter(User.id == int(user_id)).first()
            if user and user.is_active:
                return user
    except JWTError:
        pass

    # 尝试 API Key 验证（atp_ 前缀）
    if token.startswith("atp_"):
        from app.services.auth_service import verify_api_key
        user = verify_api_key(db, token)
        if user:
            return user

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid credentials",
    )
