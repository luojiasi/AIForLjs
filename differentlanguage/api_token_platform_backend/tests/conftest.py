import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base, get_db
from app.main import create_app
from app.config import settings

# 测试用内存数据库
TEST_DATABASE_URL = "sqlite:///./data/test_relay_platform.db"

engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(autouse=True)
def setup_db():
    import os
    os.makedirs("data", exist_ok=True)
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def client():
    app = create_app()
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c


@pytest.fixture()
def auth_headers(client):
    """注册用户并返回 (headers, 原始 API key)"""
    client.post("/auth/register", json={"username": "testuser", "password": "testpass123"})
    # 先登录拿 JWT
    login_resp = client.post("/auth/login", json={"username": "testuser", "password": "testpass123"})
    token = login_resp.json()["access_token"]
    # 创建 API Key
    key_resp = client.post(
        "/auth/api-keys",
        json={"name": "test key"},
        headers={"Authorization": f"Bearer {token}"},
    )
    raw_key = key_resp.json()["raw_key"]
    return {"Authorization": f"Bearer {raw_key}"}, raw_key
