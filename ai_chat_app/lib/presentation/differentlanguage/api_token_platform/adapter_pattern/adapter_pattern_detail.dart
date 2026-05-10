const String adapterPatternFullDetail = '''

# 多厂商适配器模式
## 为什么需要适配器？

AI厂商的API差异是全方位的。以Chat请求为例：
| 维度 | OpenAI | Anthropic |
|------|--------|-----------|
| 端点 | POST /v1/chat/completions | POST /v1/messages |
| 消息格式 | messages: [{role, content}] | messages: [{role, content}] |
| 系统消息 | 放在messages数组中 | 独立system参数 |
| 最大Token | max_tokens (可选) | max_tokens (必填) |
| 停止序列 | stop (字符串数组) | stop_sequences (字符串数组) |
| 费用查询 | 需额外API | 响应中包含 |
| 错误格式 | error.message | error.error.message |

如果不做适配，客户端代码需要针对每个厂商写不同的调用逻辑，这严重违背了"平台统一入口"的设计目标。

## 适配器模式架构
### 抽象基类设计

```python
from abc import ABC, abstractmethod

class BaseVendorAdapter(ABC):
    """厂商适配器抽象基类"""

    @property
    @abstractmethod
    def vendor_name(self) -> str:
        """厂商名称，如 'openai', 'anthropic'"""
        ...

    @property
    def display_name(self) -> str:
        """显示名称"""
        return self.vendor_name

    @abstractmethod
    async def chat_completion(
        self, request: 'RelayRequest', api_key: str
    ) -> 'RelayResponse':
        """执行Chat Completion请求"""
        ...

    def model_to_vendor(self, model: str) -> str | None:
        """将平台模型名映射为厂商模型名，默认返回None"""
        return None

    def estimate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """估算费用"""
        return 0.0
```

### OpenAI适配器实现

```python
class OpenAIAdapter(BaseVendorAdapter):
    vendor_name = "openai"
    display_name = "OpenAI"

    # 模型 → 价格映射 (per 1K tokens)
    PRICING = {
        "gpt-4o": (0.005, 0.015),       # prompt, completion
        "gpt-4o-mini": (0.00015, 0.0006),
        "gpt-4-turbo": (0.01, 0.03),
        "gpt-3.5-turbo": (0.0005, 0.0015),
    }

    def model_to_vendor(self, model: str) -> str | None:
        model_lower = model.lower()
        if any(model_lower.startswith(p) for p in ("gpt-", "o1", "o3")):
            return model
        return None

    async def chat_completion(self, request, api_key):
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": request.model,
            "messages": [m.model_dump() for m in request.messages],
            "max_tokens": request.max_tokens or 1024,
            "temperature": request.temperature,
        }
        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                f"{self.base_url}/v1/chat/completions",
                json=payload, headers=headers,
            )
        data = resp.json()
        if resp.status_code != 200:
            raise HTTPException(
                status_code=resp.status_code,
                detail=data.get("error", {}).get("message", "OpenAI error"),
            )
        return self._normalize_response(data)

    def _normalize_response(self, data: dict) -> RelayResponse:
        choice = data["choices"][0]
        usage = data.get("usage", {})
        return RelayResponse(
            id=data["id"],
            model=data["model"],
            content=choice["message"]["content"],
            finish_reason=choice.get("finish_reason", "stop"),
            usage=UsageInfo(
                prompt_tokens=usage.get("prompt_tokens", 0),
                completion_tokens=usage.get("completion_tokens", 0),
                total_tokens=usage.get("total_tokens", 0),
            ),
            vendor="openai",
        )
```

### Anthropic适配器实现

```python
class AnthropicAdapter(BaseVendorAdapter):
    vendor_name = "anthropic"
    display_name = "Anthropic"

    PRICING = {
        "claude-sonnet-4-6": (3.0, 15.0),     # per 1M tokens
        "claude-opus-4-7": (15.0, 75.0),
        "claude-haiku-4-5": (0.80, 4.0),
    }

    def model_to_vendor(self, model: str) -> str | None:
        if model.lower().startswith("claude-"):
            return model
        return None

    async def chat_completion(self, request, api_key):
        headers = {
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
        }
        # 提取系统消息
        system_msgs = [m.content for m in request.messages if m.role == "system"]
        chat_msgs = [m for m in request.messages if m.role != "system"]

        payload = {
            "model": request.model,
            "messages": [{"role": m.role, "content": m.content} for m in chat_msgs],
            "max_tokens": request.max_tokens or 4096,
        }
        if system_msgs:
            payload["system"] = "\n".join(system_msgs)

        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                f"{self.base_url}/v1/messages",
                json=payload, headers=headers,
            )
        data = resp.json()
        if resp.status_code != 200:
            raise HTTPException(
                status_code=resp.status_code,
                detail=data.get("error", {}).get("message", "Anthropic error"),
            )
        return self._normalize_response(data)
```

## 适配器工厂

```python
class AdapterFactory:
    """适配器工厂 — 管理所有厂商适配器"""

    _adapters: dict[str, BaseVendorAdapter] = {}

    @classmethod
    def register(cls, adapter_cls: type[BaseVendorAdapter]):
        instance = adapter_cls()
        cls._adapters[instance.vendor_name] = instance

    @classmethod
    def get(cls, vendor_name: str) -> BaseVendorAdapter:
        adapter = cls._adapters.get(vendor_name)
        if adapter is None:
            raise ValueError(f"Unknown vendor: {vendor_name}")
        return adapter

    @classmethod
    def detect(cls, model: str) -> tuple[BaseVendorAdapter, str]:
        """根据模型名自动检测厂商"""
        for adapter in cls._adapters.values():
            internal = adapter.model_to_vendor(model)
            if internal is not None:
                return adapter, internal
        raise ValueError(f"Cannot detect vendor for model: {model}")

    @classmethod
    def list_all(cls) -> list[str]:
        return list(cls._adapters.keys())
```

## 如何新增厂商适配器？

只需3步即可支持一个新的AI厂商：

### 第1步：创建适配器文件
在 `app/adapters/` 下新建文件，如 `google_adapter.py`：

```python
class GoogleAdapter(BaseVendorAdapter):
    vendor_name = "google"
    display_name = "Google Gemini"

    def model_to_vendor(self, model):
        if model.startswith("gemini-"):
            return model
        return None

    async def chat_completion(self, request, api_key):
        # 实现Google AI的调用逻辑
        ...
```

### 第2步：注册适配器
在 `app/adapters/__init__.py` 中注册：

```python
from .google_adapter import GoogleAdapter
AdapterFactory.register(GoogleAdapter)
```

### 第3步：配置厂商密钥
```bash
curl -X POST http://localhost:8000/admin/vendors/google/key \\
  -d '{"api_key":"your-google-key"}'
```

完成！新的厂商适配器立即生效。

## 适配器模式的优势

| 优势 | 说明 |
|------|------|
| 开闭原则 | 对扩展开放（新增适配器），对修改关闭（核心代码不变）|
| 单一职责 | 每个适配器只负责一个厂商的协议转换 |
| 统一接口 | 所有厂商对外暴露相同的接口，客户端无感知 |
| 可测试性 | 每个适配器可以独立进行单元测试 |
| 运行时切换 | 根据请求动态选择适配器，无需重启服务 |

''';
