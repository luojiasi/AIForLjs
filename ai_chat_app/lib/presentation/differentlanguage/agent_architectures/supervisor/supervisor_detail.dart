/// Supervisor Pattern — 完整详解
const String supervisorFullDetail = '''

# 监督者模式 (Supervisor Pattern) - 完整详解

## 第一章：核心概念与架构

### 1.1 定义

Supervisor是一种层级化的多Agent架构。与Router的一次性分类不同，
Supervisor在整个任务执行过程中**持续监控进度**，动态委派子任务给
专业Worker Agent，并在必要时重新分配或调整策略。

如果把Router比作接线员（一次性转接），Supervisor就是项目经理
（全程管理、动态调整）。

### 1.2 架构布局

```
                ┌─────────────┐
                │ Supervisor  │  ← 使用最强模型
                │  监督者Agent │    全局监控+任务分解+动态委派
                └──┬──┬──┬───┘
                   │  │  │
         ┌─────────┘  │  └─────────┐
         ↓            ↓            ↓
    ┌────────┐  ┌────────┐  ┌────────┐
    │Research│  │ CodeGen│  │  Test  │  ← 专业Worker
    │ Agent  │  │ Agent  │  │ Agent  │    使用较轻模型
    └────────┘  └────────┘  └────────┘
```

**模型配置差异：**
- Supervisor：使用最强推理模型（如Claude Opus），temperature=0.1-0.3
- Worker Agent：使用较轻模型（如Claude Haiku），temperature=0.3-0.5

### 1.3 Supervisor的六大核心职责

1. **任务理解与分解：** 把用户目标拆成可执行的子任务，明确依赖关系
2. **动态委派：** 根据当前状态和Agent可用性选择最合适的Worker
3. **进度监控：** 跟踪各Worker的执行状态，及时发现问题
4. **冲突协调：** 处理Worker之间的依赖冲突和资源争用
5. **结果聚合：** 将各Worker的输出整合为连贯的最终答案
6. **异常处理：** Worker失败时重新分配、降级处理或转人工

## 第二章：三种委派策略

### 2.1 顺序委派（Sequential）

```
Agent A → Agent B → Agent C
```

每个Agent的输出是下一个Agent的输入。适合有明确顺序依赖的任务链。

**例子（长文写作）：**
```
ResearchAgent → 收集资料
  ↓ (原始资料)
OutlineAgent → 设计大纲
  ↓ (结构化大纲)
WriterAgent → 撰写正文
  ↓ (完整初稿)
ReviewerAgent → 审查润色
  ↓ (最终稿)
```

### 2.2 并行委派（Parallel）

```
Agent A ↘
Agent B → Supervisor聚合 → 最终输出
Agent C ↗
```

Supervisor将任务拆分成可以同时执行的独立部分。

**例子（竞品分析报告）：**
```
SearchAgent_A → 搜索竞品A信息  ↘
SearchAgent_B → 搜索竞品B信息  → Supervisor聚合 → 对比分析报告
SearchAgent_C → 搜索竞品C信息  ↗
```

### 2.3 动态委派（Dynamic）

Supervisor实时判断下一步该委派给谁，基于中间结果动态调整。

**例子（代码调试）：**
```
Step 1: 委派CodeAgent分析错误
Step 2: 基于错误类型决定：
  - 如果是语法错误 → 委派CodeAgent修复
  - 如果是依赖问题 → 委派DevOpsAgent处理
  - 如果是逻辑错误 → 委派CodeAgent重新设计
Step 3: 修复后委派TestAgent验证
```

## 第三章：完整执行流程示例

以"帮我写一篇关于AI Agent架构的技术博客"为例：

**Step 1 — 任务分解**
Supervisor分析目标并生成计划：
```
Task Plan:
1. [ResearchAgent] 搜索2025年AI Agent架构最新资料（并行）
2. [OutlineAgent] 基于研究资料整理文章大纲
3. [WriterAgent] 撰写正文
4. [CodeAgent] 检查文章中的代码示例（并行）
5. [CriticAgent] 审查文章逻辑和准确性（并行）
6. [EditorAgent] 综合审查意见修改定稿
```

**Step 2 — 执行与监控**
```
Supervisor: 委派Step 1 → ResearchAgent开始...
ResearchAgent完成 → 返回5篇核心论文+3篇行业报告
Supervisor: 质量检查通过 → 委派Step 2
OutlineAgent完成 → 返回4段式文章结构
Supervisor: 审核大纲 → 通过 → 委派Step 3
WriterAgent完成 → 返回完整初稿
Supervisor: 审核正文 → 发现代码示例第3个有误
```

**Step 3 — 异常处理**
```
Supervisor: 委派CodeAgent修复第3个代码示例
CodeAgent: 修复完成
Supervisor: 同步委派CriticAgent审查全文
CriticAgent: 发现2处逻辑跳跃和1处事实引用不准确
Supervisor: 综合CodeAgent修复+CriticAgent意见 → 委派EditorAgent
EditorAgent: 修改定稿
```

**Step 4 — 最终聚合**
```
Supervisor: 审核最终稿 → 所有检查通过 → 返回用户
```

## 第四章：Supervisor提示词设计

### 4.1 完整的系统提示词模板

```
你是一个团队的项目经理（Supervisor）。你的职责是：
1. 分析用户目标，分解为可执行的子任务
2. 将子任务委派给最合适的专业Agent
3. 监控执行进度，确保按时按质完成
4. 处理异常情况，必要时调整计划

可用Agent及其能力：
- ResearchAgent：搜索网络、查询数据库、收集和整理信息
  输入格式：搜索主题描述
  输出格式：结构化的研究发现摘要，包含来源引用

- WriterAgent：撰写内容、整理格式、润色文字
  输入格式：写作要求+参考资料
  输出格式：完整的文章/文档

- CodeAgent：编写代码、审查代码、运行测试
  输入格式：代码需求描述或待审查代码
  输出格式：代码文件+测试结果

- CriticAgent：审查输出质量、检查事实准确性、发现逻辑漏洞
  输入格式：待审查内容+审查标准
  输出格式：结构化审查报告（严重度+位置+建议）

委派时使用格式：
DELEGATE: <Agent名称>
TASK: <任务描述>
CONTEXT: <相关上下文>
EXPECTED_OUTPUT: <期望输出格式>

完成时使用格式：
FINAL_ANSWER: <最终答案>

重要规则：
- 并行委派无依赖的子任务（提高效率）
- 关键步骤完成后必须审查质量
- Worker连续失败2次 → 调整策略或降级
- 总步数不超过15步
```

### 4.2 Worker能力边界设计

每个Worker的规范文档应包含：
```
Agent名称: ResearchAgent
核心能力: 搜索公开信息、检索论文、查询数据库
输入要求: 明确的搜索主题（可选关键词、时间范围）
输出格式: JSON {findings: [...], sources: [...], confidence: float}
能力边界: 不执行内部数据库查询（那是SQLAgent的职责）
          不处理实时数据（使用专门的API Agent）
典型耗时: 2-5秒（简单搜索）/ 10-30秒（深度研究）
失败模式: 搜索无结果、信息过时、来源不可靠
```

## 第五章：JARVIS案例深度分析（Cisco）

Cisco Outshift的JARVIS是最著名的Supervisor生产实现。

### 5.1 架构决策

| 组件 | 决策 | 理由 |
|------|------|------|
| Supervisor模型 | 独立于Worker的最强模型 | 委派决策需要最准确的推理 |
| Worker模型 | 较轻模型，按任务选择 | 专用任务不需要通用推理能力 |
| 通信方式 | Supervisor↔Worker双向 | Worker之间不直接通信 |
| 状态管理 | 全局状态树 | 每个Worker的输出被记录和索引 |
| 质量保证 | Reflection Agent评估 | 每个Worker输出都经过质量检查 |

### 5.2 生产指标

- 延迟改善：比纯ReAct基线降低~40%
- 准确率：复杂多步任务提升~15%
- 可靠性：失败率从8%降至2%
- 审计性：每步决策完整可追踪

## 第六章：实现框架

### 6.1 LangGraph Supervisor

```python
from langgraph.prebuilt import create_supervisor
from langgraph.checkpoint.memory import MemorySaver

# 创建Worker Agent
research_agent = create_react_agent(research_llm, [search_tool])
writer_agent = create_react_agent(writer_llm, [])
code_agent = create_react_agent(code_llm, [code_executor])

# 创建Supervisor
supervisor = create_supervisor(
    agents=[research_agent, writer_agent, code_agent],
    model=supervisor_llm,  # 使用最强模型
    prompt=supervisor_prompt,
    output_mode="last",
)

# 编译（带持久化checkpoint）
app = supervisor.compile(checkpointer=MemorySaver())

# 执行
result = app.invoke(
    {"messages": [{"role": "user", "content": "写一篇关于AI的技术博客"}]},
    config={"configurable": {"thread_id": "task-001"}}
)
```

### 6.2 CrewAI Hierarchical Process

```python
from crewai import Agent, Task, Crew, Process

researcher = Agent(role='Research Analyst', goal='...', tools=[search])
writer = Agent(role='Tech Writer', goal='...', tools=[])
reviewer = Agent(role='Content Reviewer', goal='...', tools=[])

crew = Crew(
    agents=[researcher, writer, reviewer],
    tasks=[research_task, writing_task, review_task],
    process=Process.hierarchical,  # 启用Supervisor模式
    manager_llm=ChatOpenAI(model="gpt-4o"),  # Supervisor模型
)

result = crew.kickoff()
```

### 6.3 AutoGen GroupChat with Manager

AutoGen使用GroupChat + GroupChatManager实现Supervisor模式。
Manager由LLM驱动，基于对话历史动态选择下一个发言的Agent。

## 第七章：Supervisor的演进路径

```
单Agent (2022)
  ↓
Router (2023) —— 一次性分类
  ↓
Supervisor (2024) —— 持续监控和委派
  ↓
Arbiter (2025) —— 语义能力匹配+动态Agent生成
  ↓
Hierarchical Teams (2025+) —— Supervisor管理Agent团队
```

### 2025年前沿方向

1. **Arbiter模式：** Supervisor不仅能委派给已知Agent，还能推理"需要什么样的Agent"并动态生成
2. **Hierarchical Teams：** Supervisor管理的不再是单个Agent，而是Agent团队
3. **自适应监督强度：** 根据任务风险级别自动调整监督深度（低风险→宽松，高风险→严格）
4. **MCP+A2A集成：** 标准化的工具调用和Agent间通信让Supervisor可以跨组织委派

## 第八章：何时使用Supervisor

**最佳场景：**
- 复杂多步任务（5步以上，Worker间有依赖关系）
- 需要动态调整策略的探索性任务
- 要求审计追踪和决策可解释性
- 3-10个专业Worker Agent的团队规模

**不适合的场景：**
- 简单单步任务 → Router更高效
- Worker数量 < 3 → 过度设计
- 实时延迟要求 < 2s → 多次委派延迟叠加
- 极度开放的任务 → 协商式Multi-Agent更灵活

> Supervisor模式是构建复杂多Agent系统的核心架构。它结合了
> 中心化控制的可预测性和Worker专业化的高效性。在2025年，
> 结合MCP标准化的工具接口和A2A的Agent通信协议，
> Supervisor模式正在成为企业级Agent系统的首选架构。
> 关键教训：**Supervisor的决策质量决定了整个系统的上限。**
> 在Supervisor上使用最好的模型是ROI最高的投资。
''';
