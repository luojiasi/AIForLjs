"""
数据库引擎与会话管理模块

使用 SQLAlchemy 2.0 管理数据库连接。默认使用 SQLite（文件数据库，零配置），
通过在 .env 中修改 DATABASE_URL 可切换到 PostgreSQL。

SQLite 优化：
- WAL 模式（Write-Ahead Logging）：提升并发读写性能
- 外键约束强制启用
- check_same_thread=False：允许 FastAPI 多线程访问
"""

from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base
from app.config import settings

# 创建数据库引擎
# SQLite 需要 check_same_thread=False 才能在 FastAPI 的异步环境中使用
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if "sqlite" in settings.database_url else {},
    echo=settings.debug,  # 调试模式下打印 SQL 语句
)


# SQLite 连接事件监听器：每次建立新连接时自动设置 PRAGMA 优化
@event.listens_for(engine, "connect")
def _set_sqlite_pragma(dbapi_connection, connection_record):
    """为 SQLite 连接启用 WAL 日志模式和外键约束"""
    if "sqlite" in settings.database_url:
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA journal_mode=WAL")       # WAL 模式：提升并发写入性能
        cursor.execute("PRAGMA foreign_keys=ON")         # 强制启用外键约束
        cursor.close()


# 数据库会话工厂 — 每次请求创建一个新的会话
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# SQLAlchemy 声明式基类 — 所有 ORM 模型继承自此类
Base = declarative_base()


def init_db():
    """初始化数据库：创建数据目录和所有表结构（仅在应用启动时调用一次）"""
    import os
    # SQLite 需要确保数据目录存在
    if "sqlite" in settings.database_url:
        db_path = settings.database_url.replace("sqlite:///", "")
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
    # 根据 ORM 模型定义自动创建所有表（已存在的表不会重复创建）
    Base.metadata.create_all(bind=engine)


def get_db():
    """
    数据库会话依赖注入生成器

    用作 FastAPI 的 Depends 参数，每次请求创建一个新会话，请求结束后自动关闭。
    用法: db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
