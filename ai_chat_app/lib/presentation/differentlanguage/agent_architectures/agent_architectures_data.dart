import 'package:flutter/material.dart';

/// ============================================================
/// Data models for AI Agent Architecture detailed guide
/// 主流AI Agent架构详解 - 12种核心架构模式
/// ============================================================

class AgentArchitecture {
  final String id;
  final String name;
  final String englishName;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String overview;
  final String corePrinciple;
  final String workflow;
  final String detailedContent;
  final String pros;
  final String cons;
  final String useCases;
  final String implementations;
  final String papers;
  final String evolutionPath;
  final List<String> tags;

  const AgentArchitecture({
    required this.id,
    required this.name,
    required this.englishName,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.overview,
    required this.corePrinciple,
    required this.workflow,
    required this.detailedContent,
    required this.pros,
    required this.cons,
    required this.useCases,
    required this.implementations,
    required this.papers,
    required this.evolutionPath,
    required this.tags,
  });
}

/// ============================================================
/// All 12 Agent Architectures — 完整详解
/// ============================================================
const List<AgentArchitecture> agentArchitectures = [
  // ──────────────────────────────────────────────────────────
  // 1. Workflow + Tool Calling
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'workflow_tool_calling',
    name: '工作流 + 工具调用',
    englishName: 'Workflow + Tool Calling',
    subtitle: '最基础的Agent模式，通过结构化工作流编排工具调用',
    icon: Icons.account_tree,
    color: Color(0xFF2196F3),
    overview: '''
Workflow + Tool Calling 是AI Agent最基础、最广泛使用的架构模式。它通过预定义的工作流（Workflow）来编排大语言模型（LLM）对各种工具（Tool/Function）的调用，从而完成复杂的实际任务。

这一模式的核心思想是：LLM本身只能生成文本，但通过与外部工具交互，它可以查询数据库、调用API、执行代码、搜索网页等，从而突破纯文本生成的能力边界。

在2024-2025年，随着MCP（Model Context Protocol）协议的标准化，Tool Calling已经成为几乎所有主流Agent框架的标配能力。''',
    corePrinciple: '''
1. LLM作为"大脑"：负责理解用户意图、规划任务步骤、决定调用哪些工具
2. 工具作为"手脚"：每个工具封装一个特定能力（搜索、计算、API调用等）
3. 工作流作为"骨架"：定义任务执行的流程、分支、重试、超时等逻辑
4. 结构化输出：LLM输出JSON格式的function_call，精确指定工具名和参数

核心公式：Task → LLM Plan → Tool Execution → Result → LLM Synthesize → Final Output''',
    workflow: '''
Step 1: 用户输入任务 → LLM分析意图
Step 2: LLM决定需要调用哪些工具，输出function_call
Step 3: 系统执行工具调用，获取结果
Step 4: 工具结果返回LLM，LLM判断是否继续调用工具
Step 5: LLM综合所有信息，生成最终回复

工作流引擎（LangGraph/Temporal等）负责：
- 状态管理：追踪每一步的输入输出
- 错误处理：工具调用失败时的重试/降级
- 并行调度：无依赖的工具调用并行执行
- 中断恢复：支持人工审批节点（Human-in-the-Loop）''',
    detailedContent: '''
【发展演进】

2023年初：OpenAI发布Function Calling API，标志着Tool Calling正式成为LLM标准能力。早期实现仅支持单次单工具调用，每次调用需要完整上下文回传。

2024年：Parallel Tool Calling成为标配。Claude、GPT-4等模型支持在一次响应中并行调用多个无依赖工具，大幅降低延迟。同时，JSON Mode和Structured Outputs确保工具调用的参数合法性。

2025年：MCP（Model Context Protocol）由Anthropic提出并开源，成为工具调用的标准化协议。MCP定义了统一的JSON Schema契约，让任何工具提供方都能"即插即用"。同时，vLLM、SGLang等推理框架内置structured outputs支持，从推理层面保证JSON合法性。

【关键子模式】

1. 单步工具调用（Single Tool Call）
   - 最简单的形式，适合查询类任务
   - 例子：用户问"今天天气怎么样？"→ LLM调用get_weather() → 返回结果

2. 链式工具调用（Chained Tool Calling）
   - 多个工具按顺序调用，后一步依赖前一步的结果
   - 例子：搜索"最新AI论文" → 获取URL → 抓取网页内容 → 总结

3. 并行工具调用（Parallel Tool Calling）
   - 无依赖的工具同时执行，减少总延迟
   - 例子：同时查询北京、上海、广州的天气，然后比较

4. 条件分支工具调用（Conditional Tool Calling）
   - 根据中间结果决定下一步调用哪个工具
   - 例子：先查数据库，如果找到结果就返回，否则调用搜索API

5. Human-in-the-Loop 工具调用
   - 关键操作前暂停，等待人工确认
   - 例子：发送邮件前展示草稿，用户确认后才执行

【2025工作流引擎对比】

| 引擎 | 核心特点 | 适用场景 |
|------|---------|---------|
| LangGraph | 状态图+中断+检查点 | 复杂Agent编排 |
| LlamaIndex Workflows | 事件驱动+并发 | RAG+工具链 |
| Temporal | 工业级重试+幂等 | 生产级任务 |
| Dify/AI Flow | 可视化拖拽 | 低代码场景 |
| MCP+标准工具 | JSON Schema+即插即用 | 工具标准化 |''',
    pros: '''
• 结构清晰，易于理解和调试
• 每个步骤可独立测试和优化
• 支持人工审批节点，安全性高
• MCP标准化后工具生态系统丰富
• 与现有业务系统集成方便
• 适合大多数企业应用场景''',
    cons: '''
• 灵活性受限，难以应对完全开放的任务
• 复杂工作流设计和维护成本高
• 串行工具调用时延迟叠加
• LLM可能选择错误的工具或参数
• 工具数量增多时选择难度上升
• 依赖预定义的流程模板''',
    useCases: '''
• 客服机器人：查订单→查物流→退款→转人工
• 数据查询助手：SQL生成→执行→可视化
• 邮件处理Agent：读取→分类→回复/转发
• IT运维：告警分析→查询日志→执行修复脚本
• 电商比价：搜索→抓取→比较→推荐
• 代码助手：读取代码→分析→生成修复→运行测试''',
    implementations: '''
• OpenAI Function Calling / Tool Use API
• Anthropic Claude Tool Use (支持MCP)
• LangChain Tools + Agents
• LangGraph StateGraph + ToolNode
• LlamaIndex FunctionTool + QueryEngineTool
• Google Gemini Function Calling
• Semantic Kernel (Microsoft) Plugin系统''',
    papers: '''
• Toolformer: Language Models Can Teach Themselves to Use Tools (Schick et al., 2023)
• Gorilla: Large Language Model Connected with Massive APIs (Patil et al., 2023)
• MCP Specification: Model Context Protocol (Anthropic, 2024)
• ReAct: Synergizing Reasoning and Acting in Language Models (Yao et al., 2023)''',
    evolutionPath: '原始Function Calling → 并行Tool Calling → Structured Outputs → MCP标准化 → 智能工具选择',
    tags: ['基础模式', '工具调用', '工作流', 'MCP', '入门必学'],
  ),

  // ──────────────────────────────────────────────────────────
  // 2. ReAct
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'react',
    name: 'ReAct 推理-行动循环',
    englishName: 'ReAct (Reasoning + Acting)',
    subtitle: '思考与行动交替进行，逐步决策并获取外部信息',
    icon: Icons.loop,
    color: Color(0xFF4CAF50),
    overview: '''
ReAct（Reasoning + Acting）是2023年由Yao等人提出的经典Agent架构。它的核心思想是让LLM交替进行"推理"和"行动"，而不是一次性生成最终答案。

在这一模式中，Agent每走一步都会先输出一段推理文字（Thought），然后决定执行什么动作（Action），观察动作结果（Observation）后，再进入下一轮思考。这种"思考-行动-观察"的循环让Agent能够根据外部反馈动态调整策略。

ReAct是目前绝大多数Agent框架的底层循环逻辑，也是理解更复杂架构的基础。论文在HotpotQA和Fever等知识密集型任务上显著优于纯推理或纯行动的基线方法。''',
    corePrinciple: '''
核心三要素循环：

  Thought（思考）→ Action（行动）→ Observation（观察）→ Thought → Action → ...

1. Thought：LLM分析当前情况，推理下一步该做什么
   例："我需要先找到苹果公司2024年的营收数据，让我搜索一下财报"
2. Action：执行具体的工具调用或操作
   例：search("Apple 2024 annual revenue")
3. Observation：获取行动的结果，作为下一轮思考的输入
   例："搜索结果显示苹果2024财年营收为3910亿美元"

关键洞察：推理和行动不是分离的阶段，而是交织在一起的。推理指导行动，行动结果反过来修正推理方向。''',
    workflow: '''
┌──────────────────────────────────────────────┐
│             ReAct 完整执行流程              │
├──────────────────────────────────────────────┤
│                                              │
│  用户问题："苹果2024年营收比微软多多少？"   │
│                                              │
│  Round 1:                                    │
│  💭 Thought: 需要查苹果和微软的2024年营收    │
│  🎬 Action: search("Apple 2024 revenue")     │
│  👁 Observation: Apple revenue: \$391B         │
│                                              │
│  Round 2:                                    │
│  💭 Thought: 苹果是391B，现在需要查微软      │
│  🎬 Action: search("Microsoft 2024 revenue")  │
│  👁 Observation: Microsoft revenue: \$245B     │
│                                              │
│  Round 3:                                    │
│  💭 Thought: 两个数据都有了，391B-245B=146B  │
│  🎬 Action: Finish("苹果比微软多1460亿美元") │
│                                              │
│  最终输出：苹果2024年营收比微软多约1460亿美元│
└──────────────────────────────────────────────┘''',
    detailedContent: '''
【ReAct vs 纯推理 vs 纯行动】

| 维度 | 纯推理(CoT) | 纯行动 | ReAct |
|------|-----------|--------|-------|
| 幻觉问题 | 严重（编造事实） | 较低 | 低（事实可追溯） |
| 推理能力 | 强 | 弱 | 强（推理+事实交织） |
| 可解释性 | 中等 | 低 | 高（每步推理可见） |
| 适应性 | 无法纠错 | 盲目试错 | 动态纠错 |
| Token消耗 | 低 | 中 | 高（每步重新编码历史） |

【ReAct的关键设计决策】

1. 提示词模板设计
   ReAct的prompt需要明确定义三个角色：
   - Thought: 推理当前状态，规划下一步
   - Action: 指定要调用的工具和参数
   - Observation: 被动接收工具返回结果

   典型模板：
   """
   You have access to the following tools:
   - search(query: str): Search the web
   - calculator(expr: str): Evaluate math expression

   Use the format:
   Thought: <your reasoning>
   Action: <tool_name>(<args>)
   Observation: <result>
   ... (repeat until you know the answer)
   Thought: I now know the answer
   Final Answer: <answer>
   """

2. 终止条件
   - 模型输出Final Answer时自然终止
   - 达到最大步数限制时强制终止
   - 连续无效行动时提前终止

3. 少样本示例（Few-shot Examples）
   ReAct性能高度依赖示例质量。通常需要2-5个完整的多步推理示例。

4. 上下文窗口管理
   ReAct每步都将历史积累到上下文中，N步后可能超过窗口限制。
   缓解策略：
   - 滑动窗口：只保留最近K步
   - 摘要压缩：将早期步骤压缩为摘要
   - 分层记忆：重要信息存入外部记忆

【ReAct的局限性】

1. 贪心短视：每一步只基于当前信息选择下一个工具，缺乏全局规划。在需要协调多个工具完成复杂任务时容易走弯路。

2. Token消耗大：每一步都需要把完整的对话历史（包括所有之前的推理、工具调用和结果）发送给LLM，导致token使用量随步数线性增长。

3. 串行执行：默认情况下，ReAct一次只能调用一个工具，有依赖关系的工具链延迟叠加。

4. 容易陷入循环：在某些情况下，Agent可能反复执行相同的无效操作。''',
    pros: '''
• 推理过程完全透明，每一步思考都可见
• 能够根据外部反馈动态调整策略
• 有效减少幻觉（事实来源于工具返回）
• 可解释性强，适合审计和调试
• 实现简单，几乎不需要额外基础设施
• 作为其他复杂架构的底层循环基础''',
    cons: '''
• 串行执行，延迟叠加
• Token消耗随步数线性增长
• 贪心策略，可能陷入局部最优
• 缺乏全局规划，复杂任务效率低
• 容易陷入重复循环
• 对Prompt模板和Few-shot示例敏感''',
    useCases: '''
• 知识密集型问答：搜索→阅读→推理→回答
• 客户服务分流：理解问题→查询信息→引导解决
• 交互式代码调试：读错误→分析→修复→测试→重复
• 购物决策：搜索→比较→查评价→推荐
• 研究辅助：检索论文→提取信息→综合结论
• 故障排查：检查症状→查知识库→执行诊断→定位根因''',
    implementations: '''
• LangChain AgentExecutor (ReActAgent)
• LangGraph createReactAgent()
• LlamaIndex ReActAgent
• AutoGen ConversableAgent (ReAct模式)
• CrewAI Agent (内置ReAct循环)
• BeeAI Framework ReActAgent
• 各框架的基本Agent实现几乎都基于ReAct变体''',
    papers: '''
• ReAct: Synergizing Reasoning and Acting in Language Models (Yao et al., ICLR 2023)
  论文链接: https://arxiv.org/abs/2210.03629
• STaR: Self-Taught Reasoner (Zelikman et al., 2022) — ReAct的先驱工作
• Chain-of-Thought Prompting Elicits Reasoning in LLMs (Wei et al., 2022)''',
    evolutionPath: 'CoT推理 → ReAct融合推理+行动 → Agent循环标准化 → 各种衍生架构',
    tags: ['经典模式', '推理-行动', '基础循环', '必学核心'],
  ),

  // ──────────────────────────────────────────────────────────
  // 3. Router + Dispatcher
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'router_dispatcher',
    name: '路由 + 分发模式',
    englishName: 'Router + Dispatcher',
    subtitle: '轻量路由器对意图分类，分发到专业Agent，实现高效分工',
    icon: Icons.alt_route,
    color: Color(0xFFFF9800),
    overview: '''
Router + Dispatcher 是一种生产环境中非常实用的架构模式。它由一个轻量级"路由器"模型对用户请求进行分类，然后根据意图将任务分发到不同的专业Agent处理。

这一模式的核心洞察是：不是所有任务都需要最强大的模型和最复杂的推理。通过"分类-分发"的架构，可以用便宜的模型处理简单任务，只在必要时动用大模型和专业Agent。

2024-2025年，这种模式在大型AI产品中广泛采用，因为它能显著降低成本和延迟，同时保持高质量输出。''',
    corePrinciple: '''
架构组成：

  [用户输入]
       ↓
  ┌──────────┐
  │  Router  │ ← 轻量模型（如GPT-4o-mini），做意图分类
  │  路由器   │    输出：{intent: "search", confidence: 0.92}
  └────┬─────┘
       │  分发（Dispatch）
  ┌────┼──────────────┐
  ↓    ↓      ↓       ↓
[搜索] [SQL] [代码] [闲聊]  ← 专业Agent（不同模型/工具/提示词）
  └────┼──────────────┘
       ↓
  [结果聚合/直接返回]

关键角色：
- Router：意图识别 + 分发决策，追求低延迟低成本
- Dispatcher：任务队列管理 + 并行分发 + 结果聚合
- Specialist Agent：每个专精一个领域，可有自己的工具和模型''',
    workflow: '''
Step 1 — 意图分类（Router）
  用户："帮我查一下上周的订单数据"
  → Router分析：意图=SQL查询，置信度=0.95
  → 分类结果：路线=SQLAgent

Step 2 — 分发（Dispatcher）
  → 检查SQLAgent是否空闲
  → 将任务加入队列或立即分发
  → 附带上下文：用户原始问题+分析出的参数

Step 3 — 专业执行（Specialist）
  SQLAgent收到："查上周订单数据"
  → 理解需求：SELECT * FROM orders WHERE date >= ...
  → 执行查询，获取结果
  → 格式化返回

Step 4 — 聚合返回
  → Dispatcher接收结果
  → 如果涉及多个Agent，聚合结果
  → 返回用户

【路由策略】
1. Intent-based Routing：基于NLU意图分类 → 最常用
2. Semantic Routing：基于语义相似度 → 灵活但计算量大
3. Keyword-based Routing：关键词匹配 → 快速但粗糙
4. Hybrid Routing：组合以上策略 → 平衡速度和准确率
5. Confidence Fallback：置信度低时走安全默认路径''',
    detailedContent: '''
【2024-2025 双速架构（生产主流）】

这是Router-Dispatcher模式最重要的生产实践：

第一层：Router（便宜模型，如GPT-4o-mini）
  将请求分为三类：
  - single_tool：单步任务，直接调用工具返回
  - multi_step：多步任务，需要规划
  - clarify：意图不明确，需要追问澄清

第二层（仅multi_step时）：Micro-planner
  生成 ≤4步、深度 ≤2的小型DAG
  为每步指派对应的专业Agent

第三层：Graph Executor
  并行执行无依赖的步骤
  支持中断（Human-in-the-Loop）
  结果自动聚合

优势：
- 比纯ReAct延迟更低（关键路径=最长依赖链，而非所有步骤之和）
- 比纯Router更灵活（多步任务有专门处理）
- Token消耗大幅降低（简单任务不走复杂流程）

【Router设计最佳实践】

1. Router应该"快速失败"
   - 低置信度时不硬猜，而是转人工或追问
   - 路由错误的成本远高于路由延迟

2. 路由粒度
   - 太粗：专业Agent需要处理过于多样化的任务（能力退化）
   - 太细：路由表爆炸，维护困难
   - 建议：5-15个路由目标，每个有明确边界

3. 路由可观测性
   - 记录每次路由决策和置信度
   - 监控路由准确率，持续优化路由规则
   - 建立路由错误反馈闭环''',
    pros: '''
• 成本优化：简单任务用便宜模型，复杂任务才用大模型
• 延迟降低：单步任务直接处理，不经过复杂推理
• 专业化：每个Agent专精一个领域，效果更好
• 可扩展：新增能力只需添加新Agent+路由规则
• 可观测：每一步路由决策都清晰可见
• 生产友好：已被大量产品验证''',
    cons: '''
• 路由错误会级联放大（分错Agent=完全无法处理）
• 路由规则维护成本随Agent数量增长
• 边界模糊的请求可能被错误分类
• Router本身有延迟开销（通常100-300ms）
• 跨领域任务需要多个Agent协作时复杂
• 需要持续监控路由准确率并调优''',
    useCases: '''
• 企业智能助手：HR问题→HR Agent，IT问题→IT Agent，财务→财务Agent
• 电商客服：订单查询→OrderAgent，退货→RefundAgent，投诉→EscalationAgent
• 代码平台：前端→FrontendAgent，后端→BackendAgent，DevOps→DevOpsAgent
• 搜索系统：网页搜索→SearchAgent，数据库→SQLAgent，文档→DocAgent
• 知识库问答：产品文档→ProductAgent，技术文档→TechAgent，政策→PolicyAgent''',
    implementations: '''
• Semantic Router (开源库): 语义路由专用框架
• LangChain RouterChain + MultiPromptChain
• LlamaIndex RouterQueryEngine
• OpenAI Swarm (轻量路由+Agent切换)
• Google Vertex AI Agent Builder (内置路由)
• AWS Bedrock Agents (协作模式中的路由)''',
    papers: '''
• Semantic Router: Fast Semantic Route Decision for LLM Applications (Aurelio AI, 2024)
• Guided Agent Funnel: Router → Micro-planner → Graph Executor (2024 Industry Best Practice)
• JARVIS Multi-Agent Architecture (Cisco Outshift, 2024)''',
    evolutionPath: '简单if-else路由 → 语义路由 → 双速架构 → 动态Agent生成路由',
    tags: ['生产实践', '意图分类', '成本优化', '双速架构'],
  ),

  // ──────────────────────────────────────────────────────────
  // 4. Supervisor
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'supervisor',
    name: '监督者模式',
    englishName: 'Supervisor Pattern',
    subtitle: '层级结构中有一个监督Agent持续监控、动态委派和协调子Agent',
    icon: Icons.supervisor_account,
    color: Color(0xFF9C27B0),
    overview: '''
Supervisor（监督者）模式是一种层级化的多Agent架构。与Router的一次性分类不同，Supervisor在整个任务执行过程中持续监控进度，动态委派子任务给专业Agent，并在必要时重新分配或调整策略。

可以把Supervisor想象成项目管理者：它自己不执行具体工作，但负责理解整体目标、分解任务、分配给合适的人、监控进度、处理阻塞、最终整合结果。

Supervisor与Router的关键区别：
- Router：一次性分类 → 分发 → 结束（像一个接线员）
- Supervisor：持续监控 → 动态委派 → 协调 → 调整 → 聚合（像一个项目经理）''',
    corePrinciple: '''
层级结构：

                ┌─────────────┐
                │ Supervisor  │  ← 全局监控+任务分解+委派
                │  监督者Agent │
                └──┬──┬──┬───┘
                   │  │  │
         ┌─────────┘  │  └─────────┐
         ↓            ↓            ↓
    ┌────────┐  ┌────────┐  ┌────────┐
    │Research│  │ CodeGen│  │  Test  │  ← 专业Worker Agent
    │ Agent  │  │ Agent  │  │ Agent  │
    └────────┘  └────────┘  └────────┘

Supervisor的核心职责：
1. 任务理解与分解：把用户目标拆成可执行的子任务
2. 动态委派：根据当前状态选择最合适的Worker
3. 进度监控：跟踪各Worker的执行状态
4. 冲突协调：处理Worker之间的依赖和冲突
5. 结果聚合：将各Worker的输出整合为最终答案
6. 异常处理：Worker失败时重新分配或降级处理''',
    workflow: '''
Step 1 — 任务分解
  Supervisor接收："帮我写一篇关于AI Agent架构的技术博客"
  → 分解为子任务：
    1. 搜索AI Agent架构最新资料（ResearchAgent）
    2. 整理大纲和要点（WriterAgent）
    3. 撰写正文（WriterAgent）
    4. 检查代码示例（CodeAgent）
    5. 审查和润色（CriticAgent）

Step 2 — 动态委派
  Supervisor将任务1委派给ResearchAgent
  → 等待ResearchAgent返回搜索结果
  → 检查结果质量，决定是否需要补充搜索

Step 3 — 依赖管理
  ResearchAgent完成 → Supervisor将结果传给WriterAgent
  → WriterAgent整理大纲 → Supervisor审核大纲
  → 审核通过 → WriterAgent继续撰写正文
  → 正文部分完成 → 并行分发：CodeAgent检查代码 + CriticAgent审查文字

Step 4 — 异常处理
  CodeAgent报告某个代码示例有误
  → Supervisor决定：让CodeAgent修复 → 修复后WriterAgent更新正文

Step 5 — 最终聚合
  所有子任务完成 → Supervisor审核最终输出
  → 确认质量达标 → 返回用户''',
    detailedContent: '''
【Supervisor vs Router 详细对比】

| 维度 | Router | Supervisor |
|------|--------|------------|
| 决策次数 | 1次（入口分类） | N次（持续决策） |
| 任务粒度 | 整个请求 | 子任务级 |
| 上下文 | 用户原始输入 | 完整执行历史 |
| 协调能力 | 无 | 强（依赖管理） |
| Agent关系 | 无交互 | 协调+仲裁 |
| 适用复杂度 | 简单-中等 | 中等-复杂 |
| 延迟 | 低 | 中等 |

【Supervisor的三种委派策略】

1. 顺序委派（Sequential）
   Agent A → Agent B → Agent C
   适用：有明确顺序依赖的任务

2. 并行委派（Parallel）
   Agent A ↘
   Agent B → Supervisor 聚合
   Agent C ↗
   适用：无依赖的独立子任务

3. 动态委派（Dynamic）
   Supervisor实时判断下一步该委派给谁
   根据中间结果动态调整计划
   适用：探索性任务，路径不确定

【实现Supervisor的技术要点】

1. Supervisor的提示词设计
   需要包含：
   - 所有Worker Agent的能力描述
   - 委派决策的格式规范
   - 进度追踪的模板
   - 异常处理策略

2. 全局状态管理
   - 任务队列：待执行的子任务
   - 执行历史：已完成的任务和结果
   - Agent状态：各Worker是否忙碌/可用

3. 通信协议
   - Supervisor → Worker：任务描述+输入数据
   - Worker → Supervisor：执行结果+置信度+遇到的问题
   - Worker ↔ Worker：通常不直接通信，通过Supervisor中转

【JARVIS案例】
Cisco的JARVIS系统是最著名的Supervisor生产实现：
- Supervisor作为"语义路由器"
- Reflection Agent做LLM-as-Judge评估
- 多个专业子Agent分工处理搜索、SQL、代码等任务
- 生产环境验证了数月，延迟和准确率均有显著改善''',
    pros: '''
• 全局视角，能根据整体进度动态调整
• 复杂任务的分解和协调能力强
• Worker Agent可独立优化和替换
• 支持并行执行，提高效率
• 异常处理鲁棒，失败后可重新分配
• 适合长期运行的多步骤任务''',
    cons: '''
• Supervisor本身成为瓶颈和单点故障
• 架构复杂度高，调试困难
• Supervisor的提示词设计难度大
• 多次委派带来额外的延迟和Token消耗
• Worker之间的依赖管理复杂
• 需要精心设计Worker的能力边界''',
    useCases: '''
• 长篇内容创作：研究→大纲→撰写→审查→润色
• 复杂软件工程：需求分析→架构设计→编码→测试→文档
• 数据分析报告：数据收集→清洗→分析→可视化→撰写
• 学术研究辅助：文献检索→提取→综合→写作→查重
• 多步骤业务流程：订单处理→库存检查→支付→发货通知
• 安全审计：扫描→分析→评级→报告→修复建议''',
    implementations: '''
• LangGraph Supervisor (create_supervisor())
• CrewAI Hierarchical Process
• AutoGen GroupChat with Manager
• Semantic Kernel Process Framework
• JARVIS (Cisco Outshift)
• MetaGPT Role-Based Collaboration''',
    papers: '''
• JARVIS: A Technical Deep Dive into Multi-Agent System Design (Cisco, 2024)
• AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation (Wu et al., 2024)
• MetaGPT: Meta Programming for Multi-Agent Collaborative Framework (Hong et al., 2024)
• Agent Transformer: A Comprehensive Survey (ASU, 2025)''',
    evolutionPath: 'Router → Supervisor → Arbiter（动态Agent生成）→ Hierarchical Teams',
    tags: ['多Agent', '层级控制', '任务分解', '动态委派'],
  ),

  // ──────────────────────────────────────────────────────────
  // 5. Reflection / Reflexion
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'reflection',
    name: '反思模式',
    englishName: 'Reflection / Reflexion',
    subtitle: 'Agent产出后自我批评，记录反思，修正后重新生成更高质量输出',
    icon: Icons.self_improvement,
    color: Color(0xFFE91E63),
    overview: '''
Reflection（反思）是AI Agent中一种重要的自我提升架构。核心思想是让Agent对自己的输出进行自我批评、记录反思经验，然后基于反思修正输出，反复迭代直到达到满意的质量。

Andrew Ng（吴恩达）将其列为四大Agent设计模式之一（另外三个是Planning、Tool Use、Multi-agent Collaboration）。

Reflexion（Shinn et al., 2023）是该模式的里程碑论文。它证明了不需要微调模型，仅通过在推理时加入"口头反思"机制，就能让GPT-4在HumanEval代码生成任务上从80%提升到91%的准确率。''',
    corePrinciple: '''
核心三阶段循环：

  Generate（生成） → Reflect/Critique（反思/批评） → Refine（修正） → Repeat

1. Actor（生成者）：生成初始输出
   - 使用ReAct或Chain-of-Thought进行推理和生成

2. Evaluator（评估者）：对输出进行评分和批评
   - LLM-as-Judge：用LLM做评估
   - Heuristic Rules：基于规则（如测试用例通过率）
   - External Validators：外部验证器（编译器检查等）

3. Self-Reflection（自我反思）：生成自然语言反馈
   - 分析失败原因："上次的输出在内存管理部分有错误..."
   - 提出改进策略："下次应该先检查变量作用域..."
   - 存入Episodic Memory供后续尝试参考

关键创新：记忆系统中的"反思记忆"
- 存储的不是原始数据，而是对错误的抽象分析
- 可以在未来的类似任务中复用这些经验''',
    workflow: '''
具体执行示例（代码生成任务）：

Attempt 1:
  ├─ Generate: 生成代码实现
  ├─ Execute: 运行测试用例 → 3/5通过
  ├─ Reflect: "测试2失败是因为忘记处理空列表的边界情况
  │           测试5失败是因为返回值类型不匹配"
  ├─ Store: 将反思存入记忆 {"边界检查": "始终检查空输入",
  │         "返回值": "确保与函数签名一致"}
  └─ Refine: 基于反思修改代码

Attempt 2:
  ├─ Generate: 生成修正后的代码（加载了之前的反思记忆）
  ├─ Execute: 运行测试用例 → 5/5通过 ✓
  └─ Return: 返回通过测试的代码

典型指标：
- 最佳迭代次数：2-3次（超过3次收益递减）
- 代码生成：GPT-4 + Reflexion 在HumanEval上91% vs 80%基准
- AlfWorld任务：130/134完成 vs 基准的更低完成率''',
    detailedContent: '''
【Reflection vs Reflexion 的区别】

Reflection（反思）是广义概念，Reflexion是具体的实现框架。

Reflexion框架的三个核心组件：
1. Actor — 生成行动/文本（通常使用ReAct或CoT）
2. Evaluator — 对输出进行评分（启发式/LLM-Judge/环境信号）
3. Self-Reflection — 生成自然语言反馈存入情景记忆

【评估器的三种类型】

1. 启发式评估器（Heuristic Evaluator）
   - 代码生成：运行测试用例，统计通过率
   - 数学题：验证最终答案
   - 搜索任务：检查是否找到目标
   - 优点：客观、快速、可重复
   - 缺点：只适用于有明确标准的任务

2. LLM-as-Judge评估器
   - 让另一个LLM（或同一LLM）评估输出质量
   - 评价维度：准确性、完整性、流畅性、安全性等
   - 优点：灵活，适用于开放式任务
   - 缺点：LLM评估本身有偏差和不确定性

3. 工具交互式评估器（Tool-Interactive / CRITIC）
   - 使用外部工具验证事实
   - 例：搜索结果交叉验证、代码编译器检查
   - 优点：客观验证，不依赖LLM判断
   - 缺点：需要对应的验证工具

【反思记忆的设计】

关键设计决策：
- 滑动窗口：只保留最近N条反思
- 向量存储：用embedding检索相关历史反思
- 结构化存储：按错误类型分类存储
- 记忆增强Prompt：启动时加载相关反思到上下文中

最佳实践：
- 反思要具体：不是"代码不好"，而是"函数foo在第12行缺少空指针检查"
- 反思要可执行：不仅指出问题，还要给出修改方向
- 反思要"去重"：类似的反思合并，避免记忆膨胀

【何时使用Reflection】
✓ 代码生成、数学推理等有明确评判标准的任务
✓ 报告撰写、文档审查等需要打磨质量的任务
✓ 复杂决策中需要多轮校准的场景
✗ 实时对话等延迟敏感场景
✗ 没有明确质量标准的开放式创意任务
✗ 评估本身就不可靠的任务''',
    pros: '''
• 无需微调模型即可显著提升输出质量
• 错误经验可积累和复用
• 可解释性强，反思过程可见
• 与多种基础架构兼容
• 适合需要高质量输出的场景
• 能够发现和修正系统性错误''',
    cons: '''
• 额外计算开销（每次反思=额外的LLM调用）
• 延迟增加（2-3次迭代意味着2-3倍时间）
• 评估器本身可能不准确（LLM-Judge的局限性）
• 可能"过度反思"导致输出变差
• 没有明确评判标准的任务效果有限
• 反思记忆可能过时或产生误导''',
    useCases: '''
• 代码生成+自动修复：生成→运行测试→反思失败原因→修复
• 学术写作：初稿→自我审查→修正→再审查→终稿
• 数学推理：尝试求解→验证答案→反思错误→重新求解
• 翻译质量提升：翻译→对照检查→修正不准确处→润色
• 政策合规检查：生成回复→审查合规性→修改违规处→确认
• 复杂诊断：初步诊断→验证→反思遗漏→补充检查→最终诊断''',
    implementations: '''
• LlamaIndex IntrospectiveAgent (SelfReflectionAgentWorker)
• LangGraph Reflexion Tutorial (Actor + Pydantic结构化反思)
• MoFA (mofa-org): 内核级ThoughtStepType::Reflection
• LangChain Reflexion implementation
• Microsoft PromptFlow (支持Reflection变体)
• CrewAI (支持内置Reflection步骤)''',
    papers: '''
• Reflexion: Language Agents with Verbal Reinforcement Learning (Shinn et al., 2023)
  论文链接: https://arxiv.org/abs/2303.11366
• CRITIC: Large Language Models Can Self-Correct with Tool-Interactive Critiquing (Gou et al., 2024)
• Self-Refine: Iterative Refinement with Self-Feedback (Madaan et al., 2023)
• Self-Discover: LLMs Self-Compose Reasoning Structures (Zhou et al., 2024)''',
    evolutionPath: '基础Self-Correction → Reflexion框架 → CRITIC工具验证 → 多维度反思 → 持久化反思记忆',
    tags: ['自我提升', '质量优化', '反思学习', '迭代改进'],
  ),

  // ──────────────────────────────────────────────────────────
  // 6. Plan-Execute
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'plan_execute',
    name: '规划-执行模式',
    englishName: 'Plan-Execute (Planner-Executor)',
    subtitle: '规划器将目标分解为子任务，执行器逐个完成，计划可动态调整',
    icon: Icons.playlist_add_check,
    color: Color(0xFF00BCD4),
    overview: '''
Plan-Execute（规划-执行）架构将Agent的任务处理分为两个明确分离的阶段：先制定完整计划，再逐步执行。这种"先想再做"的模式与ReAct的"边想边做"形成鲜明对比。

Planner负责"战略层"的全局规划，Executor负责"战术层"的具体执行。两者使用不同的提示词和模型配置（Planner通常用更强的模型+低temperature，Executor用更灵活的配置）。

2024-2025年，随着RP-ReAct、NaviAgent等框架的出现，Plan-Execute模式在复杂企业任务中展现出比纯ReAct更好的可控性和可审计性。''',
    corePrinciple: '''
架构分离：

  ┌─────────────────────────────────────┐
  │            Planner（规划器）         │
  │  - 使用低temperature（0.0-0.3）     │
  │  - 更强的推理模型                    │
  │  - 输出结构化计划列表                │
  │  - 可根据执行反馈动态调整计划        │
  └──────────────┬──────────────────────┘
                 │ 下达计划
                 ↓
  ┌─────────────────────────────────────┐
  │           Executor（执行器）         │
  │  - 使用中temperature（0.3-0.7）     │
  │  - 可能使用更轻量的模型              │
  │  - 按计划逐步执行（通常ReAct风格）    │
  │  - 报告执行结果和遇到的问题          │
  └─────────────────────────────────────┘

关键设计原则：
- Planner和Executor使用不同的系统提示词
- 计划不是一成不变的，可根据执行结果调整
- Planner给出的是"做什么"，Executor决定"怎么做"''',
    workflow: '''
以"调研新能源汽车市场并生成报告"为例：

Phase 1 — 规划（Planner）
  输入：调研新能源汽车市场并生成报告
  输出：
  [
    {step: 1, task: "搜索2024-2025年新能源汽车销量数据", agent: "SearchAgent"},
    {step: 2, task: "搜索主要车企的新能源战略和产品线", agent: "SearchAgent"},
    {step: 3, task: "搜索充电基础设施发展状况", agent: "SearchAgent"},
    {step: 4, task: "综合分析以上数据生成5000字报告", agent: "WriterAgent",
     depends_on: [1, 2, 3]},
    {step: 5, task: "审查报告的数据准确性和逻辑", agent: "CriticAgent",
     depends_on: [4]},
    {step: 6, task: "根据审查意见修改报告", agent: "WriterAgent",
     depends_on: [5]},
  ]

Phase 2 — 执行（Executor）
  并行执行Step 1, 2, 3（无依赖关系）
  → 等待完成
  → 执行Step 4（依赖1/2/3完成）
  → 执行Step 5
  → 执行Step 6

Phase 3 — 动态调整（可选）
  如果Step 3发现充电桩数据不够，Planner调整：
  → 插入新步骤: "搜索充电基础设施行业报告"
  → 更新Step 4的依赖关系''',
    detailedContent: '''
【Plan-Execute 变体】

1. 静态规划（Static Plan）
   - 一次性生成完整计划，执行过程中不修改
   - 代表：ReWOO
   - 优点：Token消耗最少，可预测
   - 缺点：无法应对意外情况

2. 动态重规划（Dynamic Replan）
   - 每执行一步后重新评估和调整计划
   - 代表：标准的Plan-Execute
   - 优点：灵活，能应对变化
   - 缺点：额外的LLM调用

3. 层级规划（Hierarchical Plan）
   - 多层级计划：高层目标 → 中层步骤 → 底层行动
   - 代表：NaviAgent（双层规划）
   - 优点：处理复杂任务能力强
   - 缺点：架构复杂

【RP-ReAct (2025) 创新设计】

这是Plan-Execute的最新演进：

- Reasoner-Planner Agent (RPA)：负责规划每个子步骤，分析执行结果
- Proxy-Execution Agent (PEA)：将子步骤翻译为具体的工具交互
- Context-saving策略：大型工具输出存储为外部引用，避免上下文溢出
- 解决的核心问题：开源小模型执行复杂任务时上下文窗口不够用

【计划的数据结构】

典型的计划结构：
```
{
  "goal": "调研新能源汽车市场",
  "steps": [
    {
      "id": 1,
      "description": "搜索销量数据",
      "agent": "SearchAgent",
      "depends_on": [],
      "expected_output": "2024年各品牌销量表格"
    },
    ...
  ],
  "success_criteria": "报告包含销量数据、竞争格局、趋势预测",
  "max_steps": 10,
  "replan_threshold": 0.7  // 执行成功率低于70%时触发重规划
}
```''',
    pros: '''
• 全局规划能力强，不会陷入局部最优
• 支持并行执行无依赖的步骤
• 可审计：计划清晰可见，可人工审核
• 执行效率高（并行步骤同时进行）
• 动态调整：失败不从头开始
• 适合企业级复杂任务''',
    cons: '''
• 初始规划可能不准确（Garbage in, garbage out）
• 规划本身有额外的LLM开销
• 过于详细的计划可能浪费时间
• 过于简化的计划可能不够用
• 静态规划对意外情况鲁棒性差
• Planner和Executor的协调增加复杂度''',
    useCases: '''
• 市场调研：搜索→收集数据→分析→撰写报告
• 旅行规划：查航班→查酒店→查景点→制定行程→优化
• 软件开发：需求分析→技术选型→架构设计→编码→测试
• 学术文献综述：检索→筛选→精读→整理→撰写
• 竞品分析：确定竞品→收集信息→对比分析→输出报告
• 活动策划：确定主题→场地→人员→物料→时间线''',
    implementations: '''
• LangGraph Plan-Execute Agent (官方教程)
• LlamaIndex Plan-Execute Agent
• RP-ReAct (开源框架，2025)
• NaviAgent (双层规划，2025)
• LangChain PlanAndExecute Agent
• Smolagents (HuggingFace) Plan-Execute''',
    papers: '''
• RP-ReAct: Reasoner-Planner Supervising ReAct Executor (Dec 2025)
  论文链接: https://arxiv.org/abs/2512.03560
• NaviAgent: Bilevel Planning on Tool Navigation Graph (Jun 2025)
• JoyAgent-JDGenie: Combining Supervisor (Plan-Execute) with Single Agents (ReAct) (Oct 2025)
• Plan-and-Solve Prompting (Wang et al., 2023)''',
    evolutionPath: '静态计划 → 动态重规划 → 层级规划 → RP-ReAct → NaviAgent双层规划',
    tags: ['任务分解', '战略规划', '并行执行', '企业级'],
  ),

  // ──────────────────────────────────────────────────────────
  // 7. LLMCompiler
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'llm_compiler',
    name: 'LLMCompiler 并行编译执行',
    englishName: 'LLMCompiler',
    subtitle: '借鉴编译器设计思想，DAG建模工具依赖，并行执行无依赖步骤',
    icon: Icons.memory,
    color: Color(0xFF795548),
    overview: '''
LLMCompiler（Kim et al., ICML 2024）是UC Berkeley SqueezeAILab提出的创新架构。它将Agent的函数调用过程类比为编译器的工作流程：先分析依赖关系，再并行调度执行。

传统ReAct的串行工具调用就像逐行解释执行代码，而LLMCompiler则像编译器一样——先构建依赖图（DAG），识别可并行的部分，然后一次性调度执行。

这种"编译器思维"带来了革命性的性能提升：延迟降低3.7倍，成本节省6.7倍，同时因为给了LLM更完整的上下文，准确率反而提升了9%。''',
    corePrinciple: '''
编译器类比：

  传统编译器流程        →    LLMCompiler映射
  ┌──────────────┐         ┌────────────────────┐
  │ Lex/Parse    │    →    │ Function Planner   │  分析任务，识别所需工具
  │ 词法/语法分析 │         │ 函数调用规划器      │
  ├──────────────┤         ├────────────────────┤
  │ DAG Build    │    →    │ Dependency Graph   │  构建工具调用依赖图
  │ 构建依赖图    │         │ 依赖图构建          │
  ├──────────────┤         ├────────────────────┤
  │ Schedule     │    →    │ Task Fetching Unit │  拓扑排序，调度并行任务
  │ 并行调度      │         │ 任务调度单元         │
  ├──────────────┤         ├────────────────────┤
  │ Execute      │    →    │ Executor           │  并行执行无依赖的函数调用
  │ 执行          │         │ 执行器              │
  ├──────────────┤         ├────────────────────┤
  │ Join         │    →    │ Result Aggregation │  汇总结果，生成最终输出
  │ 结果汇合      │         │ 结果聚合            │
  └──────────────┘         └────────────────────┘

核心创新：在一次LLM调用中规划所有工具调用并分析依赖关系，而不是每次只规划一步。''',
    workflow: '''
具体执行示例：

任务："比较苹果和微软的市值、营收、员工数量"

Step 1 — Function Planner（一次LLM调用）
  输出DAG：
  ┌─────────────────────────────────┐
  │  search("Apple market cap")     │ ← 无依赖，可并行
  │  search("MSFT market cap")      │ ← 无依赖，可并行
  │  search("Apple revenue 2024")   │ ← 无依赖，可并行
  │  search("MSFT revenue 2024")    │ ← 无依赖，可并行
  │  search("Apple employee count") │ ← 无依赖，可并行
  │  search("MSFT employee count")  │ ← 无依赖，可并行
  └──────────┬──────────────────────┘
             ↓ 所有搜索完成后
  ┌─────────────────────────────────┐
  │ synthesize(所有搜索结果) → 比较表格│ ← 依赖所有搜索
  └─────────────────────────────────┘

Step 2 — 并行执行（Task Fetching Unit + Executor）
  → 6个搜索调用同时发出（而非逐条执行）
  → 等待所有搜索完成
  → 执行数据综合

Step 3 — 结果聚合
  → 生成完整的比较分析表格

时间对比：
  ReAct: search1→search2→search3→...→search6→synthesize ≈ 7×2s = 14s
  LLMCompiler: parallel(6×search) + synthesize ≈ 2s + 2s = 4s
  提升：3.5倍''',
    detailedContent: '''
【DAG（有向无环图）的构建】

LLMCompiler中的DAG节点代表工具调用，边代表数据依赖关系。

依赖类型：
1. 数据依赖：工具B需要工具A的输出作为输入
2. 资源依赖：两个工具访问同一资源，需要顺序执行
3. 无依赖：可完全并行执行

LLM通过上下文学习（few-shot）来识别依赖关系：
```
示例：
Task: "Find the population of the capital of France"
Tools: search(query), wiki(entity)
DAG:
  Step 1: search("capital of France") [no dependencies]
  Step 2: wiki(#1.result) [depends on Step 1]
```

【Task Fetching Unit 调度算法】

基于拓扑排序的并行调度：
1. 初始化：找出所有入度为0的节点（无依赖的任务）
2. 发射：将所有就绪任务加入执行队列
3. 等待：任一任务完成后，检查是否有新任务就绪
4. 重复2-3直到所有任务完成

关键优化：
- 动态重排序：如果工具A先完成但工具B更关键，优先处理B的结果
- 超时处理：某任务超时后不影响其他并行任务的继续执行
- 早期终止：如果某步骤的结果已经能回答用户问题，后续步骤可取消

【性能数据（来自论文）】

| 指标 | ReAct | LLMCompiler | 提升 |
|------|-------|-------------|------|
| 延迟 (P50) | ~15s | ~4s | 3.7× |
| Token消耗 | ~5000 | ~750 | 6.7× |
| 准确率 | 基准 | +9% | - |
| 工具调用准确率 | 基准 | 基准+ | 更完整的上下文 |

【TinyAgent: 端侧部署】

LLMCompiler的重要应用是TinyAgent——在手机/笔记本等设备上运行小模型Agent。
- 模型：小型语言模型（1-7B参数）
- 场景：离线/隐私敏感的Agent任务
- 成效：在约60个工具的规模下维持>90%准确率''',
    pros: '''
• 延迟大幅降低（并行执行无依赖的工具调用）
• Token消耗显著减少（一次规划 vs 多次反复）
• 准确率反而提升（LLM看到更完整的任务上下文）
• 适合工具密集型任务
• 理论基础扎实（编译器领域成熟思想）
• 支持端侧小模型部署''',
    cons: '''
• 依赖关系判断可能出错（错误依赖导致不必要的串行）
• 规划阶段的一次性LLM调用质量要求高
• 复杂依赖场景下并行度受限
• 对LLM的结构化输出能力要求高
• 工具数量极大时DAG构建本身变复杂
• 需要较高质量的few-shot示例''',
    useCases: '''
• 数据聚合：同时查询多个数据源→汇总分析
• 多平台比价：并行搜索各大电商→比较→推荐
• 并行信息检索：同时搜索多个关键词→交叉验证
• API编排：无依赖的API同步调用→结果合并
• 监控查询：并行查询多个监控指标→综合分析
• 批量处理：同时对多份文档进行相同操作''',
    implementations: '''
• LLMCompiler (UC Berkeley): https://github.com/SqueezeAILab/LLMCompiler
• LangGraph (支持DAG并行执行模式)
• LlamaIndex Workflows (事件驱动+num_workers并发)
• BeeAI Framework (支持LLMCompiler模式)
• TinyAgent (基于LLMCompiler的端侧Agent)''',
    papers: '''
• LLMCompiler: An LLM Compiler for Parallel Function Calling (Kim et al., ICML 2024)
  论文链接: https://arxiv.org/abs/2312.04511
  GitHub: https://github.com/SqueezeAILab/LLMCompiler
• TinyAgent: Function Calling at the Edge (Berkeley, 2024)
• Task Decomposition and Parallel Scheduling in LLM Agents (多篇扩展研究)''',
    evolutionPath: '串行ReAct → 识别并行机会 → LLMCompiler DAG规划 → 端侧TinyAgent → 与MCP结合',
    tags: ['并行执行', '编译器思想', '性能优化', 'DAG'],
  ),

  // ──────────────────────────────────────────────────────────
  // 8. ReWOO
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'rewoo',
    name: 'ReWOO 无需观察的推理',
    englishName: 'ReWOO (Reasoning WithOut Observation)',
    subtitle: '将推理与观察解耦，先制定完整蓝图再执行，大幅减少Token消耗',
    icon: Icons.architecture,
    color: Color(0xFF607D8B),
    overview: '''
ReWOO（Reasoning WithOut Observation，Xu et al., 2024）是一种革命性的Agent架构，它的核心洞察是：ReAct每一步都将完整上下文回传LLM，导致Token使用量呈二次增长——这是Agent效率低下的根本原因。

ReWOO通过将推理（Reasoning）与观察（Observation）完全解耦来解决这个问题。它只调用两次LLM：一次做规划（Planner），一次做最终推理（Solver）。中间的工具执行完全不经过LLM。

这种方法带来了5倍的Token效率提升，同时准确率反而提高了4%。更令人兴奋的是，ReWOO的Planner训练不需要真实的工具调用数据，这使得它可以进行知识蒸馏——将大模型（GPT-3.5 175B）的规划能力蒸馏到小模型（LLaMA 7B）。''',
    corePrinciple: '''
ReWOO的三个模块：

  [用户问题]
       ↓
  ┌──────────┐
  │ Planner  │ ← 第1次LLM调用
  │  规划器   │   输出完整的执行蓝图：（计划, #E1, 计划, #E2, ...）
  └────┬─────┘   用 #Ex 作为变量占位符标记需要工具返回的数据
       ↓
  ┌──────────┐
  │  Worker  │ ← 0次LLM调用（只执行工具）
  │  执行器   │   按顺序执行工具，将 #Ex 替换为真实的工具返回结果
  └────┬─────┘   不做任何推理，不做任何决策
       ↓
  ┌──────────┐
  │  Solver  │ ← 第2次LLM调用
  │  求解器   │   综合所有计划+真实证据，生成最终答案
  └──────────┘

关键创新：Worker完全不调用LLM，只是机械地执行工具并将结果填入占位符。
这避免了ReAct中每步都需要LLM处理冗余历史上下文的问题。''',
    workflow: '''
具体示例：HotpotQA问答

问题："《盗梦空间》的导演和《星际穿越》的导演是同一个人吗？"

Step 1 — Planner（一次LLM调用）
  输出：
  """
  Plan: 搜索《盗梦空间》的导演
  #E1 = search("Inception director")

  Plan: 搜索《星际穿越》的导演
  #E2 = search("Interstellar director")

  Plan: 比较两位导演是否相同
  """

Step 2 — Worker（无LLM调用）
  执行 search("Inception director") → "Christopher Nolan"
  用结果替换 #E1 = "Christopher Nolan"

  执行 search("Interstellar director") → "Christopher Nolan"
  用结果替换 #E2 = "Christopher Nolan"

Step 3 — Solver（一次LLM调用）
  输入：
  """
  问题：《盗梦空间》的导演和《星际穿越》的导演是同一个人吗？

  证据：
  《盗梦空间》的导演：Christopher Nolan
  《星际穿越》的导演：Christopher Nolan

  请根据以上证据回答问题。
  """

  输出："是的，两部电影的导演都是Christopher Nolan。"

Token对比：
  ReAct所需Token：~12,000（5步×每步2400 tokens）
  ReWOO所需Token：~2,400（Planner ~1500 + Solver ~900）
  节省：5倍''',
    detailedContent: '''
【ReWOO vs ReAct 深度对比】

| 维度 | ReAct | ReWOO |
|------|-------|-------|
| LLM调用次数 | N+1次（N=工具调用数） | 2次 |
| Token复杂度 | O(N²)（每次包含所有历史） | O(1)（两次独立调用） |
| 工具执行 | 交替：Reason→Act→Obs→Reason... | 批量：Plan→Execute All→Solve |
| 对LLM的依赖 | 每步依赖 | 只在规划和求解时依赖 |
| 工具失败鲁棒性 | 中等 | 高（Solver可从Plan推断） |
| 可微调性 | 困难（需要工具调用轨迹） | 容易（Planner/Solver分离训练） |
| 适合的模型规模 | 大模型 | 大小模型均可 |

【ReWOO的关键设计】

1. 变量占位符机制（#E notation）
   #E1, #E2, #E3... 是Planner插入的占位符
   Worker用真实的工具返回值替换这些占位符
   即使工具调用失败，#Ex也会被替换为空或错误信息
   Solver看到的是"计划+真实数据"的完整视图

2. 工具失败鲁棒性
   由于Planner已经给出了完整的推理蓝图，即使某些工具调用失败，
   Solver仍然可以从Planner的推理逻辑中推断出部分答案。
   这是ReWOO相比ReAct的一个重要优势。

3. 知识蒸馏能力
   因为Planner不依赖真实的工具输出，可以用大模型生成规划数据，
   然后用这些数据微调小模型。论文中成功将GPT-3.5的规划能力
   蒸馏到LLaMA 7B，保留了大部分性能。

【ReWOO不适用的场景】
- 高度动态的任务：工具结果完全改变了任务方向
- 需要深层嵌套推理的任务：结果需要反复分析和重新规划
- 实时交互场景：用户需要看到Agent的中间思考过程''',
    pros: '''
• Token效率极高（只有2次LLM调用）
• 适合小模型部署（可知识蒸馏）
• 工具失败鲁棒性好
• 执行过程可预测（计划透明）
• 与ReAct比准确率反而更高（+4%）
• Planner/Solver可独立优化和替换''',
    cons: '''
• 不适合高度动态的任务（无法基于中间结果调整）
• 工具数量和步骤需要提前规划好
• Planner一次性预测所有步骤，可能不准确
• Worker无法做智能决策（完全是机械执行）
• 缺乏中间推理的可视化（对调试不友好）
• 对Planner的规划质量要求高''',
    useCases: '''
• 多跳问答（Multi-hop QA）：搜索多个事实→综合回答
• 信息聚合：收集多源信息→汇总分析
• 事实核查：搜索多个来源→交叉验证→判断真伪
• 简单数据流水线：提取→转换→汇总
• 批量信息检索：多个独立搜索→整理比较
• 报告生成（结构化）：收集数据→填入模板→润色''',
    implementations: '''
• LangGraph ReWOO Implementation (官方示例)
• LangChain JS/TS ReWOO (官方notebook)
• LlamaIndex ReWOO Agent
• Illufly Framework ReWOO模式
• 自定义实现（架构简单，三个模块清晰分离）''',
    papers: '''
• ReWOO: Decoupling Reasoning from Observations for Efficient Augmented Language Models (Xu et al., 2024)
  论文链接: https://arxiv.org/abs/2305.18323
• 知识蒸馏实验：GPT-3.5 Planner → LLaMA 7B (同一论文)
• HotpotQA数据集上的评估：5× Token效率 + 4%准确率提升''',
    evolutionPath: 'ReAct → 识别Token浪费问题 → ReWOO解耦设计 → 知识蒸馏 → 与Plan-Execute融合',
    tags: ['Token优化', '解耦设计', '知识蒸馏', '小模型友好'],
  ),

  // ──────────────────────────────────────────────────────────
  // 9. Tree of Thoughts
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'tree_of_thoughts',
    name: '思维树',
    englishName: 'Tree of Thoughts (ToT)',
    subtitle: '将推理建模为树搜索，同时探索多条路径，BFS/DFS剪枝找到最优解',
    icon: Icons.account_tree_outlined,
    color: Color(0xFF8BC34A),
    overview: '''
Tree of Thoughts（思维树，Yao et al., 2023）是一种将经典搜索算法（BFS/DFS）与LLM推理相结合的Agent架构。它不是像Chain-of-Thought那样单路径推理，也不是像Self-Consistency那样采样多条独立路径，而是主动构建一棵"思维树"——在每个决策点生成多个候选，评估每个候选的前景，然后有策略地探索最有希望的路径。

这种"搜索式推理"让LLM能够解决需要前瞻规划的任务——比如24点游戏、迷你填字游戏、创意写作等。

在GSM8K数学推理上，ToT达到约76.7%准确率（vs. CoT的66.7%），提升约10个百分点。但代价是计算量增加5-8倍。''',
    corePrinciple: '''
搜索树结构：

                    [初始问题]
                   /    |    \
              [思路A] [思路B] [思路C]  ← 第1层：生成3个候选思路
              /  \     |     /  \
          [A1] [A2]  [B1] [C1] [C2]  ← 第2层：对每个有希望的思路继续展开
           ✗    ✓      ✓    ✗    ✓   ← 评估：✗剪枝，✓保留
                |      |         |
              [...]  [...]     [...]  ← 最终找到最优路径

每一步包含两个子步骤：

1. 生成（Generate）：LLM生成k个候选"思路"
   例：对于"24点游戏：4, 9, 8, 2"，生成
   思路A: "先算 8×9=72"
   思路B: "先算 9-2=7"
   思路C: "先算 4+8=12"

2. 评估（Evaluate）：LLM评估每个部分状态
   评分："sure / maybe / impossible"
   思路A: "maybe"（72之后还要处理4和2得24，有希望）
   思路B: "maybe"（7之后还要得到24，有点远）
   思路C: "sure"（12之后需要2得到24，很接近）
   剪枝：去掉被判定为"impossible"的路径''',
    workflow: '''
以24点游戏为例：用数字 4, 9, 8, 2 算出24

ToT使用BFS（宽度优先搜索），每层宽度b=3：

Layer 0: [4, 9, 8, 2]（初始状态）

Layer 1: 生成3个候选思路
  ├─ Path A: 8×9=72, 剩余 [72, 4, 2] → 评估: maybe
  ├─ Path B: 9-2=7, 剩余 [7, 4, 8] → 评估: maybe
  └─ Path C: 4+8=12, 剩余 [12, 9, 2] → 评估: sure ✓

Layer 2: 对保留的路径继续展开
  Path A: 72/4=18, 剩余 [18, 2] → impossible ✗ (剪枝)
  Path B: 7+8=15, 剩余 [15, 4] → maybe
         7×8=56, 剩余 [56, 4] → impossible ✗
  Path C: 12×2=24, 剩余 [24, 9] → 需要处理9...
         12+9=21, 剩余 [21, 2] → maybe
         12×9=108, 剩余 [108, 2] → impossible ✗

Layer 3: 继续探索剩余路径...
  最终在Path C的子路径找到: 12×2=24 ✓

关键参数：
- 分支因子（b）：每层生成几个候选，通常2-5
- 搜索深度（d）：最多探索几层，通常2-4
- 搜索策略：BFS（广度优先）还是DFS（深度优先）''',
    detailedContent: '''
【ToT的两种搜索策略】

1. BFS（广度优先搜索）
   - 按层展开：先生成所有第一层思路，评估后再进入第二层
   - 优点：不会错过好路径，整体探索充分
   - 缺点：计算量大（b^d 级别）
   - 适用：路径深度浅、分支少、需要全局最优

2. DFS（深度优先搜索）
   - 沿一条路径深入到底，不满意再回溯
   - 优点：快速找到可行解
   - 缺点：可能陷入次优路径
   - 适用：只需要一个可行解的任务

【ToT vs 其他模式对比】

| 模式 | 推理方式 | 模型调用次数 | 灵活性 |
|------|---------|------------|--------|
| CoT | 单链推理 | 1次 | 最低 |
| CoT-SC | 多条独立链+投票 | k次 | 低 |
| ToT | 树搜索+剪枝 | b^d 级别 | 高 |
| GoT | 图搜索+合并 | 可变 | 最高 |

【ToT的局限性】

1. 计算成本高
   即使 b=2, d=3，最坏情况需要 1+2+4+8=15次LLM调用
   b=5, d=5 时可达数百次调用（实际不可用）

2. 评估器质量瓶颈
   如果评估器本身的判断不准确，好路径可能被错误剪枝
   这是ToT最核心的风险

3. 任务适用性
   适合：有明确中间状态和评价标准的任务
   不适合：开放式对话、简单事实问答

【ToT的最新发展】

- Graph of Thoughts (GoT, 2024)：将树结构扩展为图结构，支持思路的合并和循环
- Reasoning via Planning (RAP, 2024)：将ToT与MCTS（蒙特卡洛树搜索）结合
- A* for LLM：用A*搜索替代BFS/DFS，更高效地找到最优路径''',
    pros: '''
• 能找到比单链推理更优的解
• 支持回溯和探索（不会死胡同）
• 可解释：完整搜索树可见
• 适用于需要前瞻规划的任务
• 剪枝机制避免全面搜索
• 与人类"多想几步"的思考方式一致''',
    cons: '''
• 计算成本极高（5-8倍于CoT）
• 对评估器质量要求高（错误评估=错误剪枝）
• 延迟大，不适合实时场景
• 复杂任务的分支因子难以控制
• 不适合开放式无评价标准的任务
• 实现复杂度高''',
    useCases: '''
• 数学推理：24点游戏、数学证明、复杂算术
• 逻辑谜题：数独、填字游戏、逻辑推理
• 创意写作（有约束）：特定主题和结构的创作
• 策略规划：需要提前考虑多步后果的决策
• 代码优化：探索多种重构方案，选最优
• 博弈：棋类游戏的最优走法搜索''',
    implementations: '''
• 官方ToT实现 (Princeton NLP): https://github.com/princeton-nlp/tree-of-thought-llm
• LangGraph ToT example
• DSPy (支持ToT风格的推理搜索)
• Guidance (支持树形生成约束)
• Graph of Thoughts (GoT实现)''',
    papers: '''
• Tree of Thoughts: Deliberate Problem Solving with Large Language Models (Yao et al., NeurIPS 2023)
  论文链接: https://arxiv.org/abs/2305.10601
• Graph of Thoughts: Solving Elaborate Problems with LLMs (Besta et al., 2024)
• Reasoning via Planning (RAP): MCTS + LLM (Hao et al., 2024)
• Large Language Models as Commonsense Knowledge for Large-Scale Task Planning (2024)''',
    evolutionPath: 'CoT单链 → CoT-SC多链投票 → ToT树搜索 → GoT图搜索 → MCTS+LLM融合',
    tags: ['搜索推理', '树搜索', '前瞻规划', '高质量输出'],
  ),

  // ──────────────────────────────────────────────────────────
  // 10. Self-Consistency
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'self_consistency',
    name: '自一致性',
    englishName: 'Self-Consistency (CoT-SC)',
    subtitle: '采样多条推理链，多数投票选出最一致的答案，提升可靠性',
    icon: Icons.how_to_vote,
    color: Color(0xFF3F51B5),
    overview: '''
Self-Consistency（自一致性，Wang et al., 2022）是一种通过"采样+投票"来提升LLM推理可靠性的架构模式。它的核心思想简单而有效：让LLM以较高温度（temperature=0.7）生成多条独立的推理链，然后对最终答案进行多数投票。

与Tree of Thoughts不同，Self-Consistency不做中间评估和剪枝，每条路径都从头到尾完整生成。这种方法特别适合那些"殊途同归"的任务——多条不同的推理路径往往能收敛到同一个正确答案。

在MMLU和GSM8K等基准上，Self-Consistency能以适度的额外计算成本（通常5次采样）显著提升准确率。它的魅力在于简单：不需要修改模型，不需要复杂的搜索策略，只需要多采样几次然后投票。''',
    corePrinciple: '''
流程：

  [用户问题]
       ↓
  ┌─────────────────────────────────────┐
  │  以 temperature=0.7 采样k条推理链   │
  │                                     │
  │  Chain 1: 推理过程A → 答案: 42     │
  │  Chain 2: 推理过程B → 答案: 42     │
  │  Chain 3: 推理过程C → 答案: 36     │
  │  Chain 4: 推理过程D → 答案: 42     │
  │  Chain 5: 推理过程E → 答案: 42     │
  └─────────────────────────────────────┘
       ↓
  ┌──────────┐
  │ 多数投票  │
  │ 42: 4票  │ → 最终答案: 42
  │ 36: 1票  │
  └──────────┘

关键参数：
- k：采样数量，通常3-10条，5条最常见
- temperature：0.5-0.8，推荐0.7
- 投票策略：多数投票（分类）/ 加权平均（数值）''',
    workflow: '''
详细流程：

Step 1 — 构建CoT提示
  包含问题+引导推理的提示词
  """
  Q: 如果一列火车以60km/h的速度行驶3小时，它能走多远？
  A: 让我们一步步思考。
  速度=60km/h，时间=3小时
  距离=速度×时间=60×3=180km
  答案是180km。

  Q: [用户的实际问题]
  A: 让我们一步步思考。
  """

Step 2 — 多次采样
  for i in 1..k:
    以 temperature=0.7 调用LLM
    记录完整的推理链和最终答案
  → 得到k条可能不同的推理路径

Step 3 — 答案提取
  从每条推理链中提取最终答案
  归一化：统一格式（如"42"和"forty-two"视为相同）

Step 4 — 投票
  多数投票（离散答案）：
    统计每个答案出现的次数
    选择出现最多的答案
  加权投票（可选）：
    如果某些推理链更长/更详细，可赋予更高权重

Step 5 — 返回结果
  返回得票最多的答案
  可选：附带得票数和置信度''',
    detailedContent: '''
【为什么Self-Consistency有效？】

1. 多样性带来鲁棒性
   单一的贪婪解码（temperature=0）可能被"固定"在某个错误的
   推理路径上。提高temperature让模型探索不同的推理方向，
   增加了找到正确路径的概率。

2. 正确推理趋向一致
   对于有确定答案的问题，正确的推理路径虽然表述不同，
   但最终答案应该一致。错误的推理路径往往给出分散的答案。

3. 数学直觉：大数定律
   如果每条推理链的正确概率为p>0.5，那么k次采样后
   多数投票正确的概率会趋近于1（随k增加）。

【Self-Consistency vs ToT vs 直接采样】

| 维度 | 直接采样(t=0) | Self-Consistency | ToT |
|------|-------------|-----------------|-----|
| LLM调用 | 1次 | k次 | b^d级 |
| 中间评估 | 无 | 无 | 有（每步评估） |
| 路径关系 | 独立 | 独立 | 树形依赖 |
| 适合任务 | 简单 | 有确定答案的推理 | 需要前瞻规划 |
| 成本 | 基准 | k×基准 | 5-8×基准 |
| 实现难度 | 最简单 | 简单 | 复杂 |

【投票策略进阶】

1. 多数投票（Majority Voting）
   每个答案一票，选票最多的
   适合：分类问题、离散答案

2. 加权投票（Weighted Voting）
   根据推理链的质量指标（长度、置信度、一致性）加权
   适合：有质量差异的推理链

3. 归一化加权平均
   对数值型答案进行加权平均
   适合：回归问题、数值预测

4. 选择-拒绝采样（Accept-Reject）
   先让LLM评估每条链的合理性，只保留高质量链再投票

【Self-Consistency的局限】

1. 如果大多数推理路径都错了 → 投票得出错误答案
2. 如果正确答案占少数 → 少数服从多数的谬误
3. 计算成本随k线性增长
4. 对开放式任务（无唯一正确答案）不适用''',
    pros: '''
• 实现极其简单（只需循环调用+投票）
• 不需要修改模型或训练
• 显著提升推理可靠性
• 适合大多数有确定答案的任务
• 可并行执行（k次采样互不依赖）
• 与CoT/ReAct等基础模式兼容''',
    cons: '''
• 计算成本线性增长（k倍）
• 如果多数推理路径都错就无效
• 不适合开放式/创造性任务
• 需要有效的答案提取机制
• 对temperature参数敏感
• 可能放大系统性偏见''',
    useCases: '''
• 数学应用题：多样推理路径→投票选出正确答案
• 多选题/判断题：多角度分析→投票→最一致的选项
• 事实问答：多来源推理→交叉验证→最一致的答案
• 代码生成（输出确定）：多版本实现→测试→最通过的版本
• 分类任务：多角度分析→投票→最一致的分类
• 数值预测：多方估算→平均→更准确的预测''',
    implementations: '''
• 直接实现：for循环 + majority_vote（不到50行代码）
• LangChain Self-Consistency Chain
• DSPy (内置Self-Consistency模块)
• HuggingFace Transformers (多数投票工具)
• promptfoo (测试框架中的自一致性评估)''',
    papers: '''
• Self-Consistency Improves Chain of Thought Reasoning in Language Models (Wang et al., ICLR 2023)
  论文链接: https://arxiv.org/abs/2203.11171
• Complementary Explanations for Effective In-Context Learning (Ye et al., 2023)
• Complexity-Based Prompting for Multi-step Reasoning (Fu et al., 2023)
• Universal Self-Consistency for LLM Generation (Chen et al., 2023)''',
    evolutionPath: '贪心解码(t=0) → CoT → CoT-SC(Self-Consistency) → USC(通用SC) → 自适应采样数',
    tags: ['可靠性', '投票机制', '采样', '简单高效'],
  ),

  // ──────────────────────────────────────────────────────────
  // 11. Multi-Agent Collaboration
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'multi_agent_collaboration',
    name: '多智能体协作',
    englishName: 'Multi-Agent Collaboration',
    subtitle: '多个Agent分工协作、辩论、或组成团队，通过交互产生更优结果',
    icon: Icons.groups,
    color: Color(0xFFFF5722),
    overview: '''
Multi-Agent Collaboration（多智能体协作）代表了Agent架构从"单个超级Agent"到"Agent团队"的范式转变。核心思想是：让多个不同角色、不同能力的Agent互相协作、辩论、审查，集体产生比任何单个Agent都更好的结果。

2024-2025年，多Agent系统经历了从实验到生产落地的关键转变。微软AutoGen、CrewAI、MetaGPT等框架让开发者可以像组建团队一样组合Agent。Google的ANP（Agent Network Protocol）甚至为Agent之间的通信制定了标准化协议。

但研究也发出了重要警告："简单堆砌Agent不会自动提升效果"——不加设计的Agent群体会遭遇"思想退化"（集体陷入错误共识）、"多数羊群效应"（压制正确的少数观点）等问题。架构设计至关重要。''',
    corePrinciple: '''
三种核心协作形态：

1. 协作（Collaboration）— "一起做"
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ Agent A │  │ Agent B │  │ Agent C │
   │ 研究员   │  │ 写作者   │  │ 审查者   │
   └────┬────┘  └────┬────┘  └────┬────┘
        │─────────────│─────────────│
        │      共享工作区/消息总线     │
        └──────────────────────────┘
   角色分工，各司其职，产出拼接

2. 辩论（Debate）— "辩出真理"
   ┌──────────┐     ┌──────────┐
   │ 正方Agent │ ←→ │ 反方Agent │
   └─────┬─────┘     └─────┬────┘
         │                 │
         └────────┬────────┘
                  ↓
          ┌──────────────┐
          │ Arbiter 仲裁 │ → 最终决策
          └──────────────┘
   对立观点碰撞，暴露假设，仲裁择优

3. 竞争（Competition）— "优胜劣汰"
   ┌──────┐ ┌──────┐ ┌──────┐
   │Agent1│ │Agent2│ │Agent3│
   └──┬───┘ └──┬───┘ └──┬───┘
      │ 方案A  │ 方案B  │ 方案C
      └───────│────────│──────┘
              ↓
        ┌─────────┐
        │ 评分/选择 │ → 最优方案
        └─────────┘
   多方案生成，按标准评选，择优采纳''',
    workflow: '''
【案例】用多Agent协作写一篇技术文章

1. Researcher Agent（研究员）
   → 搜索"2025年AI Agent架构趋势"相关资料
   → 收集5篇核心论文、3篇行业报告
   → 输出：结构化的研究摘要

2. Outliner Agent（大纲设计者）
   → 基于研究摘要设计文章大纲
   → 输出：4段式文章结构 + 每段要点

3. Writer Agent（写作者）
   → 根据大纲逐段撰写
   → 每段引用研究摘要中的数据和论文
   → 输出：完整初稿

4. Code Reviewer Agent（代码审查者）
   → 检查文章中的代码示例
   → 验证代码可运行性和正确性
   → 输出：需要修改的代码问题列表

5. Critic Agent（批评者）
   → 审查全文的逻辑、准确性、可读性
   → 输出：包含具体修改建议的审查报告

6. Editor Agent（编辑者）
   → 综合Writer初稿 + CodeReview意见 + Critic意见
   → 逐条处理反馈，生成修改版
   → 输出：最终版本

7. Supervisor Agent（监督者）
   → 全程监控进度和质量
   → 决定何时需要重新执行某步骤
   → 最终确认输出质量''',
    detailedContent: '''
【主流多Agent协作模式详解】

1. Captain Agent / Orchestrator（船长模式/编排模式）
   - 中央协调者分解目标、委派子任务、监控进度
   - Worker Agent是无状态的，按需创建
   - 优势：结构清晰、可控性强
   - 代表：AutoGen GroupChat Manager、CrewAI Hierarchical

2. Peer-to-Peer / Distributed（点对点/分布式）
   - Agent之间直接通信，没有中心协调者
   - 图结构组织，邻居间通信
   - 优势：灵活、可扩展、无单点故障
   - 代表：多Agent辩论系统、MACI框架

3. Debate + Arbiter（辩论+仲裁）
   - 多个Agent从不同角度论证
   - Arbiter评估各方论点，选出最优方案
   - 优势：充分暴露假设、减少偏见
   - 代表：ChatEval、DeepMind辩论框架

4. Swarm（群体智能）
   - 大量简单Agent通过简单规则交互，涌现智能行为
   - 优势：可扩展性极强
   - 风险：缺乏控制的设计会导致"思想退化"
   - 代表：OpenAI Swarm（实验性）

5. Critic Voting Ensemble（批评投票集成）
   - 多个异构Agent生成各自的方案
   - Critic模型独立评估所有方案
   - 后验投票选择最优
   - 代表：JoyAgent-JDGenie（3-5个模型投票）

【关键警告：多Agent的陷阱】

1. 思想退化（Degeneration of Thought）
   在辩论中，Agent群体可能集体收敛到一个看似合理但错误的答案。
   早期的错误观点一旦被多数接受，少数正确的观点反而被压制。

2. 多数羊群效应（Majority Herding）
   多个Agent观察其他Agent的输出后，倾向于跟随"多数意见"，
   即使多数意见是错误的。

3. 上下文膨胀（Context Bloat）
   多Agent对话产生大量中间消息，极易超过上下文窗口限制。

4. 协调失败（Coordination Failure）
   Agent之间的通信协议不清晰导致重复工作或遗漏任务。

【多Agent框架对比】

| 框架 | 模式 | 通信方式 | 特点 |
|------|------|---------|------|
| AutoGen | 编排式 | 消息传递 | 微软出品，生态丰富 |
| CrewAI | 角色协作 | 顺序/层级 | 直观的角色定义 |
| MetaGPT | 角色分工 | SOP驱动 | 软件工程专精 |
| LangGraph | 图编排 | 状态图 | 灵活的自定义拓扑 |
| OpenAI Swarm | 轻量路由 | 切换交接 | 实验性，轻量级 |
| ANP (Google) | 去中心化 | 协议通信 | Agent间标准化协议 |''',
    pros: '''
• 专业化分工，单个Agent更简单高效
• 多角度审查，减少偏见和错误
• 复杂的整体行为从简单个体涌现
• 可扩展：新增Agent不影响现有系统
• 容错：单个Agent失败不影响整体
• 适合大型复杂任务''',
    cons: '''
• 协调开销大（通信+规划+仲裁）
• 可能出现协调失败（遗漏/重复）
• 上下文容易超限
• "思想退化"和"羊群效应"风险
• 调试极其困难（多Agent交互复杂）
• 计算成本是单Agent的数倍''',
    useCases: '''
• 软件工程：架构师→开发者→测试员→代码审查→文档
• 科学研究：假设生成→实验设计→数据分析→结论验证→论文
• 内容创作：研究→大纲→撰写→审查→编辑→发布
• 商业分析：数据收集→多角度分析→风险评估→决策建议
• 游戏AI：策略制定→资源管理→战术执行→实时调整
• 医疗诊断：影像分析→病史分析→化验解读→综合诊断''',
    implementations: '''
• Microsoft AutoGen (多Agent对话+编排)
• CrewAI (基于角色的多Agent协作)
• MetaGPT (软件工程多Agent流水线)
• LangGraph (图结构多Agent编排)
• CAMEL (探索性多Agent角色扮演)
• MACI (对抗性协作辩论框架)
• ANP (Google Agent Network Protocol)''',
    papers: '''
• AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation (Wu et al., 2024)
• MetaGPT: Meta Programming for Multi-Agent Collaborative Framework (Hong et al., 2024)
• Multi-Agent Collaboration Mechanisms: A Survey (2025)
  Survey: https://arxiv.org/abs/2501.06322
• Agent Network Protocol (ANP): Decentralized Agent Communication (Google, 2025)
• MACI: Multi-LLM Agent Collaborative Intelligence (ACM, 2025)''',
    evolutionPath: '单Agent → 简单多Agent → 角色分工 → 编排式 → 辩论式 → 去中心化协议 → 涌现智能',
    tags: ['多Agent', '协作', '团队', '辩论', '涌现'],
  ),

  // ──────────────────────────────────────────────────────────
  // 12. Critic-Editor
  // ──────────────────────────────────────────────────────────
  AgentArchitecture(
    id: 'critic_editor',
    name: '批评-编辑配对模式',
    englishName: 'Critic-Editor Pattern',
    subtitle: 'Editor生成内容，Critic严格审查，循环修正直到满足所有约束',
    icon: Icons.rate_review,
    color: Color(0xFF009688),
    overview: '''
Critic-Editor（批评-编辑）是一种双Agent配对架构。Editor负责生成内容，Critic负责严格审查——强制执行约束（测试用例、代码风格、安全检查、事实准确等）。如果审查不通过，Editor会收到Critic提供的结构化反馈，然后修正后重新提交。

这像是"作者+编辑"的工作模式：作者创作内容，编辑指出问题，作者修改，编辑再审，直到满意为止。

与Reflection（自我反思）的关键区别：Critic-Editor使用两个独立的Agent（可以使用不同的模型配置），而Reflection通常是一个Agent反思自己的输出。这种分离让Critic可以更客观、更专业地进行审查。''',
    corePrinciple: '''
双Agent协作循环：

  ┌──────────┐    生成（Generate）    ┌──────────┐
  │  Editor  │ ─────────────────────→ │  Critic  │
  │  编辑者   │ ←───────────────────── │  批评者   │
  │ (创造性)  │   反馈（Feedback）      │ (严格性)  │
  └──────────┘                        └────┬─────┘
       ↑                                   │
       │         修正（Revise）             │ 通过（Approve）
       └───────────────────────────────────┘ ↓
                                           [最终输出]

配置差异：
  Editor: temperature=0.7, model=强推理模型
  Critic: temperature=0.1, model=精确严谨模型
  两者使用不同的系统提示词

核心约束类型：
1. 功能约束：代码必须通过所有测试用例
2. 风格约束：代码必须符合PEP8/ESLint标准
3. 安全约束：无SQL注入/XSS/敏感信息泄露
4. 事实约束：引用的数据必须来源可查
5. 格式约束：输出必须符合指定JSON/Markdown格式''',
    workflow: '''
以代码生成为例：

Round 1: Editor生成
  Editor生成一个Python函数
  """
  def get_user(user_id):
      query = "SELECT * FROM users WHERE id=" + user_id
      return db.execute(query)
  """

Round 1: Critic审查
  检查结果：
  ✗ 安全检查：SQL注入风险！user_id未参数化
  ✗ 风格检查：缺少类型注解
  ✗ 功能检查：未处理用户不存在的边界情况

  反馈：
  """
  ISSUES:
  1. [CRITICAL-SECURITY] SQL注入：使用参数化查询
  2. [STYLE] 添加类型注解
  3. [EDGE-CASE] 用户不存在时返回None并记录日志
  """

Round 2: Editor修正
  """
  from typing import Optional
  import logging

  def get_user(user_id: int) -> Optional[dict]:
      query = "SELECT * FROM users WHERE id = ?"
      result = db.execute(query, (user_id,))
      if not result:
          logging.warning(f"User {user_id} not found")
          return None
      return result
  """

Round 2: Critic审查
  ✓ 安全检查：参数化查询，通过
  ✓ 风格检查：类型注解正确
  ✓ 功能检查：边界处理合理
  → 审核通过！''',
    detailedContent: '''
【Critic-Editor vs 其他模式】

| 维度 | Reflection | Critic-Editor | Supervisor |
|------|-----------|---------------|------------|
| 审查者 | 同一Agent | 独立Agent | 监督Agent |
| 反馈类型 | 自我反思 | 结构化审查 | 任务调整 |
| 客观性 | 中（自我偏差） | 高（独立审查） | 中-高 |
| 专业度 | 依赖于Agent能力 | 可专门优化Critic | 侧重于协调 |
| 适用场景 | 通用质量提升 | 有明确约束的任务 | 复杂多步任务 |

【Critic的约束执行机制】

Critic不仅仅是"指出问题"，更是"强制执行约束"：

1. 硬约束（Hard Constraints）
   必须满足，不满足则必须修改：
   - 安全规则（无注入、无泄露）
   - 法律合规要求
   - 格式规范（输出必须可解析）

2. 软约束（Soft Constraints）
   最好满足，但可根据情况灵活处理：
   - 代码风格（可自动格式化）
   - 注释完整度
   - 性能优化建议

3. 条件约束（Conditional Constraints）
   在特定条件下激活：
   - 包含用户数据时 → 激活隐私审查
   - 涉及金融操作时 → 激活审计审查

【结构化反馈格式】

Critic的反馈应该结构化，便于Editor精确理解和处理：

```
{
  "verdict": "REVISE",  // APPROVE | REVISE | REJECT
  "issues": [
    {
      "severity": "CRITICAL",
      "category": "SECURITY",
      "location": "line 3",
      "description": "Direct string concatenation in SQL query",
      "suggestion": "Use parameterized query: db.execute(query, (user_id,))"
    },
    {
      "severity": "WARNING",
      "category": "STYLE",
      "location": "function signature",
      "description": "Missing type annotations",
      "suggestion": "Add input/output type hints"
    }
  ],
  "summary": "1 critical security issue and 1 style warning found. Security issue must be fixed."
}
```

【关键设计决策】

1. 同一模型还是不同模型？
   - 同一模型：成本低，但可能有相同盲点
   - 不同模型：客观性更高，如用Claude做Critic审查GPT-4生成的代码

2. Critic的严格程度？
   - 太松：漏掉关键问题
   - 太严：无限修改循环
   - 建议：分级别（错误必须修，警告可忽略）

3. 最大修改轮次？
   - 通常2-4轮（与Reflection类似，超过3轮收益递减）
   - 达到上限后降级处理：接受当前版本或转人工''',
    pros: '''
• 审查客观性高（独立Critic）
• 约束强制执行，质量有保证
• 可针对不同约束优化不同Critic
• 结构化反馈，Editor易于处理
• 安全性高（独立安全审查）
• 适合需要合规审查的场景''',
    cons: '''
• 双Agent意味着双倍的LLM成本
• 延迟增加（每轮修改=Editor+Critic两次调用）
• Critic过于严格可能导致无限修改循环
• Critic的判断也可能出错
• 两个Agent的提示词都需要精心设计
• 对于纯创意任务可能过度限制''',
    useCases: '''
• 安全代码审查：生成→安全扫描→修复→再审查
• 合规内容审核：草稿→合规检查→修改→确认→发布
• 学术论文润色：初稿→同行评审式审查→修改→再审
• 法律文档：起草→法规审查→修改→律师确认
• 翻译质量保证：翻译→对照检查→修正→母语审查
• 政策文件：撰写→政策专家审查→修改→合规确认''',
    implementations: '''
• LangGraph (Editor + Critic双节点循环)
• AutoGen (两个Agent的循环对话)
• LlamaIndex (IntrospectiveAgent的Critic模式)
• Custom implementation (两个Agent+结构化反馈协议)
• Code review bots (GitHub Copilot code review模式)''',
    papers: '''
• CRITIC: Large Language Models Can Self-Correct with Tool-Interactive Critiquing (Gou et al., 2024)
• Self-Refine: Iterative Refinement with Self-Feedback (Madaan et al., 2023)
• Constitutional AI: Harmlessness from AI Feedback (Bai et al., 2022) — 先驱性工作
• Peer Review in LLM-based Systems (多篇相关研究, 2024)''',
    evolutionPath: '自我反思 → 独立Critic → 多维度Critic → 工具辅助Critic → 自适应约束强度',
    tags: ['质量保证', '双Agent', '约束执行', '代码审查'],
  ),
];
