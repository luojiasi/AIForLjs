const String securityFullDetail = '''

# 安全设计

## 安全威胁模型

API Token中转平台面临的主要安全威胁：

| 威胁 | 风险等级 | 影响 | 防护措施 |
|------|---------|------|---------|
| 厂商密钥泄露 | 严重 | 所有用户的AI调用可被劫持 | Fernet加密 + 环境变量隔离 |
| 用户API Key泄露 | 高 | 单个用户的滥用 | bcrypt哈希 + 快速撤销 |
| 数据库被拖库 | 高 | 用户信息 + 加密密钥泄露 | 加密存储 + 日志审计 |
| API暴力破解 | 中 | 未授权访问 | 限流 + 指数退避 |
| SQL注入 | 中 | 数据篡改或泄露 | ORM参数化查询 |
| 中间人攻击 | 中 | 传输数据被窃取 | 全链路HTTPS |
| 日志泄露 | 中 | 敏感信息在日志中暴露 | 日志过滤 + 脱敏 |

## 三层加密体系

```
第一层（传输加密）:
  Client ──HTTPS/TLS 1.3──→ Nginx ──HTTP──→ Uvicorn

第二层（存储加密 - 用户凭证）:
  bcrypt(API_Key) → key_hash (单向，不可逆)

第三层（存储加密 - 厂商密钥）:
  Fernet(AES-128-CBC + HMAC)(Vendor_Key) → encrypted_key (可解密)
```

## 密钥安全详解

### 第一道防线：bcrypt 保护用户凭证

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 存储:
key_hash = pwd_context.hash("atp_a1b2c3d4...")
# → "\$2b\$12\$K8xY7zQ9wE2rT5uI3oP1sO..."

# 验证:
is_valid = pwd_context.verify("atp_a1b2c3d4...", key_hash)
# → True/False
```

bcrypt的安全性保证：
- **随机盐 (Salt)**：每次哈希都包含随机盐，相同明文产生不同哈希
- **成本因子 (Cost Factor)**：默认12，即2^12=4096次迭代，计算耗时约0.3秒
- **单向性**：数学上无法从哈希值恢复原始Key
- **防彩虹表**：盐值确保预计算的彩虹表攻击无效

### 第二道防线：Fernet 保护厂商密钥

Fernet是 `cryptography` 库提供的高级对称加密方案：
```
Fernet = AES-128-CBC (加密) + HMAC-SHA256 (签名)

加密过程：
  明文 → AES-128-CBC(密钥, 随机IV) → 密文
  密文 + 时间戳 + IV → HMAC-SHA256 → 签名
  最终 = Base64(版本 + 时间戳 + IV + 密文 + 签名)

解密过程：
  Base64解码 → 验证HMAC签名 → 验证时间戳 → AES解密 → 明文
```

```python
from cryptography.fernet import Fernet
import base64, hashlib

def _get_fernet() -> Fernet:
    # 从SECRET_KEY派生Fernet密钥
    key_bytes = hashlib.sha256(settings.secret_key.encode()).digest()
    fernet_key = base64.urlsafe_b64encode(key_bytes)
    return Fernet(fernet_key)

def encrypt_vendor_key(raw_key: str) -> str:
    return _get_fernet().encrypt(raw_key.encode()).decode()

def decrypt_vendor_key(encrypted: str) -> str:
    return _get_fernet().decrypt(encrypted.encode()).decode()
```

### 第三道防线：SECRET_KEY 隔离

SECRET_KEY 是整个安全体系的基石：
```
SECRET_KEY 的生命周期：
  生成 ──→ 环境变量 ──→ Python Settings对象 ──→ 内存
     (openssl rand)   (.env文件)    (pydantic-settings)  (永远不会写入磁盘或日志)
```

生成安全的SECRET_KEY：
```bash
openssl rand -hex 32
# 输出: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a7b8c9d0e1f2a3b4c5d6a7b8c9d0
```

## 应用安全

### 输入验证

FastAPI + Pydantic 自动验证所有请求输入：

```python
class RelayRequest(BaseModel):
    model: str = Field(..., min_length=1, max_length=100)
    messages: list[ChatMessage] = Field(..., min_length=1)
    max_tokens: int = Field(1024, ge=1, le=128000)
    temperature: float = Field(0.7, ge=0.0, le=2.0)
```

Pydantic自动进行类型校验、范围校验、长度校验，确保非法输入在进入业务逻辑前被拒绝。

### SQL注入防护

所有数据库操作使用 SQLAlchemy ORM 参数化查询：

```python
# ✅ 安全：ORM参数化查询
user = db.query(User).filter(User.username == username).first()

# ❌ 危险：字符串拼接（代码中从未使用）
# db.execute(f"SELECT * FROM users WHERE username = '{username}'")
```

### CORS配置

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-app.com"],  # 生产环境指定具体域名
    allow_credentials=True,
    allow_methods=["GET", "POST", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

## 日志安全

### 敏感信息过滤

```python
import re
import logging

class SensitiveDataFilter(logging.Filter):
    """过滤日志中的敏感信息"""

    _patterns = [
        (r'sk-[a-zA-Z0-9]{20,}', '[OPENAI_KEY_REDACTED]'),
        (r'sk-ant-[a-zA-Z0-9]{20,}', '[ANTHROPIC_KEY_REDACTED]'),
        (r'atp_[a-f0-9]{64}', '[PLATFORM_KEY_REDACTED]'),
        (r'Bearer [a-zA-Z0-9_-]{20,}', 'Bearer [REDACTED]'),
    ]

    def filter(self, record):
        if hasattr(record, 'msg'):
            for pattern, replacement in self._patterns:
                record.msg = re.sub(pattern, replacement, str(record.msg))
        return True

# 注册过滤器
logger = logging.getLogger("api_gateway")
logger.addFilter(SensitiveDataFilter())
```

## 安全部署检查清单
### 部署前检查
- [ ] SECRET_KEY使用 `openssl rand -hex 32` 生成
- [ ] .env 文件已加入 .gitignore
- [ ] DEBUG=false
- [ ] CORS配置了具体的允许域名（非"*"）
- [ ] 启用了限流配置
- [ ] 日志过滤器已配置
- [ ] Docker容器以非root用户运行

### 运维安全检查
- [ ] 定期审查API Key使用情况
- [ ] 配置厂商Key的使用量告警
- [ ] 监控异常登录频率
- [ ] HTTPS证书有效期监控
- [ ] 数据库备份加密
- [ ] 定期安全审计

''';
