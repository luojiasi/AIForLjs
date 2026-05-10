"""
令牌桶限流模块

实现基于令牌桶算法（Token Bucket）的请求频率限制。

算法原理：
- 一个"桶"以固定速率（tokens/sec）填充令牌
- 桶有最大容量限制，多余的令牌会被丢弃
- 每个请求需要消耗 1 个令牌
- 有令牌 → 请求通过；无令牌 → 请求被拒绝（HTTP 429）

相比固定窗口算法的优势：
- 允许合理的流量突发（burst）
- 不会在窗口边界产生"双倍流量"问题

线程安全设计：所有桶操作使用 threading.Lock 保护。
"""

import time
import threading
from collections import defaultdict
from app.config import settings


class 令牌桶:
    """
    令牌桶限流器

    参数:
        rate: 令牌填充速率（tokens/秒）
        capacity: 桶的最大容量（允许的突发流量上限）

    示例:
        桶 = 令牌桶(rate=1, capacity=60)  # 每秒1个令牌，最多存60个（允许突发60个请求）
    """
    def __init__(self, rate: int, capacity: int | None = None):
        self.rate = rate                     # 令牌填充速率（tokens/秒）
        self.capacity = capacity or rate     # 桶的最大容量
        self.tokens = float(capacity)        # 当前令牌数（初始满桶）
        self.last_refill = time.monotonic()  # 上次填充时间戳
        self.lock = threading.Lock()         # 线程安全锁

    def _补充令牌(self):
        """根据经过的时间补充令牌（不超过桶容量）"""
        当前时间 = time.monotonic()
        经过时间 = 当前时间 - self.last_refill
        self.tokens = min(self.capacity, self.tokens + 经过时间 * self.rate)
        self.last_refill = 当前时间

    def consume(self, tokens: int = 1) -> bool:
        """
        尝试消耗指定数量的令牌

        返回: True=有足够令牌，请求通过；False=令牌不足，请求应被拒绝
        """
        with self.lock:
            self._补充令牌()
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            return False

    @property
    def available(self) -> int:
        """当前可用的令牌数"""
        with self.lock:
            self._补充令牌()
            return int(self.tokens)


TokenBucket = 令牌桶  # 英文别名


class 内存限流器:
    """
    内存级用户限流器

    为每个用户（按 user_id）维护独立的令牌桶。
    每个用户的桶有相同的速率限制（从配置读取），但互不干扰。

    适用场景：单机部署
    多机部署：需切换到 Redis 分布式限流方案
    """

    def __init__(self, rpm: int | None = None):
        self.rpm = rpm or settings.rate_limit_requests_per_minute   # 每分钟请求限制
        self._用户桶字典: dict[int, 令牌桶] = {}                     # user_id → 令牌桶
        self._锁 = threading.Lock()

    def _获取用户桶(self, user_id: int) -> 令牌桶:
        """获取或创建用户的令牌桶"""
        if user_id not in self._用户桶字典:
            每秒速率 = self.rpm / 60.0   # RPM 转换为 tokens/sec
            self._用户桶字典[user_id] = 令牌桶(rate=每秒速率, capacity=self.rpm)
        return self._用户桶字典[user_id]

    def 是否允许(self, user_id: int) -> bool:
        """检查指定用户的请求是否被允许"""
        with self._锁:
            return self._获取用户桶(user_id).consume(1)

    is_allowed = 是否允许  # 英文别名

    def 剩余配额(self, user_id: int) -> int:
        """查询用户当前剩余的请求配额"""
        with self._锁:
            return self._获取用户桶(user_id).available

    remaining = 剩余配额  # 英文别名

    def 重置用户(self, user_id: int):
        """重置指定用户的限流状态（管理员操作）"""
        with self._锁:
            if user_id in self._用户桶字典:
                del self._用户桶字典[user_id]

    reset = 重置用户  # 英文别名


# 全局限流器单例
# 使用方式: from app.services.rate_limiter import rate_limiter
#         rate_limiter.is_allowed(user_id)
rate_limiter = 内存限流器()
InMemoryRateLimiter = 内存限流器  # 英文别名
