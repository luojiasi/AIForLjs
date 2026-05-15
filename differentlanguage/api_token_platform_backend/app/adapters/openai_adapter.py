"""
OpenAI API 适配器

将平台统一请求转换为 OpenAI Chat Completions API 格式并转发。
支持所有 GPT 系列和 O 系列模型。
"""

import time
from app.adapters.base_adapter import BaseVendorAdapter
from app.schemas.relay import RelayRequest, RelayResponse, ChatChoice, ChatMessage, TokenUsage


class OpenAIAdapter(BaseVendorAdapter):
    """OpenAI API 适配器 — 支持 GPT-4o / GPT-4o-mini / GPT-4-Turbo / O1 / O3 / O4 系列"""

    vendor_name = "openai"
    display_name = "OpenAI"

    _prefixes = ["gpt-", "o1-", "o3-", "o4-"]

    _pricing = {
        "gpt-4o": (2.50, 10.00),
        "gpt-4o-mini": (0.15, 0.60),
        "gpt-4-turbo": (10.00, 30.00),
        "o1": (15.00, 60.00),
        "o3-mini": (1.10, 4.40),
        "o4-mini": (1.10, 4.40),
    }

    def model_to_vendor(self, model: str) -> str | None:
        for prefix in self._prefixes:
            if model.startswith(prefix):
                return model
        return None

    async def chat_completion(self, request: RelayRequest, api_key: str) -> RelayResponse:
        from openai import AsyncOpenAI

        client = AsyncOpenAI(api_key=api_key)
        start = time.monotonic()

        kwargs = {
            "model": request.model,
            "messages": [{"role": m.role, "content": m.content} for m in request.messages],
            "max_tokens": request.max_tokens,
            "temperature": request.temperature,
            "top_p": request.top_p,
        }
        if request.stop:
            kwargs["stop"] = request.stop

        response = await client.chat.completions.create(**kwargs)
        latency_ms = (time.monotonic() - start) * 1000

        choice = response.choices[0]
        usage = TokenUsage(
            prompt_tokens=response.usage.prompt_tokens if response.usage else 0,
            completion_tokens=response.usage.completion_tokens if response.usage else 0,
            total_tokens=response.usage.total_tokens if response.usage else 0,
        )

        return RelayResponse(
            id=response.id,
            object="chat.completion",
            created=response.created,
            model=response.model,
            vendor="openai",
            choices=[ChatChoice(
                index=0,
                message=ChatMessage(role="assistant", content=choice.message.content or ""),
                finish_reason=choice.finish_reason or "stop",
            )],
            usage=usage,
            latency_ms=latency_ms,
        )

    def estimate_cost(self, response: RelayResponse) -> float:
        pricing = self._pricing.get(response.model, (0, 0))
        prompt_cost = (response.usage.prompt_tokens / 1_000_000) * pricing[0]
        completion_cost = (response.usage.completion_tokens / 1_000_000) * pricing[1]
        return round(prompt_cost + completion_cost, 6)
