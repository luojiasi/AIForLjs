"""
Anthropic Claude API 适配器

将平台统一请求转换为 Anthropic Messages API 格式并转发。
支持所有 Claude 系列模型。

与 OpenAI 的关键差异:
- system 消息作为顶层参数传递，而非放在 messages 数组中
- max_tokens 是必填参数
- 响应中使用 stop_reason 而非 finish_reason
- 响应内容为 ContentBlock 列表（text 类型）
"""

import time
from app.adapters.base_adapter import BaseVendorAdapter
from app.schemas.relay import RelayRequest, RelayResponse, ChatChoice, ChatMessage, TokenUsage


class AnthropicAdapter(BaseVendorAdapter):
    """Anthropic Claude API 适配器 — 支持 Claude Sonnet / Opus / Haiku 系列"""

    vendor_name = "anthropic"
    display_name = "Anthropic Claude"

    _prefixes = ["claude-"]

    _pricing = {
        "claude-sonnet-4-6": (3.00, 15.00),
        "claude-opus-4-7": (15.00, 75.00),
        "claude-haiku-4-5": (0.80, 4.00),
    }

    def model_to_vendor(self, model: str) -> str | None:
        for prefix in self._prefixes:
            if model.startswith(prefix):
                return model
        return None

    async def chat_completion(self, request: RelayRequest, api_key: str) -> RelayResponse:
        from anthropic import AsyncAnthropic

        client = AsyncAnthropic(api_key=api_key)
        start = time.monotonic()

        system_prompt = None
        user_messages = []
        for m in request.messages:
            if m.role == "system":
                system_prompt = m.content
            else:
                user_messages.append({"role": m.role, "content": m.content})

        kwargs = {
            "model": request.model,
            "messages": user_messages,
            "max_tokens": request.max_tokens,
            "temperature": request.temperature,
        }
        if system_prompt:
            kwargs["system"] = system_prompt
        if request.top_p < 1.0:
            kwargs["top_p"] = request.top_p
        if request.stop:
            kwargs["stop_sequences"] = request.stop

        response = await client.messages.create(**kwargs)
        latency_ms = (time.monotonic() - start) * 1000

        text_blocks = [b.text for b in response.content if b.type == "text"]
        content = "\n".join(text_blocks)

        prompt_tokens = response.usage.input_tokens if response.usage else 0
        completion_tokens = response.usage.output_tokens if response.usage else 0

        return RelayResponse(
            id=response.id,
            object="chat.completion",
            created=int(start),
            model=response.model,
            vendor="anthropic",
            choices=[ChatChoice(
                index=0,
                message=ChatMessage(role="assistant", content=content),
                finish_reason=response.stop_reason or "stop",
            )],
            usage=TokenUsage(
                prompt_tokens=prompt_tokens,
                completion_tokens=completion_tokens,
                total_tokens=prompt_tokens + completion_tokens,
            ),
            latency_ms=latency_ms,
        )

    def estimate_cost(self, response: RelayResponse) -> float:
        pricing = self._pricing.get(response.model, (0, 0))
        prompt_cost = (response.usage.prompt_tokens / 1_000_000) * pricing[0]
        completion_cost = (response.usage.completion_tokens / 1_000_000) * pricing[1]
        return round(prompt_cost + completion_cost, 6)
