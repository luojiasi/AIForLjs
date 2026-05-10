"""
Anthropic Claude API 适配器

将平台统一请求转换为 Anthropic Messages API 格式并转发。
支持所有 Claude 系列模型。

Anthropic API 端点: POST https://api.anthropic.com/v1/messages
SDK: anthropic (AsyncAnthropic)

与 OpenAI 的关键差异:
- system 消息作为顶层参数传递，而非放在 messages 数组中
- max_tokens 是必填参数
- 响应中使用 stop_reason 而非 finish_reason
- 响应内容为 ContentBlock 列表（text 类型）
"""

from app.adapters.base_adapter import BaseVendorAdapter
from app.schemas.relay import RelayRequest, RelayResponse


class AnthropicAdapter(BaseVendorAdapter):
    """Anthropic Claude API 适配器 — 支持 Claude Sonnet / Opus / Haiku 系列"""

    vendor_name = "anthropic"
    display_name = "Anthropic Claude"

    # 模型前缀 — 自动识别 claude- 开头的模型
    _模型前缀列表 = ["claude-"]

    # 定价表 — 单位：美元/百万Token (输入价, 输出价)
    _定价表 = {
        "claude-sonnet-4-6": (3.00, 15.00),   # Claude Sonnet 4.6
        "claude-opus-4-7": (15.00, 75.00),    # Claude Opus 4.7 (旗舰)
        "claude-haiku-4-5": (0.80, 4.00),     # Claude Haiku 4.5 (轻量)
    }

    def model_to_vendor(self, model: str) -> str | None:
        """检查 model 名称是否匹配 Claude 模型前缀"""
        for 前缀 in self._模型前缀列表:
            if model.startswith(前缀):
                return model
        return None

    async def chat_completion(self, request: RelayRequest, api_key: str) -> RelayResponse:
        """调用 Anthropic Messages API"""
        import time
        from anthropic import AsyncAnthropic

        client = AsyncAnthropic(api_key=api_key)
        开始时间 = time.monotonic()

        # Anthropic 要求 system 消息作为顶层参数单独传递
        系统消息 = None
        用户消息列表 = []
        for m in request.messages:
            if m.role == "system":
                系统消息 = m.content
            else:
                用户消息列表.append({"role": m.role, "content": m.content})

        kwargs = {
            "model": request.model,
            "messages": 用户消息列表,
            "max_tokens": request.max_tokens,    # Anthropic 中 max_tokens 是必填的
            "temperature": request.temperature,
        }
        if 系统消息:
            kwargs["system"] = 系统消息
        if request.top_p < 1.0:
            kwargs["top_p"] = request.top_p
        if request.stop:
            kwargs["stop_sequences"] = request.stop  # Anthropic 使用 stop_sequences

        # 调用 Anthropic API
        response = await client.messages.create(**kwargs)
        延迟毫秒 = (time.monotonic() - 开始时间) * 1000

        # Anthropic 响应内容是 ContentBlock 列表，提取 text 类型的内容
        文本块列表 = [b.text for b in response.content if b.type == "text"]
        content = "\n".join(文本块列表)

        return RelayResponse(
            id=response.id,
            model=response.model,
            vendor="anthropic",
            content=content,
            finish_reason=response.stop_reason or "stop",  # Anthropic 使用 stop_reason
            usage={
                "prompt_tokens": response.usage.input_tokens if response.usage else 0,
                "completion_tokens": response.usage.output_tokens if response.usage else 0,
                "total_tokens": (
                    response.usage.input_tokens + response.usage.output_tokens
                ) if response.usage else 0,
            },
            latency_ms=延迟毫秒,
        )

    def estimate_cost(self, response: RelayResponse) -> float:
        """
        估算 Anthropic API 调用费用

        计算公式: (输入Token/1M) * 输入单价 + (输出Token/1M) * 输出单价
        """
        定价 = self._定价表.get(response.model, (0, 0))
        输入费用 = (response.usage["prompt_tokens"] / 1_000_000) * 定价[0]
        输出费用 = (response.usage["completion_tokens"] / 1_000_000) * 定价[1]
        return round(输入费用 + 输出费用, 6)
