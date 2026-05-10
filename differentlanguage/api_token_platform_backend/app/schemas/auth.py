"""
认证相关的 Pydantic 请求/响应模型

定义用户注册、登录、API Key 管理的数据模型。
Pydantic 自动进行类型校验、长度校验和格式校验。
"""

from pydantic import BaseModel, Field
from datetime import datetime


class UserRegister(BaseModel):
    """用户注册请求"""
    username: str = Field(
        ..., min_length=3, max_length=50, examples=["testuser"]
    )  # 用户名：3~50字符
    password: str = Field(
        ..., min_length=6, max_length=100
    )  # 密码：6~100字符


class UserLogin(BaseModel):
    """用户登录请求"""
    username: str
    password: str


class TokenResponse(BaseModel):
    """JWT 令牌响应"""
    access_token: str
    token_type: str = "bearer"


class ApiKeyCreate(BaseModel):
    """创建 API Key 请求"""
    name: str = Field(
        ..., min_length=1, max_length=100, examples=["我的开发Key"]
    )  # Key 的别名


class ApiKeyResponse(BaseModel):
    """API Key 信息响应（不包含完整Key）"""
    id: int
    name: str           # Key 别名
    key_prefix: str     # Key 前缀（atp_ + 8位hex）
    is_active: bool     # 是否激活
    created_at: datetime
    last_used_at: datetime | None = None

    class Config:
        from_attributes = True  # 允许从 ORM 对象创建


class ApiKeyCreatedResponse(ApiKeyResponse):
    """创建 API Key 的响应（仅此一次包含完整Key！）"""
    raw_key: str  # ⚠️ 完整的 API Key 明文，仅在创建时返回一次
