const String rateLimitingFullDetail = '''

# 限流与配额管理
## 为什么需要限流？

AI API调用是昂贵的资源。如果没有限流机制，会出现以下问题：

1. **成本失控**：一个用户可能在短时间内发起大量调用，消耗大量Token
2. **公平性问题**：个别用户占用过多资源，影响其他用户的正常使用
3. **厂商限流触发**：超出厂商的RPM/TPM限制，导致所有请求被拒绝
4. **恶意攻击**：API Key泄露后可能被用于挖矿或滥用

## 双层防护体系

平台采用两层防护：请求频率限流（Rate Limiting）和用量配额（Quota）。
```
                  ┌──────────────────┐
   请求到达 →     │ 第一层：频率限流  │ → 超限 → 返回429
                  └──────┬───────────┘
                         │ 通过
                  ┌──────▼───────────┐
                  │ 第二层：配额检查  │ → 超限 → 返回429
                  └──────┬───────────┘
                         │ 通过
                  ┌──────▼───────────┐
                  │   处理请求        │
                  └──────────────────┘
```

## 第一层：令牌桶限流
### 算法原理

```
令牌桶 (Token Bucket):

  以速率 r 填充 ──→ ┌─────────────┐
                     │[Token][Token][Token]  │ ← 桶容量 C
                     │[Token][Token]         │
                     └─────────┬───────┘
                               │
                 请求到达 → 消耗1个Token → 通过
                 请求到达 → Token不足 → 拒绝(429)
```

### 代码实现

```python
import time
import threading

class TokenBucket:
    def __init__(self, rate: int, capacity: int | None = None):
        self.rate = rate          # tokens per second
        self.capacity = capacity or rate
        self.tokens = float(capacity)  # 初始满桶
        self.last_refill = time.monotonic()
        self.lock = threading.Lock()

    def _refill(self):
        now = time.monotonic()
        elapsed = now - self.last_refill
        self.tokens = min(self.capacity,
            self.tokens + elapsed * self.rate)
        self.last_refill = now

    def consume(self, tokens: int = 1) -> bool:
        with self.lock:
            self._refill()
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            return False
```

### 用户级限流器

```python
class InMemoryRateLimiter:
    def __init__(self, rpm: int = 60):
        self.rpm = rpm
        self._buckets: dict[int, TokenBucket] = {}
        self._lock = threading.Lock()

    def _get_bucket(self, user_id: int) -> TokenBucket:
        if user_id not in self._buckets:
            rate = self.rpm / 60.0  # RPM → tokens/sec
            self._buckets[user_id] = TokenBucket(
                rate=rate, capacity=self.rpm
            )
        return self._buckets[user_id]

    def is_allowed(self, user_id: int) -> bool:
        with self._lock:
            return self._get_bucket(user_id).consume(1)
```

### 配置示例

```bash
# .env 配置
RATE_LIMIT_REQUESTS_PER_MINUTE=60     # 每个用户每分钟60次请求
RATE_LIMIT_TOKENS_PER_MONTH=1000000   # 每个用户每月100万Token
```

## 第二层：配额管理

### 数据库模型
```python
class UsageQuota(Base):
    __tablename__ = "usage_quotas"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    vendor = Column(String(50))       # "openai", "anthropic", "*"
    period = Column(String(20))       # "monthly", "daily"
    max_tokens = Column(Integer, default=1_000_000)
    used_tokens = Column(Integer, default=0)
    reset_at = Column(DateTime)
```

### 配额检查与更新

```python
def check_quota(db, user_id, vendor, requested_tokens) -> bool:
    quota = get_or_create_quota(db, user_id, vendor)
    return (quota.used_tokens + requested_tokens) <= quota.max_tokens

def add_usage(db, user_id, vendor, tokens):
    quota = get_or_create_quota(db, user_id, vendor)
    quota.used_tokens += tokens
    db.commit()
```

### 配额自动重置

```python
def get_or_create_quota(db, user_id, vendor):
    quota = db.query(UsageQuota).filter(
        UsageQuota.user_id == user_id,
        UsageQuota.vendor == vendor,
    ).first()

    now = datetime.now(timezone.utc)

    if quota is None:
        # 新配额
        next_month = (now.replace(day=1) +
                     timedelta(days=32)).replace(day=1)
        quota = UsageQuota(
            user_id=user_id, vendor=vendor,
            max_tokens=settings.rate_limit_tokens_per_month,
            reset_at=next_month,
        )
        db.add(quota)
    elif now >= quota.reset_at:
        # 周期重置
        quota.used_tokens = 0
        quota.reset_at = (now.replace(day=1) +
                         timedelta(days=32)).replace(day=1)

    return quota
```

## 限流算法对比

| 算法 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **令牌桶** | 支持突发流量，平滑限流 | 实现稍复杂 | 本平台采用 |
| 固定窗口 | 实现简单 | 边界双倍流量问题 | 简单场景 |
| 滑动窗口 | 精确平滑 | 内存开销高 | 高精度需求 |
| 漏桶 | 绝对平滑 | 不允许突发 | 严格流控 |

## 生产环境升级

### 内存限流 → Redis 分布式限流
单机部署时内存限流足够。多机部署时需要Redis：

```python
# 使用Redis + Lua脚本实现原子操作
REDIS_LUA_SCRIPT = """
local tokens_key = KEYS[1]
local rate = tonumber(ARGV[1])
local capacity = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local requested = tonumber(ARGV[4])

local last_tokens = tonumber(redis.call("get", tokens_key))
if last_tokens == nil then
    last_tokens = capacity
end

local elapsed = math.max(0, now - tonumber(redis.call("get", tokens_key..":ts")))
local new_tokens = math.min(capacity, last_tokens + elapsed * rate)

if new_tokens >= requested then
    redis.call("set", tokens_key, new_tokens - requested)
    redis.call("set", tokens_key..":ts", now)
    return 1
end
return 0
"""
```

### 响应头
标准的限流响应头，帮助客户端了解限流状态：

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1715000000
```

## 监控和告警
1. **配额使用率监控**：当用户用量超过80%时发送告警
2. **限流触发频率**：监控429响应的比例，判断限流阈值是否合理
3. **费用异常检测**：单日费用突然飙升时立即通知管理员
4. **按用户统计**：识别用量Top用户，评估是否需要升级配额

''';
