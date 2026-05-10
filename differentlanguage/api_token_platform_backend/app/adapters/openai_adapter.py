"""
OpenAI API 适配器

将平台统一请求转换为 OpenAI Chat Completions API 格式并转发。
支持所有 GPT 系列和 O 系列模型。

OpenAI API 端点: POST https://api.openai.com/v1/chat/completions
SDK: openai (AsyncOpenAI)
"""

from app.adapters.base_adapter import BaseVendorAdapter
from app.schemas.relay import RelayRequest, RelayResponse


class OpenAIAdapter(BaseVendorAdapter):
    """OpenAI API 适配器 — 支持 GPT-4o / GPT-4o-mini / GPT-4-Turbo / O1 / O3 / O4 系列"""

    vendor_name = "openai"
    display_name = "OpenAI"

    # 模型前缀 — 用于自动识别（请求中 model 以这些前缀开头的路由到 OpenAI）
    _模型前缀列表 = ["gpt-", "o1-", "o3-", "o4-"]

    # 定价表 — key: 模型名, value: (输入价格, 输出价格) 单位：美元/百万Token
    _定价表 = {
        "gpt-4o": (2.50, 10.00),        # GPT-4o: $2.50/$10.00 per 1M tokens
        "gpt-4o-mini": (0.15, 0.60),    # GPT-4o Mini: $0.15/$0.60
        "gpt-4-turbo": (10.00, 30.00),  # GPT-4 Turbo: $10/$30
        "o1": (15.00, 60.00),           # O1: 推理模型，价格较高
        "o3-mini": (1.10, 4.40),        # O3 Mini
        "o4-mini": (1.10, 4.40),        # O4 Mini
    }

    def model_to_vendor(self, model: str) -> str | None:
        """检查 model 名称是否匹配 OpenAI 模型前缀"""
        for 前缀 in self._模型前缀列表:
            if model.startswith(前缀):
                return model
        return None

    async def chat_completion(self, request: RelayRequest, api_key: str) -> RelayResponse:
        """调用 OpenAI Chat Completions API"""
        import time
        from openai import AsyncOpenAI

        # 使用官方 SDK 创建异步客户端
        client = AsyncOpenAI(api_key=api_key)
        开始时间 = time.monotonic()

        # 构建 OpenAI 格式的请求参数
        kwargs = {
            "model": request.model,
            "messages": [
                {"role": m.role, "content": m.content}
                for m in request.messages
            ],
            "max_tokens": request.max_tokens,
            "temperature": request.temperature,
            "top_p": request.top_p,
        }
        if request.stop:
            kwargs["stop"] = request.stop

        # 调用 OpenAI API
        response = await client.chat.completions.create(**kwargs)
        延迟毫秒 = (time.monotonic() - 开始时间) * 1000

        # 提取响应内容并标准化
        choice = response.choices[0]
        return RelayResponse(
            id=response.id,
            model=response.model,
            vendor="openai",
            content=choice.message.content or "",
            finish_reason=choice.finish_reason or "stop",
            usage={
                "prompt_tokens": response.usage.prompt_tokens if response.usage else 0,
                "completion_tokens": response.usage.completion_tokens if response.usage else 0,
                "total_tokens": response.usage.total_tokens if response.usage else 0,
            },
            latency_ms=延迟毫秒,
        )

    def estimate_cost(self, response: RelayResponse) -> float:
        """
        估算 OpenAI API 调用费用

        计算公式: (输入Token/1M) * 输入单价 + (输出Token/1M) * 输出单价
        使用 .get() 提供默认值，避免未知模型崩溃
        """
        定价 = self._定价表.get(response.model, (0, 0))
        输入费用 = (response.usage["prompt_tokens"] / 1_000_000) * 定价[0]
        输出费用 = (response.usage["completion_tokens"] / 1_000_000) * 定价[1]
        return round(输入费用 + 输出费用, 6)
