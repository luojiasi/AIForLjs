import '../models/workflow_model.dart';

/// 工作流历史管理器 — 支持撤销/重做
///
/// 每次变异操作前调用 [record] 保存 Workflow 快照。
/// 最大保留 50 步历史，超出时从头部淘汰。
class WorkflowHistoryManager {
  final List<Workflow> _history = [];
  int _currentIndex = -1;
  static const int _maxDepth = 50;

  bool get canUndo => _currentIndex > 0;
  bool get canRedo => _currentIndex < _history.length - 1;
  int get depth => _history.length;

  /// 在变异操作前保存快照
  void record(Workflow state) {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(state.copyWith());
    _currentIndex = _history.length - 1;

    while (_history.length > _maxDepth) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  /// 撤销：返回上一个状态
  Workflow? undo() {
    if (!canUndo) return null;
    _currentIndex--;
    return _history[_currentIndex].copyWith();
  }

  /// 重做：返回下一个状态
  Workflow? redo() {
    if (!canRedo) return null;
    _currentIndex++;
    return _history[_currentIndex].copyWith();
  }

  /// 清空所有历史（加载新工作流时）
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}
