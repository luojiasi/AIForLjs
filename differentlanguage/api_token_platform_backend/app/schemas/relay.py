"""
中继请求/响应的 Pydantic 数据模型

RelayRequest: 兼容 OpenAI Chat Completions API 格式，并扩展了 vendor 字段
RelayResponse: 平台统一的响应格式，所有厂商适配器都输出此格式
"""

from pydantic import BaseModel, Field
from typing import Optional


class ChatMessage(BaseModel):
    """聊天消息"""
    role: str = Field(..., examples=["user"])
    content: str = Field(..., examples=["Hello, how are you?"])


class RelayRequest(BaseModel):
    """
    统一的中继请求格式

    兼容 OpenAI Chat Completions API 格式，并支持以下扩展：
    - vendor: 手动指定厂商（可选，不指定则根据 model 自动识别）
    - top_p: 核采样参数
    - stop: 停止序列列表
    """
    model: str = Field(..., examples=["gpt-4o", "claude-sonnet-4-6"])
    messages: list[ChatMessage]
    max_tokens: int = Field(1024, ge=1, le=128000)
    temperature: float = Field(0.7, ge=0.0, le=2.0)
    top_p: float = Field(1.0, ge=0.0, le=1.0)
    stream: bool = False
    stop: Optional[list[str]] = None

    vendor: Optional[str] = Field(
        None,
        examples=["openai"],
        description="指定目标厂商，不填则根据 model 自动识别"
    )


class TokenUsage(BaseModel):
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0


class ChatChoice(BaseModel):
    index: int = 0
    message: ChatMessage
    finish_reason: str | None = "stop"


class RelayResponse(BaseModel):
    """
    统一的中继响应格式 — 兼容 OpenAI Chat Completions API

    所有厂商适配器的输出都标准化为此格式，保证上游应用的一致性。
    """
    id: str = ""
    object: str = "chat.completion"
    created: int = 0
    model: str = ""
    vendor: str = ""
    choices: list[ChatChoice] = []
    usage: TokenUsage = TokenUsage()
    cost: float = 0.0
    latency_ms: float = 0.0
