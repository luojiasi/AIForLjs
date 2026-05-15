"""
厂商适配器抽象基类

定义所有厂商适配器必须实现的标准接口。每个厂商适配器是一个"翻译官"，
负责将平台的统一请求格式转换为厂商专用格式，并将厂商响应标准化。

新增厂商只需3步：
1. 继承 BaseVendorAdapter 并实现抽象方法
2. 在 factory.py 中调用 register_adapter() 注册
3. 通过 Admin API 配置厂商密钥
"""

from abc import ABC, abstractmethod
from app.schemas.relay import RelayRequest, RelayResponse


class BaseVendorAdapter(ABC):
    """
    厂商适配器抽象基类

    必须实现的属性/方法:
        vendor_name: 厂商标识名（如 'openai', 'anthropic'）
        display_name: 显示名称（如 'OpenAI', 'Anthropic Claude'）
        chat_completion(): 执行 AI Chat 请求的核心方法

    可选重写的方法:
        model_to_vendor(): 模型名自动识别
        estimate_cost(): 费用估算
    """

    @property
    @abstractmethod
    def vendor_name(self) -> str:
        """厂商标识名，用于数据库索引和 API 参数（如 'openai', 'anthropic'）"""
        ...

    @property
    @abstractmethod
    def display_name(self) -> str:
        """显示名称，用于 UI 和管理后台展示（如 'OpenAI', 'Anthropic Claude'）"""
        ...

    @abstractmethod
    async def chat_completion(self, request: RelayRequest, api_key: str) -> RelayResponse:
        """
        调用厂商 API 执行聊天补全

        参数:
            request: 平台统一的中继请求对象
            api_key: 已解密的厂商 API Key（仅在内存中传递）

        返回:
            平台统一的 RelayResponse 对象

        每个适配器负责：
        - 将 RelayRequest 转换为厂商特定格式
        - 设置正确的认证头和请求体
        - 调用厂商 HTTP API（或 SDK）
        - 将厂商响应标准化为 RelayResponse
        """
        ...

    def model_to_vendor(self, model: str) -> str | None:
        """
        模型名称自动识别 — 判断请求的 model 是否属于本厂商

        参数:
            model: 请求中的模型名（如 'gpt-4o', 'claude-sonnet-4-6'）

        返回:
            厂商内部模型名（如匹配成功），或 None（不匹配）

        示例（OpenAI）:
            model='gpt-4o' → 返回 'gpt-4o'
            model='claude-sonnet' → 返回 None
        """
        return None

    def estimate_cost(self, response: RelayResponse) -> float:
        """
        根据 Token 用量估算本次调用的费用（单位：美元）

        参数:
            response: 已完成的 RelayResponse（含 usage 字段）

        返回:
            费用估算值（美元），默认返回 0.0

        子类可重写此方法，使用厂商定价表做精确计算。
        """
        return 0.0
