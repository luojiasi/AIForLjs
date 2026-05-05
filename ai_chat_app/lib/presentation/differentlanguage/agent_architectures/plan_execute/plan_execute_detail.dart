/// Plan-Execute — 完整详解
const String planExecuteFullDetail = '''

# 规划-执行模式 (Plan-Execute) - 完整详解

## 第一章：核心概念与变体

### 1.1 架构思想

Plan-Execute将Agent任务处理分为两个明确分离的阶段：先制定完整计划，
再逐步执行。这种"先想再做"的模式与ReAct的"边想边做"形成鲜明对比。

**角色分离：**
- **Planner（规划器）：** 战略层——全局规划。使用低temperature（0.0-0.3）
  的强推理模型，输出结构化计划列表。关注"做什么"。
- **Executor（执行器）：** 战术层——具体执行。使用中temperature（0.3-0.7）
  的灵活模型，按计划逐步执行（通常ReAct风格）。关注"怎么做"。

### 1.2 三种变体对比

| 维度 | 静态规划 | 动态重规划 | 层级规划 |
|------|---------|-----------|---------|
| 计划修改 | 执行中不修改 | 每步后可调整 | 分层独立调整 |
| 代表实现 | ReWOO | 标准Plan-Execute | NaviAgent |
| Token效率 | 最高（2次LLM调用） | 中（3-10次） | 中-高 |
| 灵活性 | 最低 | 高 | 最高 |
| 适用任务 | 确定性线性任务 | 中等不确定性 | 高度复杂任务 |
| 失败恢复 | 差（计划一次性） | 好（重规划） | 最好（分层重规划） |

### 1.3 计划数据结构

```json
{
  "goal": "调研新能源汽车市场并生成报告",
  "steps": [
    {
      "id": 1,
      "description": "搜索2024-2025年新能源汽车销量数据",
      "agent": "SearchAgent",
      "depends_on": [],
      "expected_output": "各品牌销量表格（含同比数据）"
    },
    {
      "id": 2,
      "description": "搜索主要车企新能源战略和产品线",
      "agent": "SearchAgent",
      "depends_on": [],
      "expected_output": "Top10车企的产品规划摘要"
    },
    {
      "id": 3,
      "description": "搜索充电基础设施发展状况",
      "agent": "SearchAgent",
      "depends_on": [],
      "expected_output": "充电桩数据+政策摘要"
    },
    {
      "id": 4,
      "description": "综合分析以上数据生成5000字报告",
      "agent": "WriterAgent",
      "depends_on": [1, 2, 3],
      "expected_output": "完整市场分析报告"
    },
    {
      "id": 5,
      "description": "审查报告数据准确性和逻辑",
      "agent": "CriticAgent",
      "depends_on": [4],
      "expected_output": "审查意见（问题清单+建议）"
    },
    {
      "id": 6,
      "description": "根据审查意见修改报告",
      "agent": "WriterAgent",
      "depends_on": [5],
      "expected_output": "最终版本报告"
    }
  ],
  "success_criteria": "报告包含销量数据、竞争格局、基础设施、趋势预测",
  "max_steps": 10,
  "replan_threshold": 0.7
}
```

**执行分析：** 步骤1/2/3无依赖 → 可并行执行 → 节省2/3时间。

## 第二章：RP-ReAct（2025最新进展）

### 2.1 论文信息
- **标题:** Reason-Plan-ReAct: A Reasoner-Planner Supervising a ReAct Executor
- **作者:** Molinari, Gianni and Ciravegna, Fabio
- **发表:** arXiv:2512.03560, December 2025

### 2.2 架构设计

RP-ReAct将Plan-Execute推向新高度——不仅分离规划和执行，而且让
规划者（RPA）持续监督执行者（PEA）：

```
┌─────────────────────────┐
│  Reasoner-Planner (RPA) │ ← 高层规划+战略推理+动态重规划
│  使用最强推理模型        │
└───────────┬─────────────┘
            │ 下达子步骤
            ↓
┌─────────────────────────┐
│  Proxy-Execution (PEA)  │ ← 将子步骤翻译为具体工具交互
│  使用ReAct循环           │    Context-saving: 工具输出存外部
└─────────────────────────┘
```

### 2.3 关键创新

**1. Context-saving策略：**
PEA将大型工具输出卸载到外部存储，只返回Token限制的预览给LLM上下文。
这解决了开源小模型执行复杂任务时上下文窗口不够用的核心问题。

**2. 动态重规划函数 δ(r_t)：**
每次执行结果后，函数δ评估是否需要重新规划：
```
δ(r_t) = {
  CONTINUE: if step_success and overall_progress > threshold
  REPLAN:   if step_failed or unexpected_result or overall_progress < threshold
}
```

**3. 多PEA扩展性：**
单个RPA可以监督多个PEA，实现可并行的子任务执行。

### 2.4 实验结果

- 在硬任务上（≥6个子步骤）：比单一ReAct和Reflexion基线提高+5至+15个准确度点
- 跨模型规模的准确率方差降低多达**50%**（更稳定可预测）
- 5/5领域达到最先进综合性能得分（CPS）

## 第三章：NaviAgent（双层规划，2025）

### 3.1 论文信息
- **标题:** NaviAgent: Bilevel Planning on Tool Navigation Graph
- **作者:** Jiang, Yan et al. (JD.COM)
- **发表:** arXiv:2506.19500, June 2025

### 3.2 双层架构

**层级1 — 多路径决策器（任务规划层）：**
- 四维决策空间：直接回复 | 意图澄清 | 工具链检索 | 工具执行
- 使用最近3个观察-行动对的滑动窗口
- 监督学习微调 + LLM驱动推理

**层级2 — 图编码导航器/TWNM（执行层）：**
- 构建工具依赖异构图（TDHG）
- 节点：API节点和参数节点
- 结构边：来自API Schema
- 行为边：来自历史使用数据
- 统计边权重：基于经验调用模式
- 使用异构图Transformer（HGT）进行工具依赖发现（链接预测）

### 3.3 性能结果

| 模型 | 任务成功率 | vs 基线 |
|------|----------|---------|
| Qwen2.5-14B + NaviAgent | 显著提升 | +13.5% |
| Qwen2.5-32B + NaviAgent | 显著提升 | +16.4% |
| DeepSeek-V3 + NaviAgent | 显著提升 | +19.0% |
| 微调Qwen2.5-14B + NaviAgent | **49.5%** | 超越32B基线的44.9% |

## 第四章：实现指南

### 4.1 LangGraph Plan-Execute

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

class PlanExecuteState(TypedDict):
    input: str
    plan: List[dict]
    completed_steps: dict
    results: dict
    final_output: str

# Planner节点
def planner_node(state):
    plan = llm.generate_plan(state["input"])
    return {"plan": plan}

# Executor节点
def executor_node(state):
    for step in state["plan"]:
        if all(state["completed_steps"].get(d) for d in step["depends_on"]):
            result = agents[step["agent"]].execute(step)
            state["results"][step["id"]] = result
            state["completed_steps"][step["id"]] = True
    return state

# Replanner节点（动态重规划）
def replanner_node(state):
    should_replan = evaluator.check(state)
    if should_replan:
        new_plan = llm.replan(state["input"], state["results"])
        return {"plan": new_plan}
    return {}

# 构建图
graph = StateGraph(PlanExecuteState)
graph.add_node("planner", planner_node)
graph.add_node("executor", executor_node)
graph.add_node("replanner", replanner_node)
graph.add_edge(START, "planner")
graph.add_edge("planner", "executor")
graph.add_conditional_edges("executor", replanner_node,
    lambda s: "replanner" if s.get("needs_replan") else END
)
```

### 4.2 Smolagents (HuggingFace)

```python
from smolagents import CodeAgent, LiteLLMModel

model = LiteLLMModel(model_id="gpt-4o")

agent = CodeAgent(
    tools=[search_tool, calculator_tool],
    model=model,
    planning_interval=3  # 每3步后触发重新规划
)

agent.run("分析并比较三家公司的营收数据")
```

## 第五章：Plan-Execute vs 替代方案决策框架

### 5.1 全面对比

| 维度 | Plan-Execute | ReAct | ReWOO | LLMCompiler |
|------|-------------|-------|-------|-------------|
| 规划方式 | 先整体规划 | 逐步规划 | 一次性规划 | DAG并行规划 |
| 灵活性 | 高（支持重规划） | 极高 | 低 | 中 |
| 并行能力 | 高 | 低 | 中 | 最高 |
| Token效率 | 中 | 低 | 最高 | 高 |
| 可审计性 | 强（计划可见） | 中 | 强 | 强 |
| 错误恢复 | 好（重规划） | 最灵活 | 差 | 中 |

### 5.2 决策树

```
你的任务适合Plan-Execute吗？

├── 任务步骤可以提前预测（>70%确定性）？
│   └── ✓ Plan-Execute最佳
│
├── 有多个无依赖的并行子任务？
│   └── ✓ Plan-Execute并行能力好
│
├── 需要审计追踪和决策可解释性？
│   └── ✓ Plan-Execute计划清晰可审计
│
├── 每步都依赖上一步的具体结果？
│   └── → ReAct更灵活
│
├── Token预算紧张？
│   └── → ReWOO更高效
│
└── 工具密集型、大量并行调用？
    └── → LLMCompiler更优化
```

## 第六章：最佳实践

### 6.1 混合架构（2025共识）

```
阶段1（扇出）：LLMCompiler/ReWOO 并行证据收集
阶段2（分析）：Plan-and-Execute 结构化多步处理
阶段3（恢复）：ReAct 处理边界情况和故障
```

### 6.2 重规划触发条件

```python
def should_replan(state) -> bool:
    triggers = [
        state.step_failures > 2,         # 连续失败
        state.unexpected_results > 0,    # 意外结果
        state.overall_progress < 0.5,    # 进度落后
        state.confidence_drop > 0.3,     # 置信度下降
        state.new_info_contradicts_plan, # 新信息推翻计划假设
    ]
    return any(triggers)
```

### 6.3 计划的粒度控制

- **太粗：** 每步是整个子领域 → Executor缺乏明确指导
- **太细：** 每步是单一工具调用 → Planner开销超过收益
- **最佳粒度：** 每步是一个语义完整的工作单元（3-8个工具调用）

> Plan-Execute代表了从"边想边做"到"先想再做"的范式转变。
> 2025年的最新进展（RP-ReAct、NaviAgent）证明了在复杂企业任务中，
> 这种模式提供了比纯ReAct更好的可控性和可审计性。
> 混合架构——宏观Plan-Execute + 微观ReAct——是当前的最佳实践。
''';
