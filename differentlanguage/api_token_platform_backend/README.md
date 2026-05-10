# API Token Relay Platform

统一 API Token 中转平台 — 多厂商 AI API 网关。

## 功能

- **统一入口**：一个 API Key 访问多个 AI 厂商（OpenAI、Anthropic Claude，可扩展）
- **自动路由**：根据 `model` 字段自动识别目标厂商
- **Token 管理**：平台 API Key 生成/撤销，厂商密钥加密存储
- **限流配额**：令牌桶限流 + 月配额管理
- **用量统计**：请求日志、Token 消耗、费用估算
- **安全设计**：bcrypt 哈希 + Fernet 加密 + 审计日志

## 快速开始

```bash
# 1. 配置环境变量
cp .env.example .env
# 编辑 .env 填入 SECRET_KEY 和厂商 API Keys

# 2. 启动
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# 3. 访问 Swagger UI
open http://localhost:8000/docs
```

## Docker

```bash
docker-compose up -d
```

## 使用流程

```bash
# 1. 注册账号
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "dev", "password": "secret123"}'

# 2. 登录获取 JWT
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "dev", "password": "secret123"}'

# 3. 创建平台 API Key（用 JWT 认证）
curl -X POST http://localhost:8000/auth/api-keys \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "my-app-key"}'
# 返回 raw_key: atp_xxxxxxxx... （仅此一次可见，请保存好）

# 4. 配置厂商密钥（管理员操作）
curl -X POST http://localhost:8000/admin/vendors/openai/key \
  -H "Content-Type: application/json" \
  -d '{"api_key": "sk-your-openai-key"}'

# 5. 发起 AI 请求（用平台 API Key）
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Authorization: Bearer atp_xxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
  }'
```

## 添加新厂商

1. 在 `app/adapters/` 下创建新适配器，继承 `BaseVendorAdapter`
2. 实现 `vendor_name`, `display_name`, `chat_completion()` 方法
3. 在 `app/adapters/factory.py` 中注册

```python
# app/adapters/gemini_adapter.py
class GeminiAdapter(BaseVendorAdapter):
    vendor_name = "gemini"
    display_name = "Google Gemini"
    # ...

# app/adapters/factory.py
from app.adapters.gemini_adapter import GeminiAdapter
register_adapter(GeminiAdapter)
```

## API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/auth/register` | 用户注册 |
| POST | `/auth/login` | 用户登录 |
| POST | `/auth/api-keys` | 创建 API Key |
| GET | `/auth/api-keys` | 列出 API Keys |
| DELETE | `/auth/api-keys/{id}` | 撤销 API Key |
| POST | `/v1/chat/completions` | **核心中继端点** |
| GET | `/usage/stats` | 用量统计 |
| GET | `/usage/quotas` | 配额状态 |
| GET | `/admin/vendors` | 厂商列表 |
| POST | `/admin/vendors/{name}/key` | 设置厂商密钥 |
| GET | `/admin/vendors/supported` | 支持的厂商 |
| GET | `/health` | 健康检查 |

## 技术栈

- **框架**：FastAPI + Uvicorn
- **数据库**：SQLAlchemy + SQLite（可切换 PostgreSQL）
- **认证**：bcrypt + JWT
- **加密**：cryptography (Fernet)
- **AI SDK**：openai + anthropic
- **测试**：pytest + httpx
