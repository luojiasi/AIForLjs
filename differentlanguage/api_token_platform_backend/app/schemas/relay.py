"""
中继请求/响应的 Pydantic 数据模型

RelayRequest: 兼容 OpenAI Chat Completions API 格式，并扩展了 vendor 字段
RelayResponse: 平台统一的响应格式，所有厂商适配器都输出此格式
"""

from pydantic import BaseModel, Field
from typing import Optional


class ChatMessage(BaseModel):
    """聊天消息"""
    role: str = Field(..., examples=["user"])                        # 角色：system / user / assistant
    content: str = Field(..., examples=["Hello, how are you?"])      # 消息内容


class RelayRequest(BaseModel):
    """
    统一的中继请求格式

    兼容 OpenAI Chat Completions API 格式，并支持以下扩展：
    - vendor: 手动指定厂商（可选，不指定则根据 model 自动识别）
    - top_p: 核采样参数
    - stop: 停止序列列表
    """
    model: str = Field(
        ..., examples=["gpt-4o", "claude-sonnet-4-6"]
    )  # 模型名（必填）
    messages: list[ChatMessage]  # 消息列表（必填）
    max_tokens: int = Field(
        1024, ge=1, le=128000
    )  # 最大输出 Token 数（1-128000）
    temperature: float = Field(
        0.7, ge=0.0, le=2.0
    )  # 温度参数（0.0-2.0，越高越随机）
    top_p: float = Field(
        1.0, ge=0.0, le=1.0
    )  # 核采样参数
    stream: bool = False  # 是否流式输出（当前版本暂不支持）
    stop: Optional[list[str]] = None  # 停止序列列表

    # === 平台扩展字段 ===
    vendor: Optional[str] = Field(
        None,
        examples=["openai"],
        description="指定目标厂商，不填则根据 model 自动识别"
    )


class RelayResponse(BaseModel):
    """
    统一的中继响应格式

    所有厂商适配器的输出都标准化为此格式，保证上游应用的一致性。
    """
    id: str                # 响应 ID（厂商返回）
    model: str             # 实际使用的模型名
    vendor: str            # 厂商名
    content: str           # AI 响应文本
    role: str = "assistant"
    usage: dict = Field(default_factory=lambda: {
        "prompt_tokens": 0,       # 输入 Token 数
        "completion_tokens": 0,   # 输出 Token 数
        "total_tokens": 0,        # 总 Token 数
    })
    finish_reason: str = "stop"   # 结束原因：stop / length / content_filter
    latency_ms: float = 0         # 请求延迟（毫秒）
