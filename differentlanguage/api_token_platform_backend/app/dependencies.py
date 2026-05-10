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
