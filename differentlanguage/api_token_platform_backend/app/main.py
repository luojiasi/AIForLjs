"""
API Token 中转平台 — FastAPI 应用入口

本模块是整个应用的启动入口，负责：
1. 创建 FastAPI 应用实例
2. 配置 CORS 跨域中间件
3. 注册各功能模块的路由（认证、中继、用量、管理）
4. 定义应用生命周期（启动时初始化数据库）
5. 提供健康检查端点
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import init_db, SessionLocal
from app.routers import auth, relay, usage, admin


def _seed_admin():
    """
    启动时确保管理员账号存在，不存在则自动创建。

    管理员用户名固定为 "admin"，密码通过 ADMIN_PASSWORD 环境变量配置，
    未设置则使用默认值（生产环境务必修改！）。
    """
    db = SessionLocal()
    try:
        from app.models.user import User
        from app.services.auth_service import hash_password
        existing = db.query(User).filter(User.username == "admin").first()
        if existing is None:
            admin_user = User(
                username="admin",
                hashed_password=hash_password(settings.admin_password),
                role="super_admin",
                is_approved=True,
            )
            db.add(admin_user)
            db.commit()
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理：启动时自动初始化数据库表结构并创建管理员"""
    init_db()
    _seed_admin()
    yield


def create_app() -> FastAPI:
    """创建并配置 FastAPI 应用实例"""
    app = FastAPI(
        title=settings.app_name,
        version="1.0.0",
        description="统一 API Token 中转平台 — 多厂商 AI API 网关",
        docs_url="/docs",      # Swagger UI 交互式文档
        redoc_url="/redoc",    # ReDoc 文档
        lifespan=lifespan,
    )

    # CORS 跨域配置
    cors_origins = settings.cors_origins.split(",") if settings.cors_origins != "*" else ["*"]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 注册各模块路由
    app.include_router(auth.router)     # 认证模块：注册/登录/API Key 管理
    app.include_router(relay.router)    # 中继模块：AI 调用的核心转发端点
    app.include_router(usage.router)    # 用量模块：统计和配额查询
    app.include_router(admin.router)    # 管理模块：厂商密钥管理

    @app.get("/health")
    def health_check():
        return {"status": "ok", "service": settings.app_name}

    @app.get("/")
    def root_info():
        return {"service": settings.app_name, "version": "1.0.0"}

    return app


# 模块级应用实例，供 uvicorn 直接加载
# 启动命令: uvicorn app.main:app --host 0.0.0.0 --port 8000
app = create_app()
