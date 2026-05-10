const String tokenMgmtFullDetail = '''

# Token管理

## 两种Token的区别
API Token中转平台涉及两种完全不同性质的Token：
| 维度 | 平台API Key | 厂商API Key |
|------|-----------|-----------|
| 持有者 | 平台用户 | 平台管理员 |
| 用途 | 调用平台API | 平台调用厂商API |
| 格式 | atp_ + 64位hex | 厂商自有格式 (sk-/sk-ant-) |
| 存储方式 | bcrypt单向哈希 | Fernet对称加密 |
| 可解密 | 否（永远不可恢复）| 是（需要时解密使用）|
| 可见性 | 仅创建时完整返回一次 | 永不对用户可见 |
| 泄露影响 | 单个用户的调用权限 | 所有用户的厂商调用能力 |

## 平台API Key设计

### Key格式

```
atp_a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
││   └─ 前缀8位hex（用于数据库索引）
│└───── 平台标识
└────── 完整Key = 前缀 + 32字节随机hex
```

### 生成算法

```python
import secrets

def generate_api_key() -> tuple[str, str]:
    raw = secrets.token_hex(32)  # 256位随机，密码学安全
    full_key = f"atp_{raw}"
    prefix = full_key[:12]  # "atp_" + 8个hex字符
    return full_key, prefix
```

### 存储与验证流程
```
创建阶段：
  明文Key → bcrypt哈希 → 存入 key_hash 字段
  明文Key → 取前12字符 → 存入 key_prefix 字段
  明文Key → 返回给用户（仅此一次）

验证阶段：
  用户传入 Key → 提取前12字符 → 查询匹配 key_prefix 的记录
  → 逐条 bcrypt.verify(传入Key, key_hash)
  → 匹配成功 → 返回用户身份
  → 均不匹配 → 返回401
```

### 验证代码实现

```python
def verify_api_key(db: Session, raw_key: str) -> User | None:
    prefix = raw_key[:12]
    candidates = db.query(PlatformApiKey).filter(
        PlatformApiKey.key_prefix == prefix,
        PlatformApiKey.is_active == True,
    ).all()
    for candidate in candidates:
        if pwd_context.verify(raw_key, candidate.key_hash):
            return candidate.user
    return None
```

关键优化：用 `key_prefix` 做索引，将验证范围从"全表"缩小到"候选集"，时间复杂度从 O(n) 降为接近 O(1)。

## 厂商API Key设计

### Fernet加密方案

```
加密过程：
  SECRET_KEY (环境变量)
    → SHA256 哈希
    → Base64 URL-safe编码
    → Fernet密钥 (32字节)

  厂商Key明文
    → Fernet(密钥).encrypt(明文)
    → Base64加密字符串
    → 存入 vendor_keys.encrypted_key

解密过程：
  加密字符串
    → Fernet(密钥).decrypt(加密值, ttl=None)
    → 明文（仅在内存中，用完丢弃）
```

### 密钥派生实现

```python
import base64
import hashlib
from cryptography.fernet import Fernet

def _get_fernet() -> Fernet:
    key = hashlib.sha256(settings.secret_key.encode()).digest()
    return Fernet(base64.urlsafe_b64encode(key))

def encrypt_vendor_key(raw_key: str) -> str:
    return _get_fernet().encrypt(raw_key.encode()).decode()

def decrypt_vendor_key(encrypted: str) -> str:
    return _get_fernet().decrypt(encrypted.encode()).decode()
```

## Key的安全生命周期
### 平台API Key生命周期

```
创建(CREATE) → 激活(ACTIVE) → 使用(IN USE) → 撤销(REVOKED)
                                                        │
                                                  never 删除
                                                  保留审计记录
```

- **创建**：通过 `/auth/api-keys` POST端点，需JWT认证
- **激活**：默认创建即激活，is_active=True
- **使用**：每次API调用验证Key合法性，更新 last_used_at
- **撤销**：通过 `/auth/api-keys/{id}` DELETE端点，设置 is_active=False

### 厂商Key的注入方式
1. **环境变量**（推荐用于初始配置）
   ```bash
   # .env
   OPENAI_API_KEY=sk-your-key
   ANTHROPIC_API_KEY=sk-ant-your-key
   ```

2. **Admin API**（运行时管理）
   ```bash
   curl -X POST http://localhost:8000/admin/vendors/openai/key \\
     -d '{"api_key":"sk-xxx"}'
   ```

## 安全最佳实践
### 1. 密钥轮转策略

| 密钥类型 | 建议轮转周期 | 轮转方式 |
|---------|------------|---------|
| 平台主密钥 SECRET_KEY | 每季度 | 重新生成 → 更新环境变量 → 重启服务 |
| 厂商API Key | 每90天 | 在厂商平台生成新Key → 通过Admin API更新 |
| 用户API Key | 按需撤销重建 | 用户调用DELETE端点 → 重新POST创建 |

### 2. 日志安全

```python
# 绝对禁止的做法
logger.info(f"Using API key: {raw_key}")        # ❌ 泄露Key
logger.info(f"Vendor key: {decrypted_key}")      # ❌ 泄露厂商密钥

# 正确的做法
logger.info(f"API key verified: prefix={key_prefix[:8]}")  # ✅ 只记录前缀
logger.info(f"Using vendor: {vendor_name}")                 # ✅ 只记录厂商标识
```

### 3. 防暴力破解
```python
# 对验证失败的请求增加延迟
import time

def verify_api_key_with_delay(db, raw_key, attempt_count):
    result = verify_api_key(db, raw_key)
    if result is None:
        # 失败次数越多，延迟越长
        delay = min(attempt_count * 0.5, 5.0)
        time.sleep(delay)
    return result
```

## 生产环境升级

对于生产环境，建议将厂商密钥管理迁移到专业的密钥管理服务：
- **AWS KMS**：使用KMS加密密钥取代Fernet
- **HashiCorp Vault**：动态密钥管理 + 审计日志
- **Azure Key Vault**：Azure生态内的密钥管理

迁移步骤：
1. 在KMS中创建主密钥
2. 修改 `encrypt_vendor_key` / `decrypt_vendor_key` 使用KMS API
3. 将已加密的Fernet密钥迁移到KMS加密格式
4. 下线Fernet加密代码

''';
