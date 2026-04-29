import 'dart:async';

enum HotkeyAction {
    toggleAppVisibility,   // 显示/隐藏窗口（系统级热键）
    closeWindow,           // 关闭窗口
    openSettings,          // 打开设置
    newTopic,              // 新建对话
    switchModel,           // 切换模型
    toggleLeftPanelAssistants, // 切换助手面板
    toggleLeftPanelTopics,     // 切换话题面板
}
/** ---
  整体架构：发布-订阅模式

  HotkeyProvider (按下快捷键)
    → _invoke("new_topic")
    → HotkeyEventBus.instance.fire(HotkeyAction.newTopic)
    → Stream 广播
    → desktop_home_page.dart 订阅 stream
    → 执行创建新对话

  --- */
///用于解耦快捷键的触发端和执行端
class HotkeyEventBus {
  HotkeyEventBus._();
  static final HotkeyEventBus instance = HotkeyEventBus._();

  final _controller = StreamController<HotkeyAction>.broadcast(); // 广播流
  Stream<HotkeyAction> get stream => _controller.stream;// 对外暴露只读流

  void fire(HotkeyAction action) {
    if (!_controller.isClosed) {
      _controller.add(action);
    }
  }

  void dispose() {
    _controller.close();
  }
}