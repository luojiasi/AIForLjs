"""
适配器工厂模块

管理所有厂商适配器的注册、发现和查找。

核心功能：
- register_adapter(): 注册适配器到全局注册表
- get_adapter(): 按厂商名获取适配器实例
- detect_vendor(): 根据模型名自动发现目标厂商
- get_all_adapters(): 获取所有已注册适配器

设计模式：工厂模式 + 注册表模式
新增厂商时，只需导入适配器类并调用 register_adapter() 即可。
"""

from app.adapters.base_adapter import BaseVendorAdapter
from app.adapters.openai_adapter import OpenAIAdapter
from app.adapters.anthropic_adapter import AnthropicAdapter

# 全局适配器注册表: vendor_name → BaseVendorAdapter 实例
_适配器注册表: dict[str, BaseVendorAdapter] = {}


def register_adapter(adapter_cls: type[BaseVendorAdapter]):
    """
    注册一个厂商适配器到全局注册表

    参数:
        adapter_cls: 适配器类（非实例），注册时会自动创建实例

    示例:
        register_adapter(OpenAIAdapter)
        register_adapter(AnthropicAdapter)
    """
    instance = adapter_cls()
    _适配器注册表[instance.vendor_name] = instance


register_adapter = register_adapter  # 保持向后兼容


def get_adapter(vendor_name: str) -> BaseVendorAdapter | None:
    """
    按厂商名查找适配器

    返回: 适配器实例，或 None（厂商未注册）
    """
    return _适配器注册表.get(vendor_name)


get_adapter = get_adapter


def detect_vendor(model: str) -> tuple[BaseVendorAdapter | None, str | None]:
    """
    根据请求的 model 名称自动检测目标厂商

    遍历所有已注册适配器的 model_to_vendor() 方法，
    返回第一个匹配的适配器及其内部模型名。

    返回:
        (适配器实例, 厂商内部模型名) — 如果都返回 None 表示无法识别
    """
    for adapter in _适配器注册表.values():
        internal = adapter.model_to_vendor(model)
        if internal:
            return adapter, internal
    return None, None


detect_vendor = detect_vendor


def get_all_adapters() -> dict[str, BaseVendorAdapter]:
    """
    获取所有已注册的厂商适配器

    返回: vendor_name → BaseVendorAdapter 实例的字典副本
    """
    return dict(_适配器注册表)


get_all_adapters = get_all_adapters


# ===== 注册内置适配器 =====
# 新增厂商时，只需在此处添加一行 register_adapter(NewAdapter)
register_adapter(OpenAIAdapter)       # OpenAI (GPT-4o, GPT-4o-mini, GPT-4-Turbo, O1, O3, O4)
register_adapter(AnthropicAdapter)    # Anthropic Claude (Sonnet, Opus, Haiku)
