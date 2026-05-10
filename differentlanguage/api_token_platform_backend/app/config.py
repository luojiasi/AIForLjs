"""
应用配置管理模块

使用 pydantic-settings 从 .env 文件和系统环境变量中加载所有配置项。
配置项按功能分为：应用基础、安全认证、数据库、Redis、服务、限流、厂商密钥、超时控制。

生产环境注意事项：
- secret_key 必须使用 openssl rand -hex 32 生成
- debug 必须设置为 False
- 厂商 API Key 建议通过环境变量注入，不要写在 .env 文件中提交到版本控制
"""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """应用全局配置 — 所有字段可通过环境变量或 .env 文件覆盖"""

    # ===== 应用基础配置 =====
    app_name: str = "API Token Relay Platform"
    debug: bool = True                                # 开发模式；生产环境设为 False
    log_level: str = "INFO"                           # 日志级别：DEBUG / INFO / WARNING / ERROR

    # ===== 安全认证配置 =====
    secret_key: str = "dev-secret-change-in-production"  # JWT 签名密钥 + Fernet 加密派生源
    algorithm: str = "HS256"                              # JWT 签名算法
    access_token_expire_minutes: int = 1440               # JWT 过期时间（默认24小时）

    # ===== 数据库配置 =====
    # SQLite 默认（零配置）；生产环境改为 PostgreSQL 连接字符串
    database_url: str = "sqlite:///./data/relay_platform.db"

    # ===== Redis 配置（可选）=====
    # 设置后用于分布式限流；不设置则使用内存限流器
    redis_url: Optional[str] = None

    # ===== 服务绑定配置 =====
    host: str = "0.0.0.0"    # 监听地址；0.0.0.0 表示接受所有网络接口
    port: int = 8000          # 监听端口

    # ===== 限流与配额配置 =====
    rate_limit_requests_per_minute: int = 60          # 每用户每分钟最大请求数
    rate_limit_tokens_per_month: int = 1_000_000      # 每用户每月最大 Token 消耗量

    # ===== 厂商 API Key（初始种子值）=====
    # 这些是启动时的默认值，运行时可通过 Admin API 动态更新
    openai_api_key: Optional[str] = None
    anthropic_api_key: Optional[str] = None

    # ===== 请求超时控制 =====
    vendor_request_timeout: int = 120   # 调用厂商 API 的超时秒数（AI 响应可能较慢）

    # pydantic-settings 配置：从 .env 文件加载（UTF-8 编码）
    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


# 全局单例配置对象
settings = Settings()
