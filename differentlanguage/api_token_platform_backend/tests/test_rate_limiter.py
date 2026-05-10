import time
from app.services.rate_limiter import TokenBucket


def test_token_bucket_consume():
    bucket = TokenBucket(rate=10, capacity=10)
    assert bucket.consume(1) is True
    assert bucket.consume(1) is True
    assert bucket.tokens <= 8


def test_token_bucket_exhaust():
    bucket = TokenBucket(rate=0.01, capacity=1)
    assert bucket.consume(1) is True
    assert bucket.consume(1) is False
    assert bucket.available == 0


def test_token_bucket_refill():
    bucket = TokenBucket(rate=100, capacity=1)
    assert bucket.consume(1) is True
    assert bucket.consume(1) is False
    time.sleep(0.05)  # 等 50ms 让 ≥5 tokens 恢复
    assert bucket.consume(1) is True
