const String architectureFullDetail = '''

# 架构设计

## 总体架构

API Token中转平台采用**六层分层架构**，从外到内依次为：
```
┌──────────────────────────────────────────────┐
│             接入层 (Nginx)                    │
│        TLS终止 · 静态资源 · 基础限流            │
├──────────────────────────────────────────────┤
│             认证层 (Middleware)               │
│        API Key验证 · JWT解析 · 用户注入          │
├──────────────────────────────────────────────┤
│             限流层 (Rate Limiter)             │
│         令牌桶算法 · 配额检查 · 成本控制          │
├──────────────────────────────────────────────┤
│             路由层 (Relay Service)            │
│        厂商识别 · 适配器选择 · 请求编排           │
├──────────────────────────────────────────────┤
│             适配器层 (Vendor Adapter)          │
│      OpenAI Adapter  │ Anthropic Adapter    │
├──────────────────────────────────────────────┤
│             厂商层 (Vendor API)               │
│        OpenAI API   │  Anthropic API        │
└──────────────────────────────────────────────┘
```

## 请求处理完整链路

一次API调用的完整处理流程：

```
Client → Nginx → Uvicorn → FastAPI App
  → CORS Middleware
  → Logging Middleware
  → RateLimit Middleware
  → Dependencies (API Key验证 → User注入)
  → Router (/v1/chat/completions)
  → RelayService
      ├─ 令牌桶检查 (Rate Limiter)
      ├─ 配额检查 (Usage Service)
      ├─ 厂商识别 (Adapter Factory)
      ├─ 密钥解密 (Fernet)
      ├─ 适配器调用
      └─ 日志写入 (RequestLog)
  → Response (统一JSON格式)
```

## 各层详细设计

### 1. 接入层 — Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name api.your-domain.com;

    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/privkey.pem;

    # IP级别基础限流
    limit_req_zone \$binary_remote_addr zone=api_limit:10m rate=10r/s;

    location / {
        limit_req zone=api_limit burst=20 nodelay;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
    }
}
```

### 2. 认证层 — FastAPI Dependencies

认证通过FastAPI的依赖注入系统实现，核心代码：
```python
# dependencies.py
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer

security_scheme = HTTPBearer(auto_error=False)

def get_platform_api_key(
    credentials = Depends(security_scheme),
    db = Depends(get_db),
) -> User:
    if credentials is None:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    token = credentials.credentials
    if not token.startswith("atp_"):
        raise HTTPException(status_code=401, detail="Invalid API key format")
    user = verify_api_key(db, token)
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid or inactive API key")
    return user
```

### 3. 路由层 — Relay Service

路由层的核心职责是**编排**而非执行：
```python
async def execute_relay(db, request, user) -> RelayResponse:
    # 1. 识别厂商（自动检测 / 手动指定）
    if request.vendor:
        adapter = get_adapter(request.vendor)
    else:
        adapter, internal_model = detect_vendor(request.model)

    # 2. 获取和解密厂商密钥
    vendor_key = db.query(VendorKey).filter(
        VendorKey.vendor_name == adapter.vendor_name
    ).first()
    raw_key = decrypt_vendor_key(vendor_key.encrypted_key)

    # 3. 调用适配器
    response = await adapter.chat_completion(request, raw_key)

    # 4. 记录审计日志
    log = RequestLog(user_id=user.id, vendor=adapter.vendor_name, ...)
    db.add(log)

    return response
```

### 4. 适配器层 — 工厂模式

```python
class BaseVendorAdapter(ABC):
    @property
    @abstractmethod
    def vendor_name(self) -> str: ...

    @abstractmethod
    async def chat_completion(self, request, api_key) -> RelayResponse: ...

    def model_to_vendor(self, model: str) -> str | None:
        # 子类重写此方法实现自动模型识别
        return None

# 工厂注册
_adapters: dict[str, BaseVendorAdapter] = {}

def register_adapter(adapter_cls):
    instance = adapter_cls()
    _adapters[instance.vendor_name] = instance

# 自动注册
register_adapter(OpenAIAdapter)
register_adapter(AnthropicAdapter)
```

## 数据库设计
### ER图（简化）

```
users                    platform_api_keys
┌──────────────┐       ┌──────────────────┐
│ id (PK)      │◄──────│ user_id (FK)      │
│ username     │       │ key_hash          │
│ hashed_pwd   │       │ key_prefix (idx)  │
│ is_active    │       │ name              │
│ created_at   │       │ is_active         │
└──────────────┘       └──────────────────┘

vendor_keys             request_logs
┌──────────────┐       ┌──────────────────┐
│ id (PK)      │       │ id (PK)          │
│ vendor_name  │       │ user_id (FK)     │
│ encrypted_key│       │ vendor           │
│ base_url     │       │ model            │
│ is_active    │       │ tokens_used      │
└──────────────┘       │ cost_estimate    │
                       │ latency_ms       │
usage_quotas           │ created_at       │
┌──────────────┐       └──────────────────┘
│ id (PK)      │
│ user_id (FK) │
│ vendor       │
│ max_tokens   │
│ used_tokens  │
│ reset_at     │
└──────────────┘
```

## 项目目录结构

```
api_token_platform_backend/
├── app/
│   ├── main.py              # FastAPI应用入口
│   ├── config.py            # 配置管理（环境变量）
│   ├── database.py          # 数据库引擎和会话
│   ├── dependencies.py      # 依赖注入
│   ├── models/              # ORM模型
│   ├── schemas/             # Pydantic请求/响应模型
│   ├── routers/             # API路由
│   ├── services/            # 业务逻辑
│   ├── adapters/            # 厂商适配器
│   └── middleware/          # 中间件
├── tests/                   # 测试
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

## 技术选型理由

| 选择 | 理由 |
|------|------|
| FastAPI | 异步高性能、自动OpenAPI文档、类型安全、依赖注入 |
| SQLAlchemy | ORM成熟稳定、支持多数据库、迁移工具Alembic |
| SQLite (默认) | 零配置、文件级部署、适合开发和轻量使用 |
| PostgreSQL (生产) | 高并发、丰富功能、适合多用户生产环境 |
| Fernet加密 | Python内置支持、工业级加密标准、简单易用 |
| bcrypt | 防止彩虹表攻击、计算成本可调、业界标准 |
| Docker | 环境一致性、快速部署、资源隔离 |

## 架构扩展性
1. **新增厂商适配器**：只需在 `adapters/` 下添加文件 + 一行注册
2. **切换数据库**：修改 `DATABASE_URL` 环境变量即可
3. **分布式限流**：设置 `REDIS_URL` 切换到Redis后端
4. **水平扩展**：无状态应用 + Redis + PostgreSQL 可支持水平扩展
5. **消息队列**：可将中继调用改为异步任务，通过消息队列处理

''';
