# simplen8n — 完整设计与实现计划

> 目标：在 Flutter 中构建一个类 n8n 的可视化工作流自动化引擎
> 
> 参考架构：n8n (基于 TypeScript/Vue) → 我们使用 Dart/Flutter 实现

---

## 目录

1. [项目定位与核心目标](#1-项目定位与核心目标)
2. [n8n 架构深度解析（我们学什么）](#2-n8n-架构深度解析我们学什么)
3. [simplen8n 整体架构](#3-simplen8n-整体架构)
4. [模块一：DAG 工作流引擎（核心）](#4-模块一dag-工作流引擎核心)
5. [模块二：节点系统](#5-模块二节点系统)
6. [模块三：可视化画布编辑器](#6-模块三可视化画布编辑器)
7. [模块四：表达式引擎](#7-模块四表达式引擎)
8. [模块五：触发器系统](#8-模块五触发器系统)
9. [模块六：凭据管理](#9-模块六凭据管理)
10. [模块七：执行历史与日志](#10-模块七执行历史与日志)
11. [模块八：持久化与数据库](#11-模块八持久化与数据库)
12. [模块九：AI 集成](#12-模块九ai-集成)
13. [模块十：部署与打包](#13-模块十部署与打包)
14. [分阶段实施路线图](#14-分阶段实施路线图)

---

## 1. 项目定位与核心目标

### 1.1 定位

**simplen8n** 是一个在 Flutter 平台中运行的**可视化工流自动化引擎**，让用户通过拖拽节点、连线的方式创建自动化流程。它是 n8n 的 Dart/Flutter 精神移植版。

### 1.2 核心能力矩阵

| 能力 | n8n 原版 | simplen8n 目标 |
|------|----------|----------------|
| 可视化画布 | Vue Flow | vyuh_node_flow (Flutter) |
| 节点市场 | 400+ 内置、2000+ 社区 | 渐进式：先从 20 个核心节点开始 |
| 工作流执行 | Node.js 单进程 + Redis/Bull 队列 | Dart 单进程 + Isolate 并行 |
| 触发器 | Webhook / Cron / Polling | Webhook / Cron / Polling（全部 Dart 实现）|
| 表达式引擎 | `{{ $json.field }}` | 自研 Dart 模板引擎 |
| 凭据管理 | 加密 JSONB (TypeORM) | 加密 SQLite (sqflite + encrypt) |
| AI 节点 | OpenAI/DeepSeek 等 | 与现有 ai_chat_app 深度整合 |
| 跨平台 | Web 优先 | 移动 + 桌面 + Web 全平台（Flutter 天然优势）|

### 1.3 相对于 n8n 的差异化优势

1. **真正的全平台**：一份代码运行在 Android/iOS/Windows/macOS/Linux/Web
2. **移动端原生体验**：n8n 没有移动端，这是巨大优势
3. **与 AI Chat 无缝集成**：工作流节点可以直接调用 ai_chat_app 的 AI 能力
4. **Flutter 渲染性能**：Canvas 节点编辑器可达到 60fps+

---

## 2. n8n 架构深度解析（我们学什么）

### 2.1 n8n 的五层架构

```
┌─────────────────────────────────────────┐
│  Editor UI 层 (Vue 3 + Vue Flow)        │  ← 我们：Flutter + vyuh_node_flow
├─────────────────────────────────────────┤
│  CLI/Server 层 (Express + REST API)     │  ← 我们：Dart Shelf / 直接嵌入
├─────────────────────────────────────────┤
│  Core 引擎层 (WorkflowExecute)          │  ← 我们：simplen8n_engine
├─────────────────────────────────────────┤
│  Workflow 抽象层 (数据模型 + 表达式)     │  ← 我们：simplen8n_workflow
├─────────────────────────────────────────┤
│  Nodes 插件层 (400+ 集成节点)            │  ← 我们：simplen8n_nodes
└─────────────────────────────────────────┘
```

### 2.2 执行引擎核心设计（直接借鉴）

```
processRunExecutionData() 主循环：
  1. 从 nodeExecutionStack 弹出下一个节点
  2. 检查 waitingExecution (多输入聚合)
  3. 准备运行环境（表达式上下文 + 凭据注入）
  4. 执行节点逻辑 (+ 重试支持)
  5. 将输出传递给下游节点（压入执行栈）
  6. 重复直到栈空 或 遇到 Wait 节点暂停
```

### 2.3 节点间数据传递模型

```dart
/// 节点执行数据（对应 n8n 的 INodeExecutionData）
class NodeExecutionData {
  final Map<String, dynamic> json;   // JSON 数据
  final Uint8List? binary;           // 二进制数据
  final int? pairedItem;             // 数据溯源
  final String? error;               // 错误信息
}
```

### 2.4 n8n 的数据库设计要点

| 表 | 核心字段 | 说明 |
|----|---------|------|
| `workflow` | id, nodes(JSONB), connections(JSONB), active, settings | 工作流定义 |
| `execution` | id, workflow_id, status, data(JSONB), started_at, stopped_at | 执行记录 |
| `credential` | id, type, data(加密JSONB) | 凭据 |
| `settings` | key, value | 全局设置 |

---

## 3. simplen8n 整体架构

### 3.1 包结构设计

```
simplen8n/
├── simplen8n_workflow/     # 抽象数据模型层
│   ├── lib/src/
│   │   ├── models/
│   │   │   ├── workflow.dart          # Workflow 类
│   │   │   ├── node.dart              # INode 接口 + BaseNode
│   │   │   ├── connection.dart        # IConnection 接口
│   │   │   ├── node_types.dart        # NodeType 注册表
│   │   │   ├── node_parameters.dart   # 节点参数定义
│   │   │   └── workflow_settings.dart # 工作流设置
│   │   ├── expression/
│   │   │   ├── expression_engine.dart # 表达式引擎
│   │   │   ├── lexer.dart             # 词法分析器
│   │   │   ├── parser.dart            # 语法分析器
│   │   │   └── evaluator.dart         # 求值器
│   │   ├── serialization/
│   │   │   └── workflow_serializer.dart # JSON 序列化/反序列化
│   │   └── validation/
│   │       └── workflow_validator.dart  # 工作流校验（循环检测等）
│   └── pubspec.yaml
│
├── simplen8n_engine/       # 核心执行引擎层
│   ├── lib/src/
│   │   ├── execution/
│   │   │   ├── workflow_execute.dart   # 主执行引擎（核心！）
│   │   │   ├── node_executor.dart      # 节点执行器接口
│   │   │   ├── execution_context.dart  # 执行上下文
│   │   │   ├── execution_stack.dart    # 执行栈
│   │   │   └── execution_data.dart     # 执行数据结构
│   │   ├── triggers/
│   │   │   ├── trigger_manager.dart    # 触发器总管理器
│   │   │   ├── webhook_trigger.dart    # Webhook 触发器
│   │   │   ├── cron_trigger.dart       # Cron 定时触发器
│   │   │   └── polling_trigger.dart    # 轮询触发器
│   │   ├── queue/
│   │   │   ├── execution_queue.dart    # 执行队列
│   │   │   └── worker.dart             # 独立 Isolate Worker
│   │   └── credential/
│   │       ├── credential_manager.dart  # 凭据管理器
│   │       └── credential_store.dart   # 加密存储
│   └── pubspec.yaml
│
├── simplen8n_nodes/        # 节点插件层
│   ├── lib/src/
│   │   ├── base/
│   │   │   ├── trigger_node.dart       # 触发器节点基类
│   │   │   ├── action_node.dart        # 动作节点基类
│   │   │   └── logic_node.dart         # 逻辑/流程控制节点基类
│   │   ├── nodes/
│   │   │   ├── triggers/    # 触发器节点
│   │   │   │   ├── webhook_node.dart
│   │   │   │   ├── cron_node.dart
│   │   │   │   └── manual_trigger_node.dart
│   │   │   ├── http/        # HTTP 节点
│   │   │   │   ├── http_request_node.dart
│   │   │   │   └── graphql_node.dart
│   │   │   ├── data/        # 数据处理节点
│   │   │   │   ├── set_node.dart
│   │   │   │   ├── filter_node.dart
│   │   │   │   ├── sort_node.dart
│   │   │   │   └── aggregate_node.dart
│   │   │   ├── flow/        # 流程控制节点
│   │   │   │   ├── if_node.dart
│   │   │   │   ├── switch_node.dart
│   │   │   │   ├── loop_node.dart
│   │   │   │   ├── merge_node.dart
│   │   │   │   └── wait_node.dart
│   │   │   ├── code/        # 代码节点
│   │   │   │   ├── code_node.dart        # JavaScript
│   │   │   │   └── python_node.dart      # Python
│   │   │   ├── ai/          # AI 节点（与 ai_chat_app 整合）
│   │   │   │   ├── chat_node.dart
│   │   │   │   ├── embedding_node.dart
│   │   │   │   └── rag_node.dart
│   │   │   ├── database/    # 数据库节点
│   │   │   │   ├── sqlite_node.dart
│   │   │   │   └── postgres_node.dart
│   │   │   └── notification/ # 通知节点
│   │   │       ├── email_node.dart
│   │   │       └── push_node.dart
│   │   └── registry/
│   │       └── node_registry.dart       # 节点注册表（懒加载）
│   └── pubspec.yaml
│
├── simplen8n_ui/           # Flutter UI 层
│   ├── lib/
│   │   ├── canvas/
│   │   │   ├── workflow_canvas.dart     # 主画布（基于 vyuh_node_flow）
│   │   │   ├── node_widget.dart         # 自定义节点渲染
│   │   │   ├── connection_widget.dart   # 连线渲染
│   │   │   ├── minimap_widget.dart      # 小地图
│   │   │   └── canvas_toolbar.dart      # 画布工具栏
│   │   ├── panels/
│   │   │   ├── node_panel.dart          # 节点配置面板（抽屉）
│   │   │   ├── parameter_form.dart      # 动态参数表单
│   │   │   ├── node_palette.dart        # 节点拖拽面板
│   │   │   └── execution_panel.dart     # 执行日志面板
│   │   ├── editor/
│   │   │   ├── workflow_editor_page.dart # 工作流编辑主页
│   │   │   └── workflow_list_page.dart  # 工作流列表页
│   │   ├── state/
│   │   │   ├── workflow_provider.dart   # 工作流状态管理
│   │   │   ├── canvas_provider.dart     # 画布状态管理
│   │   │   └── execution_provider.dart  # 执行状态管理
│   │   └── widgets/
│   │       ├── draggable_node_card.dart # 可拖拽节点卡片
│   │       ├── connection_indicator.dart # 连接状态指示器
│   │       └── status_badge.dart        # 节点状态标签
│   └── pubspec.yaml
│
├── simplen8n_app/          # 应用入口 + 路由
│   ├── lib/
│   │   ├── main.dart                    # 入口
│   │   ├── routes.dart                  # 路由
│   │   ├── theme/
│   │   │   └── simplen8n_theme.dart     # 专属主题
│   │   └── services/
│   │       ├── storage_service.dart     # 持久化服务
│   │       └── notification_service.dart# 通知服务
│   └── pubspec.yaml
│
└── plan.md                 # 本文件
```

### 3.2 数据流全景图

```
用户操作              UI 层                    引擎层                 存储层
───────    ────────────────────    ────────────────────    ─────────────
            WorkflowCanvas
拖拽节点 ──► vyuh_node_flow
               │
               ▼
           CanvasProvider ◄────── Workflow 对象
               │                       │
连线、配参 ──► 更新 nodes/connections   │
               │                       │
               ▼                       ▼
点击执行 ──► ExecutionProvider ──► WorkflowExecute
                                      │
                                      ├── 拓扑排序节点
                                      ├── 逐节点执行
                                      ├── 表达式求值
                                      ├── 凭据注入
                                      └── 结果收集
                                          │
                                          ▼
                                    ExecutionStore ──► SQLite
```

---

## 4. 模块一：DAG 工作流引擎（核心）

### 4.1 数据结构

```dart
/// 工作流定义
class Workflow {
  final String id;
  final String name;
  final List<WorkflowNode> nodes;
  final Map<String, Map<String, List<ConnectionRule>>> connections;
  final WorkflowSettings settings;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// 节点定义
class WorkflowNode {
  final String id;
  final String name;
  final String type;         // 节点类型标识符
  final List<double> position; // [x, y]
  final Map<String, dynamic> parameters; // 节点参数
  final String? credentialId;
  final int? retryOnFail;
  final int? maxTries;
  final int? waitBetweenTries;
  final bool continueOnFail;
  final String? notes;
}

/// 连接定义
class ConnectionRule {
  final String node;    // 目标节点 ID
  final int index;      // 输出索引 → 输入索引映射
}

/// 执行栈条目
class ExecutionStackItem {
  final String nodeId;
  final int sourceIndex;
  final List<NodeExecutionData> data;
}
```

### 4.2 核心执行算法（processRunExecutionData）

```dart
class WorkflowExecute {
  final Workflow workflow;
  final ExecutionData executionData;
  
  // 执行栈
  final List<ExecutionStackItem> _stack = [];
  
  // 等待多输入聚合的节点
  final Map<String, Map<int, List<NodeExecutionData>>> _waitingExecution = {};
  
  /// 主执行循环
  Future<ExecutionResult> processRunExecutionData() async {
    // 1. 从触发器节点获取初始数据，压入执行栈
    _initializeStack();
    
    // 2. 主循环：弹出栈顶节点 → 执行 → 推送下游
    while (_stack.isNotEmpty) {
      final item = _stack.removeLast();
      
      // 2a. 准备执行上下文
      final context = ExecutionContext(
        workflow: workflow,
        nodeId: item.nodeId,
        inputData: item.data,
        credentialManager: credentialManager,
        expressionEvaluator: expressionEvaluator,
      );
      
      // 2b. 执行节点（含重试逻辑）
      final result = await _executeNodeWithRetry(context);
      
      // 2c. 检查是否需要等待（多输入节点/ Wait 节点）
      if (result.isWaiting) {
        executionData.waitTill = DateTime.now().add(result.waitDuration!);
        return ExecutionResult.paused(executionData);
      }
      
      // 2d. 将输出传递给下游节点
      _pushDownstream(item.nodeId, result.data);
    }
    
    return ExecutionResult.completed(executionData);
  }
  
  /// 推送数据到下游节点
  void _pushDownstream(String fromNodeId, List<NodeExecutionData> outputData) {
    final connections = workflow.connections[fromNodeId] ?? {};
    for (final entry in connections.entries) {
      final outputIndex = int.parse(entry.key);
      for (final rule in entry.value) {
        final targetNode = workflow.nodes.firstWhere((n) => n.id == rule.node);
        
        // 检查目标节点是否需要多个输入
        if (_isMultiInputNode(targetNode)) {
          _waitingExecution
            .putIfAbsent(rule.node, () => {})
            .putIfAbsent(rule.index, () => [])
            .addAll(outputData);
          
          // 检查是否所有输入都已到达
          if (_allInputsReady(rule.node)) {
            final mergedData = _mergeInputs(rule.node);
            _stack.add(ExecutionStackItem(
              nodeId: rule.node,
              data: mergedData,
            ));
            _waitingExecution.remove(rule.node);
          }
        } else {
          _stack.add(ExecutionStackItem(
            nodeId: rule.node,
            data: outputData,
          ));
        }
      }
    }
  }
}
```

### 4.3 拓扑排序与并行执行

```dart
/// 对 DAG 进行拓扑排序，识别哪些节点可以并行执行
class DagSorter {
  /// 返回执行层级：每一层内的节点可以并行执行
  List<Set<String>> topologicalLevels(
    Workflow workflow,
  ) {
    final inDegree = <String, int>{};
    final adjacency = <String, List<String>>{};
    
    // 构建图的入度表和邻接表
    for (final node in workflow.nodes) {
      inDegree[node.id] ??= 0;
      adjacency[node.id] ??= [];
    }
    for (final entry in workflow.connections.entries) {
      final fromNode = entry.key;
      for (final rules in entry.value.values) {
        for (final rule in rules) {
          adjacency[fromNode]?.add(rule.node);
          inDegree[rule.node] = (inDegree[rule.node] ?? 0) + 1;
        }
      }
    }
    
    // BFS 分层
    final levels = <Set<String>>[];
    var queue = inDegree.entries
      .where((e) => e.value == 0)
      .map((e) => e.key)
      .toSet();
    
    while (queue.isNotEmpty) {
      levels.add(queue);
      final nextQueue = <String>{};
      for (final node in queue) {
        for (final neighbor in adjacency[node] ?? []) {
          inDegree[neighbor] = inDegree[neighbor]! - 1;
          if (inDegree[neighbor] == 0) {
            nextQueue.add(neighbor);
          }
        }
      }
      queue = nextQueue;
    }
    
    return levels;
  }
}
```

### 4.4 Isolate 并行 Worker 模式

```dart
/// 每个 Isolate 中运行的 Worker 逻辑
class WorkflowWorker {
  Future<void> run() async {
    final receivePort = ReceivePort();
    
    Isolate.spawn(_workerEntry, receivePort.sendPort);
    
    // 主线程发送任务
    final sendPort = await receivePort.first as SendPort;
    sendPort.send(WorkflowTask(workflowId: 'xxx', triggerData: {...}));
    
    // 接收结果
    receivePort.listen((result) {
      if (result is ExecutionResult) {
        // 持久化结果、触发通知等
      }
    });
  }
  
  static void _workerEntry(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    
    port.listen((message) async {
      if (message is WorkflowTask) {
        final engine = WorkflowExecute(/* ... */);
        final result = await engine.processRunExecutionData();
        sendPort.send(result);
      }
    });
  }
}
```

### 4.5 循环检测（防止无限循环）

```dart
class CycleDetector {
  /// 检测有向图中是否存在环（DFS 三色标记法）
  bool hasCycle(Map<String, List<String>> adjacency) {
    final WHITE = 0, GRAY = 1, BLACK = 2;
    final color = <String, int>{};
    
    bool dfsVisit(String node) {
      color[node] = GRAY;
      for (final neighbor in adjacency[node] ?? []) {
        if (color[neighbor] == GRAY) return true;
        if (color[neighbor] == WHITE && dfsVisit(neighbor)) return true;
      }
      color[node] = BLACK;
      return false;
    }
    
    if (adjacency.keys.any((n) => color.putIfAbsent(n, () => WHITE) == WHITE && dfsVisit(n))) {
      return true;
    }
    return false;
  }
}
```

---

## 5. 模块二：节点系统

### 5.1 节点类型枚举

```dart
enum NodeCategory {
  trigger,     // ⚡ 触发器 — 工作流起点
  action,      // 🔧 动作 — 执行操作
  logic,       // 🔀 逻辑 — 流程控制
  data,        // 📊 数据 — 转换处理
  ai,          // 🤖 AI — 智能节点
  database,    // 🗄️ 数据库
  notification,// 🔔 通知
  code,        // 💻 代码
  file,        // 📁 文件
  utility,     // 🛠️ 工具
}
```

### 5.2 节点接口设计

```dart
/// 所有节点必须实现的接口
abstract class INodeType {
  /// 唯一类型标识符
  String get type;
  
  /// 显示名称（支持国际化）
  String get displayName;
  
  /// 节点分类
  NodeCategory get category;
  
  /// 节点图标
  IconData get icon;
  
  /// 输入端口定义
  List<NodePort> get inputs;
  
  /// 输出端口定义
  List<NodePort> get outputs;
  
  /// 参数 Schema（用于动态生成配置表单）
  List<ParameterSchema> get parameterSchema;
  
  /// 执行节点逻辑
  Future<List<NodeExecutionData>> execute(ExecutionContext context);
  
  /// 节点颜色
  Color get color;
}

/// 动态参数 Schema
class ParameterSchema {
  final String name;
  final String displayName;
  final ParameterType type; // string, number, boolean, select, code, credential, expression
  final dynamic defaultValue;
  final bool required;
  final String? description;
  final List<String>? options;     // for select type
  final List<ParameterSchema>? fields; // for nested objects
}
```

### 5.3 节点注册表（插件系统）

```dart
/// 全局节点注册表 —— 懒加载模式
class NodeRegistry {
  static final NodeRegistry instance = NodeRegistry._();
  NodeRegistry._();
  
  final Map<String, INodeType Function()> _factories = {};
  
  void register(INodeType Function() factory) {
    final instance = factory();
    _factories[instance.type] = factory;
  }
  
  INodeType create(String type) {
    final factory = _factories[type];
    if (factory == null) throw UnknownNodeTypeException(type);
    return factory();
  }
  
  List<INodeType> get allTypes => _factories.values.map((f) => f()).toList();
  
  List<INodeType> getByCategory(NodeCategory category) =>
    allTypes.where((n) => n.category == category).toList();
}
```

### 5.4 首批 20 个必须实现的节点

| 序号 | 节点名 | 分类 | 功能 |
|------|--------|------|------|
| 1 | Manual Trigger | trigger | 手动点击触发 |
| 2 | Webhook | trigger | HTTP 请求触发 |
| 3 | Cron/Schedule | trigger | 定时触发 |
| 4 | HTTP Request | action | 发送 HTTP 请求 |
| 5 | Set | data | 设置/修改数据字段 |
| 6 | Filter | logic | 条件过滤数据 |
| 7 | Switch | logic | 多分支路由 |
| 8 | IF | logic | 条件判断 |
| 9 | Merge | logic | 合并多路数据 |
| 10 | Loop | logic | 遍历数组 |
| 11 | Wait | logic | 等待/暂停 |
| 12 | Code (JS) | code | 执行 JavaScript |
| 13 | Code (Python) | code | 执行 Python |
| 14 | AI Chat | ai | 调用 LLM 聊天 |
| 15 | SQLite | database | 本地数据库操作 |
| 16 | Email | notification | 发送邮件 |
| 17 | Push Notification | notification | 推送通知 |
| 18 | Read File | file | 读取文件 |
| 19 | Write File | file | 写入文件 |
| 20 | JSON Transform | data | JSON 数据转换 |

---

## 6. 模块三：可视化画布编辑器

### 6.1 技术选型：vyuh_node_flow

**为什么选 vyuh_node_flow 而不是 graph_edit / fldraw：**

| 对比项 | vyuh_node_flow | graph_edit | fldraw |
|--------|---------------|------------|--------|
| Node Flow 专精度 | ⭐⭐⭐ 最佳 | ⭐⭐ 中等 | ⭐ 通用画布 |
| n8n 风格适配 | ✅ 直接匹配 | ⚠️ 需大量改造 | ❌ 定位不同 |
| 端口系统 | ✅ 完整 | ✅ 完整 | ❌ 无 |
| 序列化 | ✅ JSON 原生 | ⚠️ 部分 | ✅ 完整 |
| 性能 (100+ 节点) | ✅ 高性能 | ⚠️ 未验证 | ✅ 高性能 |
| 社区活跃度 | 169★, 持续更新 | 较低 | 新项目 |
| MIT 许可证 | ✅ | ✅ | ✅ |

### 6.2 画布架构

```dart
class WorkflowCanvas extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 主画布 — vyuh_node_flow 的核心组件
          NodeFlowEditor<WorkflowNodeData>(
            controller: _canvasController,
            nodes: _nodes,
            connections: _connections,
            // 自定义节点渲染
            nodeBuilder: (context, node) => Simplen8nNodeWidget(node: node),
            // 连接端口样式
            portBuilder: (context, port) => Simplen8nPortWidget(port: port),
            // 连线样式（贝塞尔曲线）
            connectionStyle: ConnectionStyle.bezier,
            // 工具栏
            floatingTools: _buildToolbar(),
          ),
          
          // 2. 左下角小地图
          Positioned(
            left: 16, bottom: 16,
            child: MinimapWidget(controller: _canvasController),
          ),
          
          // 3. 右上角执行按钮
          Positioned(
            right: 16, top: 16,
            child: ExecuteButton(onPressed: _executeWorkflow),
          ),
        ],
      ),
      // 4. 左侧节点面板（可收起）
      drawer: NodePalette(
        onDragNode: _addNodeToCanvas,
      ),
      // 5. 右侧配置面板（选中节点时显示）
      endDrawer: NodeConfigPanel(
        node: _selectedNode,
        onSave: _updateNodeParameters,
      ),
      // 6. 底部执行日志面板
      bottomSheet: ExecutionLogPanel(
        logs: _executionLogs,
      ),
    );
  }
}
```

### 6.3 自定义节点渲染

```dart
class Simplen8nNodeWidget extends StatelessWidget {
  final WorkflowNodeData node;
  
  // 颜色映射（与 n8n 保持一致）
  static const _categoryColors = {
    NodeCategory.trigger: Color(0xFF0066FF),     // 蓝
    NodeCategory.action: Color(0xFF6B46EF),      // 紫
    NodeCategory.logic: Color(0xFFF59E0B),       // 橙
    NodeCategory.data: Color(0xFF10B981),        // 绿
    NodeCategory.ai: Color(0xFFEC4899),          // 粉
    NodeCategory.notification: Color(0xFFEF4444), // 红
  };
  
  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[node.category] ?? Colors.grey;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: node.isExecuting ? Colors.green : color,
          width: node.isSelected ? 2 : 1,
        ),
      ),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 节点头部（图标 + 名称 + 状态）
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(node.icon, size: 16, color: color),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(node.name, overflow: TextOverflow.ellipsis),
                ),
                if (node.status == NodeStatus.executing)
                  _PulsingDot(),
                if (node.status == NodeStatus.error)
                  Icon(Icons.error, color: Colors.red, size: 16),
              ],
            ),
            // 节点副文本（显示关键参数摘要）
            if (node.parameterSummary != null) ...[
              SizedBox(height: 4),
              Text(
                node.parameterSummary!,
                style: TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 6.4 React Flow ↔ n8n 格式转换

```dart
/// vyuh_node_flow 的节点/连线 与 simplen8n Workflow 互转
class WorkflowFormatConverter {
  /// 从画布状态转换到 Workflow 对象
  static Workflow fromCanvas({
    required List<NodeFlowNode> canvasNodes,
    required List<NodeFlowConnection> canvasConnections,
    required String workflowId,
  }) {
    final nodes = canvasNodes.map((cn) => WorkflowNode(
      id: cn.id,
      name: cn.data['name'] as String,
      type: cn.data['type'] as String,
      position: [cn.position.x, cn.position.y],
      parameters: cn.data['parameters'] as Map<String, dynamic>? ?? {},
    )).toList();
    
    final connections = <String, Map<String, List<ConnectionRule>>>{};
    for (final cc in canvasConnections) {
      connections
        .putIfAbsent(cc.sourceNodeId, () => {})
        .putIfAbsent(cc.sourcePortId, () => [])
        .add(ConnectionRule(
          node: cc.targetNodeId,
          index: int.tryParse(cc.targetPortId) ?? 0,
        ));
    }
    
    return Workflow(
      id: workflowId,
      nodes: nodes,
      connections: connections,
      // ...
    );
  }
  
  /// 从 Workflow 对象恢复到画布状态
  static ({List<NodeFlowNode> nodes, List<NodeFlowConnection> connections}) toCanvas(
    Workflow workflow,
  ) {
    // 反向转换...
  }
}
```

### 6.5 画布交互功能清单

- [ ] 拖拽节点到画布（从左侧 Palette）
- [ ] 从节点端口拖出连线
- [ ] 删除节点 / 连线（选中 + Delete 键 / 右键菜单）
- [ ] 撤销 / 重做（Command 模式）
- [ ] 复制 / 粘贴节点（Ctrl+C / Ctrl+V）
- [ ] 框选多个节点
- [ ] 自动布局（dagre 算法）
- [ ] 画布缩放（鼠标滚轮 / 捏合手势）
- [ ] 画布平移（拖拽空白区域）
- [ ] 节点右键菜单（删除/复制/执行此节点）
- [ ] 节点拖拽时吸附网格
- [ ] 画布导出为图片
- [ ] 工作流导入/导出 JSON 文件

---

## 7. 模块四：表达式引擎

### 7.1 语法设计

```dart
// 参考 n8n 的模板语法，支持以下功能：

// 基本变量引用
"{{ $json.user.name }}"
"{{ $json.body.data[0].id }}"

// 跨节点引用
"{{ $node['HTTP Request'].json.data }}"

// 表达式运算
"{{ $json.price * $json.quantity }}"
"{{ $json.name ?? 'Unknown' }}"
"{{ $json.age > 18 ? 'Adult' : 'Child' }}"

// 内置函数
"{{ $now() }}"
"{{ $randomInt(1, 100) }}"
"{{ $formatDate($json.createdAt, 'yyyy-MM-dd') }}"
```

### 7.2 词法分析器

```dart
/// Token 类型
enum TokenType {
  // 分隔符
  openBrace, closeBrace,         // {{  }}
  openParen, closeParen,         // ( )
  openBracket, closeBracket,     // [ ]
  dot, comma, colon, question,   // . , : ?
  
  // 运算符
  plus, minus, multiply, divide, modulo,
  equals, notEquals, greater, less, greaterEqual, lessEqual,
  and, or, not,
  nullCoalescing,                // ??
  ternaryThen, ternaryElse,      // ? :
  
  // 字面量
  identifier, stringLiteral, numberLiteral,
  boolLiteral, nullLiteral,
  
  // 特殊
  dollar,                        // $
  eof,
}

/// 词法分析器
class ExpressionLexer {
  final String source;
  int _pos = 0;
  
  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < source.length) {
      if (_match('{{')) {
        tokens.add(Token(TokenType.openBrace));
        continue;
      }
      // ... 逐字符解析
    }
    return tokens;
  }
}
```

### 7.3 求值器

```dart
class ExpressionEvaluator {
  final WorkflowDataProxy dataProxy;
  
  /// 求值模板字符串（可能包含多个 {{ }} 表达式）
  String evaluateTemplate(String template) {
    return template.replaceAllMapped(
      RegExp(r'\{\{(.+?)\}\}'),
      (match) {
        final expression = match.group(1)!.trim();
        final result = evaluate(expression);
        return result.toString();
      },
    );
  }
  
  /// 求值单个表达式
  dynamic evaluate(String expression) {
    final lexer = ExpressionLexer(expression);
    final tokens = lexer.tokenize();
    final parser = ExpressionParser(tokens);
    final ast = parser.parse();
    return _evalNode(ast);
  }
  
  dynamic _evalNode(AstNode node) {
    switch (node) {
      case LiteralNode(:final value):
        return value;
      case IdentifierNode(:final name):
        return dataProxy.resolve(name);  // $json, $node, $workflow, etc.
      case BinaryOpNode(:final left, :final op, :final right):
        return _applyOp(op, _evalNode(left), _evalNode(right));
      case TernaryNode(:final condition, :final thenExpr, :final elseExpr):
        return _evalNode(condition) == true ? _evalNode(thenExpr) : _evalNode(elseExpr);
      case MemberAccessNode(:final object, :final member):
        return _resolveMember(_evalNode(object), member);
      case IndexAccessNode(:final object, :final index):
        return _evalNode(object)[_evalNode(index)];
      case FunctionCallNode(:final name, :final args):
        return _callBuiltin(name, args.map(_evalNode).toList());
    }
  }
}

/// 数据代理层 — 提供 $json, $node, $workflow, $execution 等上下文变量
class WorkflowDataProxy {
  final Map<String, dynamic> currentJson;
  final Map<String, dynamic> allNodeOutputs;
  final Workflow workflow;
  
  dynamic resolve(String path) {
    // $json.field.subfield
    if (path.startsWith('json.')) {
      return _deepGet(currentJson, path.substring(5));
    }
    // $node['NodeName'].json.field
    if (path.startsWith("node['")) {
      final match = RegExp(r"node\['(.+?)'\]\.(.+)").firstMatch(path);
      if (match != null) {
        final nodeData = allNodeOutputs[match.group(1)!];
        return _deepGet(nodeData, match.group(2)!);
      }
    }
    // $workflow.id
    if (path == 'workflow.id') return workflow.id;
    // ...
    return null;
  }
}
```

---

## 8. 模块五：触发器系统

### 8.1 架构

```dart
/// 触发器管理器：管理所有激活工作流的触发器生命周期
class TriggerManager {
  final List<ActiveTrigger> _activeTriggers = [];
  
  /// 激活工作流的所有触发器
  Future<void> activateWorkflow(Workflow workflow) async {
    final triggerNodes = workflow.nodes
      .where((n) => nodeRegistry.create(n.type).category == NodeCategory.trigger);
    
    for (final node in triggerNodes) {
      final trigger = _createTrigger(node);
      await trigger.initialize();
      trigger.onTriggered.listen((data) {
        // 触发执行
        executionQueue.enqueue(workflow, data);
      });
      await trigger.start();
      _activeTriggers.add(ActiveTrigger(workflowId: workflow.id, trigger: trigger));
    }
  }
  
  /// 停用工作流
  Future<void> deactivateWorkflow(String workflowId) async {
    final triggers = _activeTriggers.where((t) => t.workflowId == workflowId);
    for (final t in triggers) {
      await t.trigger.stop();
    }
    _activeTriggers.removeWhere((t) => t.workflowId == workflowId);
  }
}
```

### 8.2 Webhook 触发器

```dart
class WebhookTrigger implements ITrigger {
  final String httpMethod;  // GET, POST, PUT, DELETE
  final String path;        // 自动生成的唯一路径
  final Map<String, dynamic>? responseData;
  
  late final HttpServer _server;
  final _triggerController = StreamController<List<NodeExecutionData>>();
  
  @override
  Stream<List<NodeExecutionData>> get onTriggered => _triggerController.stream;
  
  @override
  Future<void> initialize() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, _findAvailablePort());
    _server.listen((request) {
      if (request.method == httpMethod && request.uri.path == '/webhook/$path') {
        // 解析请求体、headers、query params
        final data = await _parseRequest(request);
        _triggerController.add(data);
        // 返回响应
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(responseData ?? {'success': true}))
          ..close();
      }
    });
  }
}
```

### 8.3 Cron 触发器

```dart
class CronTrigger implements ITrigger {
  final String cronExpression;  // 如 '0 9 * * *'
  final String timezone;
  
  late final CronParser _parser;
  Timer? _timer;
  final _triggerController = StreamController<List<NodeExecutionData>>();
  
  @override
  Future<void> start() async {
    _scheduleNext();
  }
  
  void _scheduleNext() {
    final nextTime = _parser.next(DateTime.now());
    final delay = nextTime.difference(DateTime.now());
    
    _timer = Timer(delay, () {
      _triggerController.add([NodeExecutionData(json: {'timestamp': DateTime.now().toIso8601String()})]);
      _scheduleNext();  // 递归调度下一次
    });
  }
}
```

### 8.4 Polling 触发器

```dart
class PollingTrigger implements ITrigger {
  final Duration interval;  // 轮询间隔
  
  Timer? _timer;
  
  @override
  Future<void> start() async {
    _timer = Timer.periodic(interval, (_) {
      _triggerController.add([NodeExecutionData(json: {'polledAt': DateTime.now().toIso8601String()})]);
    });
  }
}
```

---

## 9. 模块六：凭据管理

### 9.1 安全架构

```dart
/// 凭据存储 — 加密保存 API Key / 密码等敏感信息
class CredentialStore {
  final FlutterSecureStorage _secureStorage;  // iOS Keychain / Android EncryptedSharedPreferences
  final Box<String> _encryptedBox;            // Hive 加密盒子（桌面端）
  
  /// 保存凭据
  Future<void> saveCredential(Credential credential) async {
    final jsonStr = jsonEncode(credential.toJson());
    final encrypted = _encrypt(jsonStr, _deriveKey());
    
    if (Platform.isAndroid || Platform.isIOS) {
      await _secureStorage.write(key: credential.id, value: encrypted);
    } else {
      await _encryptedBox.put(credential.id, encrypted);
    }
  }
  
  /// 读取凭据（仅在执行工作流时解密到内存）
  Future<Credential> getCredential(String id) async {
    final encrypted = Platform.isAndroid || Platform.isIOS
      ? await _secureStorage.read(key: id)
      : _encryptedBox.get(id);
    
    if (encrypted == null) throw CredentialNotFoundException(id);
    
    final jsonStr = _decrypt(encrypted, _deriveKey());
    return Credential.fromJson(jsonDecode(jsonStr));
  }
  
  String _deriveKey() {
    // 从设备唯一标识 + 应用签名派生 AES-256 密钥
    // 硬件隔离的安全密钥派生
  }
  
  String _encrypt(String plaintext, String key) {
    // AES-256-GCM 加密
  }
  
  String _decrypt(String ciphertext, String key) {
    // AES-256-GCM 解密
  }
}
```

### 9.2 凭据类型

```dart
enum CredentialType {
  apiKey,       // API Key (Bearer Token)
  basicAuth,    // 用户名 + 密码
  oauth2,       // OAuth 2.0 (含刷新令牌)
  apiToken,     // 服务 Token
  database,     // 数据库连接字符串
  email,        // 邮箱 SMTP
  custom,       // 自定义
}

class Credential {
  final String id;
  final String name;
  final CredentialType type;
  final Map<String, dynamic> data;  // 加密的核心数据
  final DateTime createdAt;
}
```

---

## 10. 模块七：执行历史与日志

### 10.1 执行状态机

```
          ┌─────────┐
          │  queued │  ← 已入队，等待 Worker 取走
          └────┬────┘
               │
          ┌────▼────┐
          │ running │  ← Worker 正在执行
          └────┬────┘
               │
     ┌─────────┼─────────┐
     │         │         │
  ┌──▼──┐  ┌──▼───┐  ┌──▼───┐
  │paused│  │error │  │success│
  └──┬───┘  └──────┘  └──────┘
     │
  ┌──▼──┐
  │resumed│ → 回到 running
  └──────┘
```

### 10.2 执行记录数据模型

```dart
class Execution {
  final String id;
  final String workflowId;
  final String workflowName;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final Map<String, NodeExecutionResult> nodeResults;  // 每个节点的执行结果
  final String? error;                                   // 全局错误
  final int? durationMs;                                 // 总耗时
}

class NodeExecutionResult {
  final String nodeId;
  final NodeExecutionStatus status;
  final List<NodeExecutionData>? output;
  final String? error;
  final int? durationMs;
  final int? retryCount;
}
```

### 10.3 日志面板 UI

```dart
class ExecutionLogPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          // 标签栏：Logs | Errors | Output
          TabBar(tabs: [
            Tab(text: 'Logs (${logs.length})'),
            Tab(text: 'Errors (${errorCount})'),
            Tab(text: 'Output'),
          ]),
          // 日志列表
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, i) {
                final log = logs[i];
                return ListTile(
                  leading: _statusIcon(log.level),
                  title: Text(log.message),
                  subtitle: Text('Node: ${log.nodeName} · ${_formatTime(log.timestamp)}'),
                  trailing: Text('${log.durationMs}ms'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 11. 模块八：持久化与数据库

### 11.1 技术选型

| 场景 | 技术 | 说明 |
|------|------|------|
| 工作流定义 | SQLite (sqflite/drift) | 结构化存储，JSONB 存节点/连线 |
| 执行记录 | SQLite | 按 workflow_id 索引，定期清理 |
| 凭据 | FlutterSecureStorage + Hive | 加密存储 |
| 应用设置 | SharedPreferences | 简单键值对 |
| 节点模板 | JSON 文件/Asset | 预置节点定义 |
| 导出/导入 | JSON 文件 | 跨设备迁移 |

### 11.2 SQLite 表设计

```sql
-- 工作流表
CREATE TABLE workflows (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  nodes TEXT NOT NULL,        -- JSON 字符串
  connections TEXT NOT NULL,  -- JSON 字符串
  settings TEXT,              -- JSON 字符串
  active INTEGER DEFAULT 0,  -- 是否激活
  version INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- 执行记录表
CREATE TABLE executions (
  id TEXT PRIMARY KEY,
  workflow_id TEXT NOT NULL,
  workflow_name TEXT NOT NULL,
  status TEXT NOT NULL,
  trigger_type TEXT,
  node_results TEXT,          -- JSON 字符串
  error TEXT,
  started_at TEXT NOT NULL,
  stopped_at TEXT,
  duration_ms INTEGER,
  FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE
);

-- 执行日志表
CREATE TABLE execution_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  execution_id TEXT NOT NULL,
  node_id TEXT NOT NULL,
  node_name TEXT NOT NULL,
  level TEXT NOT NULL,        -- info, warn, error, debug
  message TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  duration_ms INTEGER,
  FOREIGN KEY (execution_id) REFERENCES executions(id) ON DELETE CASCADE
);

-- 索引
CREATE INDEX idx_executions_workflow ON executions(workflow_id);
CREATE INDEX idx_executions_status ON executions(status);
CREATE INDEX idx_executions_started ON executions(started_at);
CREATE INDEX idx_logs_execution ON execution_logs(execution_id);
```

### 11.3 Repository 模式

```dart
/// 工作流存储
class WorkflowRepository {
  final Database _db;
  
  Future<List<Workflow>> findAll() async {
    final rows = await _db.query('workflows', orderBy: 'updated_at DESC');
    return rows.map(_fromRow).toList();
  }
  
  Future<Workflow?> findById(String id) async {
    final rows = await _db.query('workflows', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }
  
  Future<void> save(Workflow workflow) async {
    await _db.insert(
      'workflows',
      _toRow(workflow),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> delete(String id) async {
    await _db.delete('workflows', where: 'id = ?', whereArgs: [id]);
  }
}
```

---

## 12. 模块九：AI 集成

### 12.1 与 ai_chat_app 的深度整合

```dart
/// AI Chat 节点 —— 调用 ai_chat_app 现有的 AI 能力
class AIChatNode extends ActionNode {
  @override
  String get type => 'ai_chat';
  
  @override
  List<ParameterSchema> get parameterSchema => [
    ParameterSchema(
      name: 'model',
      displayName: 'Model',
      type: ParameterType.select,
      options: ['claude-opus-4-7', 'claude-sonnet-4-6', 'deepseek-v4'],
      defaultValue: 'claude-sonnet-4-6',
    ),
    ParameterSchema(
      name: 'systemPrompt',
      displayName: 'System Prompt',
      type: ParameterType.code,
      defaultValue: '',
    ),
    ParameterSchema(
      name: 'userMessage',
      displayName: 'User Message',
      type: ParameterType.expression,
      defaultValue: '{{ $json.text }}',
    ),
    ParameterSchema(
      name: 'temperature',
      displayName: 'Temperature',
      type: ParameterType.number,
      defaultValue: 0.7,
    ),
  ];
  
  @override
  Future<List<NodeExecutionData>> execute(ExecutionContext context) async {
    final userMessage = context.evaluateExpression(
      context.node.parameters['userMessage'],
    );
    
    // 调用现有的 AI Service
    final aiService = AIService.instance;
    final response = await aiService.chat(
      model: context.node.parameters['model'],
      messages: [
        ChatMessage(role: 'system', content: context.node.parameters['systemPrompt']),
        ChatMessage(role: 'user', content: userMessage),
      ],
      temperature: context.node.parameters['temperature'],
    );
    
    return [NodeExecutionData(json: {'response': response.content, 'tokens': response.usage})];
  }
}

/// RAG 节点 —— 检索增强生成
class RAGNode extends ActionNode { /* ... */ }

/// Embedding 节点 —— 文本向量化
class EmbeddingNode extends ActionNode { /* ... */ }
```

---

## 13. 模块十：部署与打包

### 13.1 两种运行模式

| 模式 | 描述 | 适用场景 |
|------|------|---------|
| **嵌入式** | 引擎直接在 Flutter 进程中运行 | 移动端、轻量桌面端 |
| **独立服务模式** | 引擎作为 Dart 后台服务运行，UI 通过网络连接 | 团队协作、生产环境 |

### 13.2 独立服务模式架构

```
┌─────────────────────┐     HTTP/WebSocket     ┌─────────────────────┐
│  Flutter UI 客户端   │ ◄──────────────────────► │  Dart Shelf Server  │
│  (任何平台)          │                          │  - REST API        │
│                      │                          │  - Webhook 接收     │
│                      │                          │  - 工作流执行       │
│                      │                          │  - 凭据管理         │
└─────────────────────┘                          └─────────┬───────────┘
                                                           │
                                                      SQLite/PostgreSQL
```

### 13.3 工作流市场（远期目标）

- 社区可分享、导入工作流模板
- 评分和评论系统
- 官方认证节点和模板

---

## 14. 分阶段实施路线图

### Phase 0：原型验证（2-3 周）

| 任务 | 产出 | 优先级 |
|------|------|--------|
| 集成 vyuh_node_flow 到 Flutter | 可运行的空画布 | P0 |
| 实现根 Workflow 数据模型 | Workflow 类 + JSON 序列化 | P0 |
| 实现 3 个核心节点（Manual / HTTP / Set） | 最小可行节点 | P0 |
| 实现最简单的执行引擎（线性执行） | 串行执行 3 个节点 | P0 |
| 实现基本画布交互（拖拽 + 连线 + 配置面板） | 能搭建并运行一个简单工作流 | P0 |

### Phase 1：核心引擎（3-4 周）

| 任务 | 产出 | 优先级 |
|------|------|--------|
| DAG 拓扑排序 | 并行层级识别 | P0 |
| 完整 processRunExecutionData | 支持分支、合并 | P0 |
| 循环检测 | 拒绝有环图 | P0 |
| 表达式引擎（lexer + parser + evaluator） | `{{ $json.xxx }}` 可用 | P0 |
| 多输入聚合（Merge 节点） | waitingExecution 机制 | P1 |
| 节点重试逻辑 | maxTries / waitBetweenTries | P1 |
| 凭据加密存储 | 安全保管 API Key | P1 |

### Phase 2：节点扩展（3-4 周）

| 任务 | 数量 | 优先级 |
|------|------|--------|
| HTTP 节点（完整 REST/GraphQL） | 2 | P0 |
| 流程控制节点（IF/Switch/Loop/Merge/Wait） | 5 | P0 |
| 数据处理节点（Set/Filter/Sort/Aggregate/JSON） | 5 | P1 |
| 触发器节点（Webhook/Cron/Polling） | 3 | P0 |
| 代码节点（JS/Python） | 2 | P1 |
| 通知节点（Email/Push） | 2 | P2 |
| 数据库节点（SQLite） | 1 | P2 |

### Phase 3：UI 完善（2-3 周）

| 任务 | 优先级 |
|------|--------|
| 动态参数表单生成器（Schema → UI） | P0 |
| 撤销/重做 | P0 |
| 节点面板（分类 + 搜索 + 拖拽） | P0 |
| 执行面板（实时日志流） | P0 |
| 画布自动布局 | P1 |
| 右键上下文菜单 | P1 |
| 键盘快捷键全支持 | P1 |
| 暗色模式 | P1 |
| 小地图 | P2 |
| 节点备注/注释 | P2 |

### Phase 4：生产就绪（3-4 周）

| 任务 | 优先级 |
|------|--------|
| Isolate Worker 并行执行 | P1 |
| 工作流暂停/恢复（Wait 节点） | P1 |
| 执行历史与回放 | P1 |
| 工作流导入/导出 JSON | P0 |
| 触发器生命周期管理（激活/停用） | P0 |
| 全局错误处理与告警 | P1 |
| AI 节点（与 ai_chat_app 整合） | P1 |
| 性能测试（50+ 节点工作流） | P1 |
| 单元测试覆盖（引擎 + 表达式 + 节点） | P1 |
| 国际化（中/英文） | P2 |

### Phase 5：独立服务 + 团队协作（远期）

| 任务 | 优先级 |
|------|--------|
| Dart Shelf REST API Server | P2 |
| WebSocket 实时推送执行状态 | P2 |
| 多用户/角色权限 | P2 |
| 工作流模板市场 | P3 |
| 外部节点 SDK | P3 |

---

## 附录 A：关键风险与缓解措施

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| vyuh_node_flow 功能不满足 | 画布开发量大增 | Phase 0 早期验证，必要时 fork 改造 |
| Dart Isolate 不支持部分库 | 并行执行受限 | 降级为单线程 async，保留 API 兼容 |
| 表达式引擎性能不足 | 复杂工作流卡顿 | 预编译 + 缓存 AST |
| Python 执行沙盒安全 | 代码注入风险 | 使用 task-runner 隔离模式 |
| 跨平台一致性 | 桌面/移动端体验差异 | 每 Phase 结束做全平台测试 |

## 附录 B：参考资源

- [n8n 源码](https://github.com/n8n-io/n8n)
- [n8n 架构深度解析](https://developer.aliyun.com/article/1686438)
- [vyuh_node_flow](https://github.com/vyuh-tech/vyuh_node_flow)
- [React Flow](https://reactflow.dev)
- [n8n DeepWiki](https://deepwiki.com/n8n-io/n8n)
