const String apiReferenceFullDetail = '''

# API参考
## 概述

API Token中转平台提供RESTful API，所有响应均为JSON格式。
| 项目 | 值 |
|------|-----|
| Base URL | `http://localhost:8000` |
| API文档 (Swagger) | `http://localhost:8000/docs` |
| API文档 (ReDoc) | `http://localhost:8000/redoc` |
| 健康检查 | `http://localhost:8000/health` |
| 认证方式 | JWT (管理端点) / API Key (中继端点) |

## 认证说明

### JWT认证（用于用户管理）

```http
Authorization: Bearer <jwt_token>
```

需要JWT的端点：
- `/auth/register` (不需要)
- `/auth/login` (不需要)
- `/auth/api-keys` (需要JWT，管理平台API Key)
- `/usage/*` (需要JWT)
- `/admin/*` (需要JWT + admin角色)

### API Key认证（用于AI中继调用）

```http
Authorization: Bearer atp_<64位hex字符>
Content-Type: application/json
```

## API端点列表

### 认证模块 `/auth`

#### 用户注册
```
POST /auth/register
Content-Type: application/json

请求体:
{
  "username": "string",
  "password": "string",
  "email": "user@example.com"
}

响应 200:
{
  "id": 1,
  "username": "string",
  "email": "user@example.com",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}

错误:
  400 - 用户名已存在
  422 - 输入验证失败
```

#### 用户登录
```
POST /auth/login
Content-Type: application/x-www-form-urlencoded

参数:
  username: string
  password: string

响应 200:
{
  "access_token": "eyJhbGciOi...",
  "token_type": "bearer"
}

错误:
  401 - 用户名或密码错误
```

#### 创建平台API Key
```
POST /auth/api-keys
Authorization: Bearer <jwt_token>

请求体:
{
  "name": "My API Key"
}

响应 201:
{
  "id": 1,
  "name": "My API Key",
  "key_prefix": "atp_a1b2c3d4",
  "full_key": "atp_a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a7b8c9d0e1f2a3b4c5d6a7b8c9d0e1f2",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}

注意: full_key 仅在创建时返回一次，请妥善保存！

错误:
  401 - JWT令牌无效
```

#### 列出API Keys
```
GET /auth/api-keys
Authorization: Bearer <jwt_token>

响应 200:
[
  {
    "id": 1,
    "name": "My API Key",
    "key_prefix": "atp_a1b2c3d4",
    "is_active": true,
    "last_used_at": null,
    "created_at": "2024-01-01T00:00:00Z"
  }
]

注意: 此接口不返回完整Key
```

#### 撤销API Key
```
DELETE /auth/api-keys/{key_id}
Authorization: Bearer <jwt_token>

响应 200:
{
  "message": "API key revoked successfully"
}

错误:
  404 - Key不存在
  403 - 无权操作此Key
```

### AI中继模块 `/v1`

#### Chat Completions（核心中继端点）
```
POST /v1/chat/completions
Authorization: Bearer atp_<平台API Key>
Content-Type: application/json

请求体:
{
  "model": "gpt-4o",
  "messages": [
    {"role": "system", "content": "你是一个有帮助的助手"},
    {"role": "user", "content": "你好，请介绍一下自己"}
  ],
  "max_tokens": 1024,
  "temperature": 0.7,
  "vendor": null
}

字段说明:
  model        - 必填，模型名称。平台自动识别厂商并映射
  messages     - 必填，消息数组
  max_tokens   - 可选，默认1024，范围1-128000
  temperature  - 可选，默认0.7，范围0.0-2.0
  vendor       - 可选，手动指定厂商名 ("openai" / "anthropic")

响应 200:
{
  "id": "chatcmpl-xxx",
  "model": "gpt-4o",
  "content": "你好！我是AI助手...",
  "finish_reason": "stop",
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 50,
    "total_tokens": 75
  },
  "vendor": "openai"
}

错误:
  400 - 无法识别模型或厂商
  401 - API Key无效或未激活
  429 - 请求频率超限或配额用尽
  502 - 上游厂商API调用失败
  504 - 厂商API超时
```

模型自动识别规则：
- 以 `gpt-` 开头的模型 → OpenAI
- 以 `claude-` 开头的模型 → Anthropic
- 以 `o1`, `o3` 开头的模型 → OpenAI
- 其他模型需手动指定 `vendor` 字段

### 用量统计模块 `/usage`

#### 获取使用统计
```
GET /usage/stats
Authorization: Bearer <jwt_token>

查询参数:
  vendor   - 可选，厂商筛选 ("openai", "anthropic", "all")
  days     - 可选，统计最近N天，默认30

响应 200:
{
  "total_requests": 150,
  "total_tokens": 1250000,
  "total_cost_estimate": 15.50,
  "by_vendor": {
    "openai": {
      "requests": 120,
      "tokens": 1000000,
      "cost": 12.00
    },
    "anthropic": {
      "requests": 30,
      "tokens": 250000,
      "cost": 3.50
    }
  },
  "daily_breakdown": [
    {
      "date": "2024-01-01",
      "requests": 10,
      "tokens": 50000,
      "cost": 0.60
    }
  ]
}
```

#### 获取配额状态
```
GET /usage/quotas
Authorization: Bearer <jwt_token>

响应 200:
[
  {
    "vendor": "openai",
    "period": "monthly",
    "max_tokens": 1000000,
    "used_tokens": 250000,
    "remaining": 750000,
    "usage_percent": 25.0,
    "reset_at": "2024-02-01T00:00:00Z"
  },
  {
    "vendor": "anthropic",
    "period": "monthly",
    "max_tokens": 1000000,
    "used_tokens": 100000,
    "remaining": 900000,
    "usage_percent": 10.0,
    "reset_at": "2024-02-01T00:00:00Z"
  }
]
```

### 管理模块 `/admin`

#### 查看所有厂商
```
GET /admin/vendors
Authorization: Bearer <jwt_token>

响应 200:
[
  {
    "name": "openai",
    "display_name": "OpenAI",
    "has_key_configured": true,
    "supported_models": ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo"]
  },
  {
    "name": "anthropic",
    "display_name": "Anthropic",
    "has_key_configured": true,
    "supported_models": ["claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5"]
  }
]
```

#### 更新厂商API Key
```
POST /admin/vendors/{vendor_name}/key
Authorization: Bearer <jwt_token>
Content-Type: application/json

请求体:
{
  "api_key": "sk-xxx"
}

响应 200:
{
  "message": "Vendor key updated successfully",
  "vendor": "openai"
}

错误:
  404 - 厂商不存在或未注册适配器
```

#### 获取支持的厂商列表
```
GET /admin/vendors/supported

响应 200:
{
  "vendors": ["openai", "anthropic"],
  "auto_detectable_models": {
    "openai": ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo", "o1", "o3"],
    "anthropic": ["claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5"]
  }
}
```

## 错误格式

所有错误响应遵循统一格式：
```json
{
  "detail": "错误描述信息"
}
```

HTTP状态码：
| 状态码 | 含义 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 认证失败 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 422 | 请求体验证失败 |
| 429 | 请求频率超限/配额用尽 |
| 500 | 服务器内部错误 |
| 502 | 上游厂商错误 |
| 504 | 上游厂商超时 |

## API使用示例

### cURL

```bash
# 1. 注册用户
curl -X POST http://localhost:8000/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{"username":"alice","password":"secret123","email":"alice@example.com"}'

# 2. 登录获取JWT
JWT=\$(curl -s -X POST http://localhost:8000/auth/login \\
  -H "Content-Type: application/x-www-form-urlencoded" \\
  -d "username=alice&password=secret123" | jq -r '.access_token')

# 3. 创建平台API Key
API_KEY=\$(curl -s -X POST http://localhost:8000/auth/api-keys \\
  -H "Authorization: Bearer \$JWT" \\
  -H "Content-Type: application/json" \\
  -d '{"name":"dev-key"}' | jq -r '.full_key')

# 4. 使用API Key调用AI
curl -X POST http://localhost:8000/v1/chat/completions \\
  -H "Authorization: Bearer \$API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# 5. 查看用量
curl http://localhost:8000/usage/stats \\
  -H "Authorization: Bearer \$JWT"
```

### Python SDK 示例

```python
import requests

BASE_URL = "http://localhost:8000"

class TokenPlatform:
    def __init__(self, base_url=BASE_URL):
        self.base_url = base_url
        self.jwt_token = None
        self.api_key = None

    def register(self, username, password, email):
        resp = requests.post(f"{self.base_url}/auth/register", json={
            "username": username, "password": password, "email": email
        })
        return resp.json()

    def login(self, username, password):
        resp = requests.post(f"{self.base_url}/auth/login", data={
            "username": username, "password": password
        })
        self.jwt_token = resp.json()["access_token"]
        return self.jwt_token

    def create_api_key(self, name="default"):
        resp = requests.post(f"{self.base_url}/auth/api-keys",
            headers={"Authorization": f"Bearer {self.jwt_token}"},
            json={"name": name}
        )
        self.api_key = resp.json()["full_key"]
        return self.api_key

    def chat(self, model, messages, max_tokens=1024, temperature=0.7):
        resp = requests.post(f"{self.base_url}/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
            json={
                "model": model,
                "messages": messages,
                "max_tokens": max_tokens,
                "temperature": temperature,
            }
        )
        return resp.json()

# 使用示例
platform = TokenPlatform()
platform.register("alice", "secret123", "alice@example.com")
platform.login("alice", "secret123")
platform.create_api_key("my-key")

result = platform.chat(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello, world!"}]
)
print(result["content"])
```

''';
