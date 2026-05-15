# simplen8n — 架构与开发指南

## 目录结构

```
simplen8n/
├── simplen8n_init.dart                 ← 启动入口：注册所有节点类型 + executor（一次性）
│
├── models/                             ← 数据层（纯 Dart 对象，无 UI/IO 依赖）
│   ├── node_type.dart                  ← NodeCategory, PortDefinition, ParameterSchema, NodeTypeDefinition
│   ├── workflow_model.dart             ← Workflow, WorkflowNode, ConnectionRule, WorkflowSettings
│   └── execution_data.dart             ← NodeExecutionData, NodeExecutionResult, ExecutionResult
│
├── nodes/
│   └── node_registry.dart              ← 单例：type → NodeTypeDefinition（UI 面板从此读节点列表）
│
├── engine/                             ← 核心引擎（无 Flutter 依赖，可独立测试）
│   ├── node_executor.dart              ← INodeExecutor 抽象接口
│   ├── executor_registry.dart          ← 单例：type → INodeExecutor（引擎运行时查表调度）
│   ├── execution_engine.dart           ← 主引擎：DAG 验证 → 栈式循环执行 → 重试 → 多输入聚合
│   ├── execution_context.dart          ← 运行时上下文：变量存储、节点输出缓存、{{ }} 模板求值
│   ├── dag_analyzer.dart               ← 图论分析：环检测、拓扑排序、入度、源/汇节点
│   ├── expression_engine.dart          ← 自研表达式引擎：词法分析 → 递归下降解析 → AST 求值
│   ├── exceptions.dart                 ← 异常体系：5 层类型化异常
│   ├── executors/                      ← 10 个节点执行器（每个节点类型一个）
│   │   ├── manual_trigger_executor.dart
│   │   ├── http_request_executor.dart
│   │   ├── set_executor.dart
│   │   ├── if_executor.dart
│   │   ├── merge_executor.dart
│   │   ├── ai_chat_executor.dart
│   │   ├── webhook_trigger_executor.dart
│   │   ├── cron_trigger_executor.dart
│   │   ├── error_trigger_executor.dart
│   │   └── execute_workflow_executor.dart
│   └── triggers/                       ← 自动触发器
│       ├── trigger_manager.dart         ← 单例：管理所有激活工作流的触发器生命周期
│       ├── webhook_trigger.dart         ← HTTP 服务器触发器（127.0.0.1 监听）
│       └── cron_trigger.dart           ← Cron 解析器 + Timer 定时触发器
│
├── converters/
│   └── canvas_converter.dart           ← Workflow 模型 ↔ vyuh_node_flow 画布 双向转换
│
├── providers/                          ← 状态管理（Flutter ChangeNotifier）
│   ├── workflow_provider.dart          ← 编辑器中央状态：节点操作、执行、持久化、触发器激活
│   └── history_manager.dart            ← 撤销/重做：Workflow 快照栈（最多 50 步）
│
├── services/                           ← 基础设施（文件 IO、API 调用）
│   ├── workflow_storage_service.dart   ← 工作流 JSON 文件 CRUD + 索引管理
│   ├── execution_storage_service.dart  ← 执行历史 JSON 持久化
│   ├── credential_service.dart         ← 凭据加密存储 + 执行前批量解析
│   └── ai_api_client.dart             ← 通用 LLM API 客户端（OpenAI + Anthropic 双协议）
│
└── ui/                                 ← 视图层（7 个页面/组件）
    ├── simplen8n_home_page.dart         ← 入口页：工作流列表 + 新建
    ├── workflow_canvas_page.dart        ← 主编辑器：三栏布局 + 工具栏 + 快捷键
    ├── node_palette.dart               ← 左侧节点面板（搜索 + 分类）
    ├── node_config_panel.dart          ← 右侧参数配置面板（动态表单）
    ├── node_widget.dart                ← 画布节点渲染（颜色编码 + 状态指示）
    ├── execution_history_page.dart     ← 执行历史列表
    └── execution_detail_page.dart      ← 单次执行详情（每节点输入/输出/耗时/错误）
```

## 架构分层

```
┌──────────────────────────────────────────────────┐
│  UI Layer (7 widgets)                            │
│  HomePage → CanvasPage → Palette/ConfigPanel     │
├──────────────────────────────────────────────────┤
│  Provider Layer (ChangeNotifier)                  │
│  WorkflowProvider + HistoryManager               │
├──────────────────────────────────────────────────┤
│  Engine Layer (纯 Dart，可独立测试)               │
│  ExecutionEngine → ExecutorRegistry → INodeExecutor│
│  DagAnalyzer / ExpressionEngine / ExecutionContext│
├──────────────────────────────────────────────────┤
│  Services Layer (IO)                             │
│  StorageService / CredentialService / AiApiClient│
├──────────────────────────────────────────────────┤
│  Models Layer (纯数据)                            │
│  Workflow / WorkflowNode / ExecutionResult       │
└──────────────────────────────────────────────────┘
```

## 核心数据流

### 手动执行流程

```
UI [Run 按钮]
  ↓
WorkflowProvider.executeWorkflow()
  ↓ syncToWorkflow() — 画布 → Workflow 模型同步
  ↓
ExecutionEngine.execute(workflow)
  ↓ DagAnalyzer — 校验 DAG + 找源节点
  ↓ CredentialService — 批量解析凭据
  ↓
  执行栈循环:
    ↓ ExecutorRegistry.get(nodeType)
    ↓ INodeExecutor.execute(node, inputData, context)
    │   ↓ context.evaluateTemplate() — 替换 {{ }} 表达式
    │   ↓ 执行业务逻辑
    │   ↓ 返回 List<NodeExecutionData>
    ↓ _pushDownstream() — 推送到下游节点
    ↓ 多输入节点等待聚合
  ↓
返回 ExecutionResult
  ↓ ExecutionStorageService — 自动保存历史
  ↓ notifyListeners() — UI 刷新
```

### 触发器执行流程

```
TriggerManager.activateWorkflow(workflow)
  ├── WebhookTrigger.start() — 启动 HttpServer
  └── CronTrigger.start() — 启动 Timer

触发器点火时:
  ↓ WorkflowStorageService.load() — 重载最新工作流
  ↓ ExecutionEngine.execute() — 执行
  ↓ ExecutionStorageService.save() — 保存结果
  ↓ WorkflowProvider 回调 — UI 更新
```

### 表达式求值流程

```
用户输入: "Hello {{ $json.name }}, age {{ $json.age + 1 }}"
  ↓
ExecutionContext.evaluateTemplate()
  ↓ ExpressionEvaluator.evaluateTemplate()
    ↓ 正则匹配 {{ ... }} 块
    ↓ 对每块: evaluate(expression, context)
      ↓ ExpressionLexer — 词法分析 → Token 流
      ↓ ExpressionParser — 递归下降 → AST
      ↓ AST.evaluate(context) — 遍历 AST 求值
        ↓ 变量解析: $json → context['json']
        ↓ 函数调用: $now() → DateTime.now()
  ↓ 替换回原字符串
返回: "Hello World, age 26"
```

### 错误处理 + Error Workflow 流程

```
ExecutionEngine.execute(workflow)
  ↓ 执行中抛出异常
  ↓ catch 块捕获 → 构造失败的 ExecutionResult
  ↓ 检查 workflow.errorWorkflowId
  ↓ 如果设置了:
    ↓ WorkflowStorageService.load(errorWorkflowId)
    ↓ ExecutionEngine.execute(errorWf, triggerData: {
        error: { message, workflowId, executionId },
        nodeResults: { ... }
      })
    ↓ 错误工作流可以发通知、记录日志、重试等
  ↓ 返回失败的 ExecutionResult
```

## 10 个节点类型速览

| 节点 | type 标识 | 类别 | 输入 | 输出 | 关键参数 |
|------|----------|------|------|------|---------|
| Manual Trigger | `manual_trigger` | Trigger | - | 1 | 无 |
| Webhook | `webhook_trigger` | Trigger | - | 1 | httpMethod, port, responseData |
| Cron | `cron_trigger` | Trigger | - | 1 | cronExpression |
| Error Trigger | `error_trigger` | Trigger | - | 1 | errorTypes |
| HTTP Request | `http_request` | Action | 1 | 1 | method, url, headers, body |
| Set | `set` | Data | 1 | 1 | values (JSON) |
| IF | `if` | Logic | 1 | 2 | condition (表达式) |
| Merge | `merge` | Utility | 1 | 1 | mode (combine / passThrough) |
| AI Chat | `ai_chat` | AI | 1 | 1 | provider, model, systemPrompt, userMessage, temperature |
| Execute Workflow | `execute_workflow` | Action | 1 | 1 | workflowId, mode |

## 开发指南：如何修改

### 新增一个节点类型（最常用）

**需要动的文件：2 个新建 + 1 个修改**

**Step 1** — 新建 `engine/executors/your_node_executor.dart`：

```dart
import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

class YourNodeExecutor implements INodeExecutor {
  @override
  String get nodeType => 'your_node_type';  // 唯一标识

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,                    // 节点配置，node.parameters 读取用户输入
    List<NodeExecutionData> inputData,     // 上游传入的数据
    ExecutionContext context,             // 表达式求值、变量读写
  ) async {
    // 1. 从 node.parameters 读配置
    final someParam = node.parameters['paramName'] as String;

    // 2. 模板替换（用户可能写了 {{ $json.field }}）
    final resolved = context.evaluateTemplate(someParam);

    // 3. 执行业务逻辑
    // ...

    // 4. 返回输出数据给下游
    return [NodeExecutionData(json: {
      'result': resolved,
      'status': 'ok',
    })];
  }
}
```

**Step 2** — `simplen8n_init.dart` 加两处注册：

```dart
// ① 引入
import 'engine/executors/your_node_executor.dart';

// ② initSimplen8n() 函数内 — 注册 executor
execRegistry.registerAll([
  // ... 已有的
  YourNodeExecutor(),
]);

// ③ 注册节点类型定义（UI 面板从此读取）
registry.registerAll([
  // ... 已有的
  const NodeTypeDefinition(
    type: 'your_node_type',
    displayName: 'Your Node',
    category: NodeCategory.action,
    inputs: [PortDefinition(id: 'input', name: 'Input')],
    outputs: [PortDefinition(id: 'output', name: 'Output')],
    parameterSchema: [
      ParameterSchema(
        name: 'paramName',
        displayName: 'Parameter Label',
        type: ParameterType.string,
        defaultValue: '',
        required: true,
        description: 'What this parameter does.',
      ),
    ],
    description: 'What this node does.',
  ),
]);
```

**Step 3** — 写测试 `test/simplen8n/engine/executors/your_node_test.dart`

### 修改执行流程

**文件：** `engine/execution_engine.dart`

| 要改什么 | 改哪个方法 | 行号附近 |
|---------|-----------|---------|
| 执行前校验 | `execute()` | ~52 |
| 节点处理（重试、计时、错误） | `_processNode()` | ~146 |
| 推送到下游（多输入聚合） | `_pushDownstream()` | ~237 |
| 多输入判断逻辑 | `_isMultiInputNode()` | ~291 |
| 执行分发 | `_executeNode()` | ~329 |

### 修改表达式引擎

**文件：** `engine/expression_engine.dart`

| 要改什么 | 位置 |
|---------|------|
| 加新的 Token 类型 | `TokenType` 枚举 |
| 改词法规则 | `ExpressionLexer.nextToken()` |
| 加新的 AST 节点 | `ASTNode` 子类 |
| 改语法规则 | `ExpressionParser` 对应方法 |
| 加内置函数 | `ExpressionEvaluator._callFunction()` — 加 1 个 case |
| 加内置变量 | `ExecutionContext._buildContext()` — 加 1 个 key |

### 修改数据模型

**文件：** `models/` 下对应文件

修改任何模型类后，必须同步更新 4 个方法：`构造函数`、`fromJson()`、`toJson()`、`copyWith()`

### 修改持久化

**文件：** `services/workflow_storage_service.dart` 或 `execution_storage_service.dart`

关键约束：**public 方法签名不要变**，内部实现随意换（JSON → SQLite → 云端同步）。调用方 0 改动。

### 修改 UI

| 要改什么 | 改哪个文件 |
|---------|-----------|
| 入口页/工作流列表 | `ui/simplen8n_home_page.dart` |
| 画布工具栏（加按钮） | `ui/workflow_canvas_page.dart` → `_buildToolbar()` |
| 画布右键菜单 | `ui/workflow_canvas_page.dart` → `_showNodeContextMenu()` |
| 画布快捷键 | `ui/workflow_canvas_page.dart` → `_handleKeyboard()` |
| 左侧节点面板 | `ui/node_palette.dart` |
| 右侧参数配置 | `ui/node_config_panel.dart` |
| 节点外观渲染 | `ui/node_widget.dart` |
| 执行历史页 | `ui/execution_history_page.dart` |
| 执行详情页 | `ui/execution_detail_page.dart` |

### 修改凭据逻辑

| 要改什么 | 改哪个文件 |
|---------|-----------|
| 凭据存储/加密方式 | `services/credential_service.dart` |
| 执行时凭据注入 | `engine/execution_context.dart` → `_resolveCredentialTemplate()` |
| 执行前凭据加载 | `engine/execution_engine.dart` → `_resolveCredentials()` |

### 修改错误处理

| 要改什么 | 改哪个文件 |
|---------|-----------|
| 加新异常类型 | `engine/exceptions.dart`（继承 `Simplen8nException` 或子类） |
| 抛出异常 | 对应的 executor 或 engine 方法 |
| 捕获并展示 | `engine/execution_engine.dart` catch 块 + `workflow_provider.dart` |

## 表达式语法参考

### 变量

```
$json                    — 当前节点的输入数据
$json.field              — 输入数据的字段
$json.nested.path        — 嵌套路径
$vars.key                — Set 节点设置的全局变量
$node['NodeName'].json   — 指定节点的输出
$credential.name.value   — 凭据值
$workflow.id             — 工作流 ID
$workflow.name           — 工作流名称
```

### 运算符

```
+  -  *  /  %             — 算术
==  !=  >  <  >=  <=      — 比较
&&  ||  !                 — 逻辑
??                        — 空合并
? :                       — 三元
```

### 内置函数

```
$now()                    — 当前 ISO 时间戳
$randomInt(max)           — 随机整数 [0, max)
$len(value)               — 字符串长度或数组长度
$upper(str)               — 转大写
$lower(str)               — 转小写
$round(num)               — 四舍五入
```

### 示例

```
{{ $json.temperature > 30 ? 'Hot' : 'Cool' }}
{{ $vars.userName ?? 'Guest' }}
{{ $now() }}
{{ $json.items.len }}
```

## 持久化文件结构

```
{appDocDir}/simplen8n/
├── index.json                      ← 工作流索引 [WorkflowSummary, ...]
├── workflows/
│   ├── {id}.json                   ← 工作流完整数据
│   └── ...
├── history/
│   ├── {execution_id}.json         ← 执行记录
│   └── ...
└── credentials/
    ├── index.json                  ← 凭据索引
    ├── {id}.json                   ← 加密凭据文件
    └── ...
```

## 测试

```bash
# 运行所有 simplen8n 测试
flutter test test/simplen8n/

# 运行特定模块测试
flutter test test/simplen8n/engine/
flutter test test/simplen8n/models/

# 分析代码
flutter analyze lib/presentation/simplen8n/
```

当前测试覆盖：DAG 分析器（34 用例）、表达式引擎（52 用例）、执行引擎（13 用例）、工作流模型（12 用例）、Cron 解析器（13 用例）、工作流设置（12 用例），共 **139 个测试**。

## 快速决策表

| 我要... | 改哪个文件 | 大约改动量 |
|---------|-----------|-----------|
| 加一个新节点类型 | 新建 executor + `simplen8n_init.dart` 注册 | ~80 行 |
| 给 IF 节点加参数 | `simplen8n_init.dart` 的 IF ParameterSchema + `engine/executors/if_executor.dart` | ~10 行 |
| 改执行超时逻辑 | `engine/execution_engine.dart` execute() | ~5 行 |
| 加内置函数 | `engine/expression_engine.dart` _callFunction() | 1 行 |
| 换存储方式 | `services/workflow_storage_service.dart`（接口不变） | 1 文件 |
| 加工具栏按钮 | `ui/workflow_canvas_page.dart` _buildToolbar() | ~15 行 |
| 改节点外观 | `ui/node_widget.dart` | 1 文件 |
| 改错误提示样式 | `ui/workflow_canvas_page.dart` SnackBar 部分 | ~5 行 |
| 加新的异常类型 | `engine/exceptions.dart` + 抛出点 | ~10 行 |
| 加工作流级设置项 | `models/workflow_model.dart` WorkflowSettings + 引擎使用处 | ~20 行 |
| 加凭据类型 | `services/credential_service.dart` + `execution_context.dart` | ~15 行 |
