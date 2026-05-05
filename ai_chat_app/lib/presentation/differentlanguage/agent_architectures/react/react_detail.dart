/// ReAct 推理-行动循环 — 完整详解
const String reactFullDetail = '''

# ReAct (Reasoning + Acting) - 完整详解

## 第一章：论文深度解读

### 1.1 论文信息
- **标题:** ReAct: Synergizing Reasoning and Acting in Language Models
- **作者:** Shunyu Yao, Jeffrey Zhao, Dian Yu, Nan Du, Izhak Shafran, Karthik Narasimhan, Yuan Cao
- **发表:** ICLR 2023
- **arXiv:** 2210.03629
- **引用量:** 3000+

### 1.2 时代背景与核心贡献

2022年之前，LLM的应用分为两个独立方向：
1. **推理增强**（Chain-of-Thought, Wei et al., 2022）：让LLM"多想几步"
2. **工具增强**（Toolformer, Schick et al., 2023）：让LLM使用外部工具

但两个方向是**割裂的**。CoT擅长推理但容易产生幻觉（看不到外部世界）；
工具使用能获取事实但缺乏推理能力（拿到数据不知如何处理）。

ReAct的历史性贡献：**首次将推理（Reasoning）和行动（Acting）统一到一个
交替循环中**，让推理指导行动，行动结果修正推理方向。

### 1.3 方法论详解

**行动空间形式化定义：**
Agent的行动空间被扩充为 Â = A ∪ L
- A：任务特定的行动空间（搜索、计算、查询等工具调用）
- L：语言空间（Thought，自然语言推理文本）

思考是内部的——不改变外部环境，只改变模型对未来步骤的内部上下文。

**两种提示模式：**
- **Dense Thought模式**（HotpotQA, FEVER）：每个Action前都有密集的Thought
- **Sparse Thought模式**（ALFWorld, WebShop）：Thought只出现在关键决策节点

**工具定义（Wikipedia API用于知识任务）：**
```
search[entity]: 返回实体Wikipedia页面的前5句话
lookup[string]: 在当前页面中查找包含该字符串的下一个句子（模拟Ctrl+F）
finish[answer]: 用最终答案终止任务
```

### 1.4 详细实验结果

**HotpotQA（500随机样本，EM%）：**

| 方法 | EM |
|------|-----|
| Standard Prompting | 25.5 |
| Chain-of-Thought (CoT) | 29.4 |
| Acting Only (Act) | 24.8 |
| ReAct | 27.4 |
| CoT-SC (21样本) | 33.4 |
| **ReAct → CoT-SC** | **35.1** |
| CoT-SC → ReAct | 32.0 |

**FEVER（500随机样本，EM%）：**

| 方法 | EM |
|------|-----|
| Standard | 51.2 |
| CoT | 56.3 |
| Act | 58.7 |
| ReAct | 60.9 |
| CoT-SC (21样本) | 60.5 |
| ReAct → CoT-SC | 62.0 |
| **CoT-SC → ReAct** | **64.6** |

**关键失败分析（200个HotpotQA样本）：**
- ReAct完全消除了幻觉导致的失败（0% vs. CoT的56%）
- 但交替格式的结构约束降低了推理灵活性，导致更多推理错误（47% vs. 16%）
- 这就是为什么与CoT-SC结合产生最佳总体结果

**ALFWorld（PaLM-540B，6-shot）：**

| 方法 | 成功率 |
|------|--------|
| BUTLER (IL, ~100K专家示范) | 37% |
| Act (6次试验最佳) | 45% |
| ReAct-IM (6次最佳) | 53% |
| **ReAct (6次最佳)** | **71%** |
| ReAct (6次最差) | 48% |

即使最差的ReAct试验（48%）也击败了最好的Act试验（45%）。

**WebShop（在线购物，500条指令，任务得分）：**

| 方法 | 得分 |
|------|------|
| 模仿学习 (IL) | 62.8 |
| Act | 62.3 |
| ReAct (PALM-540B) | **66.6** |
| 人类专家 | 82.1 |

**微调结果（关键发现）：**
- PaLM-8B微调ReAct **超越所有PaLM-62B提示方法**
- PaLM-62B微调ReAct **超越所有PaLM-540B提示方法**
- 微调教授了访问Wikipedia的可泛化技能，而微调Standard/CoT只教授了记忆

## 第二章：TAO循环（Thought-Action-Observation）详解

### 2.1 执行循环

```
Step 0: [系统提示 + Few-Shot示例 + 用户问题]
Step 1: Thought_1 → Action_1 → Observation_1
Step 2: Thought_2 → Action_2 → Observation_2
...
Step N: Thought_N → "我现在知道了最终答案" → Final Answer
```

### 2.2 完整示例（带注释）

问题："除Apple Remote外，还有什么设备可以控制Apple TV的工作方式？"

```
Thought 1: 我需要搜索Apple Remote，找到什么其他设备可以控制Apple TV。
Action 1: search[Apple Remote]
Observation 1: Apple Remote是2005年Apple为Apple TV推出的遥控器。其功能可以
被Apple Watch复制...

Thought 2: 观察结果说Apple Watch可以复制遥控器功能。我应该查看Apple TV
文章来确认并看其他控制设备。
Action 2: lookup[control]
Observation 2: ...Apple TV可以由许多第三方红外遥控器控制，以及Apple Wireless
Keyboard...

Thought 3: Apple TV文章提到第三方红外遥控器和Apple Wireless Keyboard作为
替代控制方法。我现在知道了最终答案。
Action 3: finish[第三方红外遥控器和Apple Wireless Keyboard]
```

### 2.3 每个组件的分析

| 组件 | 生产者 | 内容类型 | 上下文影响 |
|------|--------|---------|-----------|
| Thought | LLM生成 | 自然语言推理 | 追加到上下文，指导下一步行动 |
| Action | LLM生成工具名+参数 | 结构化调用 | 由Agent运行时解析执行 |
| Observation | 外部工具/环境返回 | 工具输出原始文本 | 追加到上下文，为推理提供依据 |
| Final Answer | LLM生成 | 综合结论 | 返回用户，终止轨迹 |

### 2.4 算法伪代码

```
Algorithm: ReAct
Input: 用户问题 Q, 工具集 T = {t1, t2, ..., tn}, max_steps M
Output: 最终答案 A

1. 初始化上下文 C = [SystemPrompt, FewShotExamples, Q]
2. for step = 1 to M:
   a. response = LLM(C)
   b. 从response解析Thought和Action
   c. if Action是Finish(answer):
      - 返回answer, 终止循环
   d. 执行Action对应工具调用, 获取Observation
   e. 将(Thought, Action, Observation)追加到C
   f. if 检测到循环 (最近3个Action完全相同):
      - 向C追加警告提示: "请尝试不同的方法"
   g. if 检测到无效进展 (连续2步Observation无新信息):
      - 向C追加提示: "基于现有信息给出最佳答案"
3. if step == M and 未终止:
   - 强制LLM基于现有信息生成最佳答案
```

## 第三章：提示词工程

### 3.1 标准ReAct提示模板

```
你是一个能够使用工具的智能助手。你可以通过思考（Thought）
和行动（Action）来解决复杂问题。

可用工具：
- search(query: str): 搜索互联网信息。输入关键词，返回搜索结果摘要。
- lookup(index: int): 查看搜索结果的详细内容。
- finish(answer: str): 给出最终答案。当你确定答案时使用。

严格遵循以下格式（不得偏离）：
Question: 用户的问题
Thought: 你对当前情况的分析和下一步计划
Action: 工具名称[输入参数]
Observation: 工具返回的结果（由系统提供，不要自己编造）
...（重复Thought-Action-Observation直到知道答案）
Thought: 我现在知道了答案
Action: finish[最终答案]

重要规则：
- 每次只能执行一个Action
- 永远不要自己编造Observation，必须等待系统返回
- 如果搜索没有找到结果，调整搜索词重试
- 如果多次搜索仍无结果，诚实告知用户
```

### 3.2 Few-shot示例设计原则

**原则1：覆盖不同场景**
至少包含3个示例，展示：
- 需要多步搜索获取信息的任务
- 需要处理数据/计算的任务
- 找不到信息时的正确处理方法

**原则2：展示失败恢复**
示例中应包含"第一步没找到，换策略后成功"的案例。
这教会Agent：失败不是终点，调整策略可以解决问题。

**原则3：示范终止时机**
明确展示所有终止条件：
- 信息足够回答 → 立即终止
- 多次搜索无果 → 诚实告知
- 需要用户澄清 → 追问而非猜测

### 3.3 工具描述优化指南

工具描述的质量直接影响LLM的工具选择准确率：

```python
# ❌ 不好的工具描述
def search(q):
    """搜索"""
    pass

# ✅ 好的工具描述
def search(query: str) -> str:
    """
    搜索互联网获取最新信息。

    参数:
        query: 搜索查询字符串。使用关键词而非完整句子。
              例: "Apple 2024 revenue" 而非 "what is Apple's revenue for 2024"

    返回:
        前5条搜索结果的标题、URL和简短摘要。

    使用时机:
        - 事实性问题（日期、数据、人物信息）
        - 最新新闻和动态

    不使用时机:
        - 实时数据（股票、天气等有专门API的数据）
        - 内部数据库查询

    使用建议:
        - 如果首次搜索不满意，尝试不同的关键词组合
        - 使用lookup查看搜索结果详情
    """
    pass
```

## 第四章：上下文窗口管理

### 4.1 问题分析

ReAct最大的工程挑战是上下文窗口膨胀：

假设每步产生约500 tokens（Thought ~150, Action ~50, Observation ~300），
经过N步后总上下文约为：

| 步数 | 上下文大小（估算） | GPT-4o成本（估算） |
|------|-------------------|-------------------|
| 5步 | ~3,500 tokens | ~\$0.02 |
| 10步 | ~6,000 tokens | ~\$0.04 |
| 15步 | ~8,500 tokens | ~\$0.06 |
| 20步 | ~11,000 tokens | ~\$0.08 |
| 30步 | ~16,000 tokens | ~\$0.12 |

看似不多，但15步任务每次调用都要传输完整前缀，Token消耗呈二次增长：
Total tokens ≈ N × (system_prompt + avg_step × N/2)

实际生产数据（GPT-4o，22个工具，每个消息3轮）：

| 组件 | 每轮Token | ×3轮 | 占比 |
|------|----------|------|------|
| 工具模式（22个工具定义） | 11,100 | 33,300 | **69%** |
| 系统提示 | 2,870 | 8,610 | 18% |
| 工具返回结果 | ~2,000×2 | 4,000 | 8% |
| 消息历史 | ~1,750 | 5,250 | 5% |

10条消息的成本约\$0.71。在规模下（10K DAU × 5条Agent消息/天），
月成本约\$106,500。

### 4.2 策略A：滑动窗口

只保留最近K步的完整历史，更早的步骤被丢弃或摘要化。

```
上下文 = 系统提示 + 原始问题 + 最近K步(Thought, Action, Observation)

优点: 上下文大小恒定，实现简单
缺点: 可能丢失关键早期信息
最佳K值: 5-8步
```

### 4.3 策略B：摘要压缩

每5步生成一个状态摘要，替代详细历史：

```
Summary_{1-5}: "已确认：Apple营收391B，Microsoft营收245B。
                尝试了搜索X和Y，X成功，Y失败。当前需要比较两者。"

上下文 = 系统提示 + 原始问题 + 摘要 + 最近步骤

优点: 比滑动窗口保留更多关键信息
缺点: 摘要本身可能遗漏重要细节
```

提示缓存（P0优先级）：
OpenAI的自动前缀缓存对缓存的输入Token给予**90%折扣**。
由于系统提示+工具模式（~14K Token）跨请求相同，确保它们在
每个请求中占据第一个位置，可实现**约52%成本降低**。

### 4.4 策略C：外部记忆

工具调用结果存入向量数据库，按需检索而非全量加载。

```
每次新的Thought → 检索相关历史结果:
relevant = vector_db.search(current_thought, top_k=3)

上下文 = 系统提示 + 原始问题 + 检索到的相关历史 + 最近步骤

优点: 信息不丢失，按需检索，最灵活
缺点: 增加基础设施复杂度
```

## 第五章：8大失败模式与修复方案

### 5.1 工具名称幻觉

**问题：** LLM编造不存在的工具名称。200个任务基准显示**90.8%的重试**
浪费在永久不可能的操作上。

**修复——确定性工具路由：**
```python
STEP_TO_TOOL = {
    StepKind.SEARCH: "search",
    StepKind.CALCULATE: "calculate",
    StepKind.SUMMARISE: "summarise",
}
tool_name = STEP_TO_TOOL[step.kind]  # 从结构上防止幻觉
```

### 5.2 无限/重复循环

**四种循环类型：**
1. **重复行动循环**：同一工具+相同参数反复调用
2. **纯思考循环**：模型"决定再想一想"而不行动
3. **失控模拟循环**：模型在内部模拟完整的TAO周期
4. **上下文稀释**：原始意图在增长的历史中丢失

**修复：**
```python
def detect_loop(history: list) -> bool:
    recent_actions = [h.action for h in history[-5:]]
    if len(set(recent_actions)) <= 2:  # 5步内只有2种行动
        return True
    if any(history.count(a) >= 3 for a in recent_actions):  # 某行动重复3+
        return True
    return False

if detect_loop(history):
    prompt += "\n你似乎在重复相同的操作。请尝试完全不同的方法，或考虑用现有信息回答。"
```

### 5.3 沉默故障/仪表盘盲区

**问题：** 标准可观测性指标隐藏关键故障：
- 成功率可能显示100%，而54.7%的重试浪费在不可能的操作上
- 失败的ReAct运行提前退出，在平均值中显得"快"但不成功
- ReAct的步数标准差（σ=1.36）比受控工作流（σ=0.46）高3倍

### 5.4 每个工具的断路器

**问题：** 单个降级工具可能通过重复故障耗尽全局重试预算。

**修复——断路器状态机：**
```
CLOSED → (3次连续故障) → OPEN → (超时后) → HALF_OPEN → (2次成功) → CLOSED
```

### 5.5 工具输出模拟

**问题：** 模型生成了从未从任何真实工具收到的幻觉Observation。

**修复：**
```python
if "Observation:" in model_output and not actual_tool_executed:
    # 模型在工具实际执行之前编造了Observation
    response = "你必须等待实际的Observation。永远不要自己生成Observation。请重新开始。"
```

### 5.6 过早终止

**问题：** Agent在信息不足时就宣布找到了答案。

**修复：**
```python
required_info = extract_entities(question)  # ["A营收", "B营收"]
gathered_info = extract_facts_from_history(history)
missing = required_info - gathered_info.keys()
if missing and response_is_final:
    prompt += f"你还需要获取：{missing}。请不要提前终止。"
```

### 5.7 工具选择错误

**原因：** 工具描述不清晰、功能重叠、工具名称误导。

**修复：** 在工具描述中加入"使用时机"和"不使用时机"说明。

### 5.8 上下文污染

**问题：** 早期错误的Observation持续影响后续Thought。

**修复：** 关键步骤后加入"重新评估"提示：
```
Thought: 现在让我重新评估。早期关于X的假设可能不正确，
        因为后来的搜索显示Y。我需要重新考虑...
```

## 第六章：ReAct变体与演进

### 6.1 变体家族

```
Chain-of-Thought (CoT, Wei et al., 2022)
    |
    +-- ReAct (Yao et al., ICLR 2023)
    |    |
    |    +-- ReAct + CoT-SC (论文中的最佳组合)
    |    +-- ReAct-IM (Inner Monologue变体)
    |    |
    |    +-- Reflexion (Shinn et al., NeurIPS 2023) → 添加元认知+情景记忆
    |    +-- ReWOO (Xu et al., 2023) → 推理与观察解耦，2次LLM调用
    |    +-- Self-Refine (Madaan et al., 2023) → 同一模型充当作者+编辑
    |    +-- Chain-of-Hindsight (2024) → 在训练阶段内化反思
    |    +-- Pre-Act (2025) → 先多步规划，再ReAct执行
    |    +-- F-ReAct (2025) → 细粒度逐步评估
    |    +-- RP-ReAct (2025) → Reasoner-Planner + Proxy-Execution Agent
    |
    +-- Tree-of-Thoughts (Yao et al., 2023) → 分支探索
    +-- Graph-of-Thoughts (Besta et al., 2024) → 图结构聚合
```

### 6.2 ReAct + CoT-SC（最佳组合）

论文发现的最优配置：
- 先用ReAct生成多条带外部知识的推理轨迹
- 再用CoT-SC（Self-Consistency）对最终答案进行多数投票
- HotpotQA: 35.1 EM（vs 33.4 CoT-SC alone）
- FEVER: 64.6 EM（vs 60.5 CoT-SC alone）

### 6.3 Self-Ask (Press et al., 2023)

简化版ReAct——不使用外部工具，通过"自我提问-自我回答"进行推理：

```
Question: 亨利八世的第二任妻子的父亲是谁？
Are follow up questions needed here: Yes.
Follow up: 亨利八世的第二任妻子是谁？
Intermediate answer: 安妮·博林
Follow up: 安妮·博林的父亲是谁？
Intermediate answer: 托马斯·博林
So the final answer is: 托马斯·博林
```

### 6.4 IRCoT (Trivedi et al., 2023)

将信息检索与思维链交织：
```
问题 → CoT步骤1 → 检索相关文档 → CoT步骤2 → 检索相关文档 → ... → 答案
```

与ReAct的区别：IRCoT专门优化了检索步骤，在知识密集型任务上更高效。

## 第七章：框架实现

### 7.1 LangChain实现

```python
from langchain.agents import create_react_agent
from langchain.tools import Tool

search_tool = Tool(
    name="Search",
    func=lambda q: search_engine.query(q),
    description="搜索互联网获取信息。输入关键词，返回结果摘要。"
)

calculator_tool = Tool(
    name="Calculator",
    func=lambda expr: str(eval(expr)),
    description="计算数学表达式。输入如'2+2'，返回结果。"
)

agent = create_react_agent(
    llm=llm,
    tools=[search_tool, calculator_tool],
    prompt=react_prompt_template
)

result = agent.invoke({"input": "2025年AI Agent领域最大趋势是什么？"})
```

### 7.2 LangGraph实现（推荐）

```python
from langgraph.prebuilt import create_react_agent
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()

agent = create_react_agent(
    model="claude-sonnet-4-6",
    tools=[search_tool, calculator_tool, file_tool],
    checkpointer=memory,
    prompt=(
        "你是一个研究助手。每次行动前先思考需要什么信息。"
        "如果搜索没有返回想要的结果，请调整搜索词重试。"
        "当你确定答案时，使用finish工具给出最终答案。"
    )
)
```

### 7.3 LlamaIndex实现

```python
from llama_index.core.agent import ReActAgent
from llama_index.core.tools import FunctionTool

def search_wikipedia(query: str) -> str:
    """Search Wikipedia for information about the query."""
    return wikipedia.search(query)

wiki_tool = FunctionTool.from_defaults(fn=search_wikipedia)

agent = ReActAgent.from_tools(
    tools=[wiki_tool],
    llm=llm,
    verbose=True,  # 打印中间Thought-Action-Observation
    max_iterations=10  # 最大循环次数
)

response = agent.chat("What is the capital of France?")
```

## 第八章：生产部署经验

### 8.1 经验1：Vanilla ReAct是原型，不是最终方案

生产环境需要叠加以下层次：
- Token管理（滑动窗口/摘要压缩/提示缓存）
- 反思机制（Reflexion或Critic-Editor）
- 确定性工具路由（防止工具名称幻觉）
- 每工具断路器（防止级联故障）
- 完整可观测性（追踪、日志、指标）

### 8.2 经验2：监控必须超越平均值

关键监控指标：
- **步数标准差**：衡量执行一致性（ReAct: σ=1.36 vs 工作流: σ=0.46）
- **浪费重试率**：浪费在不可能操作上的重试百分比（基准：54.7%）
- **错误分类**：按类型（幻觉/循环/工具失败/上下文溢出）
- **P95延迟**：不只是平均延迟

### 8.3 经验3：MCP正在成为企业工具接口标准

MCP解决了ReAct长期面临的两个核心问题：
1. **工具碎片化**：每个LLM提供商有自己不同的函数调用API
2. **治理空白**：缺乏基于角色的工具访问控制标准

### 8.4 经验4：提示缓存是最大的成本杠杆

GPT-4o的自动前缀缓存为缓存的输入Token提供**90%折扣**。
系统提示+工具定义（通常14K+ Token）跨请求相同的场景下，
这是最大的即时成本优化。

### 8.5 经验5：从ReAct升级到Plan-Execute的时机

当以下条件满足时，应从纯ReAct升级：
- 任务步骤可以提前合理预测（>80%准确率）
- 存在大量无依赖的并行工具调用
- Token预算紧张（ReWOO可以节省5倍Token）
- 需要可审计的执行计划

## 第九章：ReAct vs 替代方案决策框架

### 9.1 全面对比

| 维度 | ReAct | Plan-Execute | ReWOO | LLMCompiler |
|------|-------|-------------|-------|-------------|
| **规划方式** | 逐步（每步一规划） | 先整体规划 | 一次性规划 | DAG并行规划 |
| **LLM调用次数** | N+1次 | 1-3次(+执行) | 2次 | 1-2次 |
| **Token效率** | 低（O(N²)） | 中 | 高（O(1)） | 高 |
| **灵活性** | 极高 | 高（支持重规划） | 低（静态计划） | 中 |
| **并行能力** | 低（默认串行） | 高 | 中 | 最高 |
| **错误恢复** | 最灵活（每步可调） | 支持重规划 | 规划时预测 | 依赖DAG结构 |
| **实现难度** | 最低 | 中 | 中 | 高 |
| **最佳场景** | 探索性、不确定性任务 | 结构化、多步任务 | 确定性、线性任务 | 工具密集、可并行任务 |

### 9.2 决策树

```
你的任务适合ReAct吗？

├── 任务路径不明确，需要探索？
│   └── ✓ ReAct最佳选择

├── 每步都依赖上一步的具体结果？
│   └── ✓ ReAct最灵活

├── 需要人机交互（中间步骤确认）？
│   └── ✓ ReAct天然支持

├── 任务步骤可以提前预测？
│   └── ✗ 考虑Plan-Execute或ReWOO

├── 有大量无依赖的工具调用？
│   └── ✗ 考虑LLMCompiler

├── Token预算紧张？
│   └── ✗ 考虑ReWOO

└── 需要完整审计追踪？
    └── ✓ ReAct每步可见，是最佳选择
```

## 第十章：2025-2026最新发展

### 10.1 多模态ReAct

ReAct正在扩展到视觉和音频领域：

```
Vision-ReAct:
  Thought: 图片中显示了一个错误对话框
  Action: screenshot_analyze[error_region]
  Observation: 错误代码0x80070002表示文件未找到
  Thought: 需要检查文件路径是否正确
  Action: check_file_config[config.xml]
  ...
```

### 10.2 结构化输出约束

2025年，结构化输出从"建议"变为"强制"：

```python
from pydantic import BaseModel

class ReActAction(BaseModel):
    thought: str
    action_type: str  # "tool_call" | "final_answer"
    tool_name: str | None = None
    tool_args: dict | None = None
    final_answer: str | None = None

# LLM被约束只能输出符合此Schema的JSON
response = llm.generate(prompt, response_format=ReActAction)
```

### 10.3 MCP原生ReAct

```
[ReAct Agent]
    ↓ MCP Client协议
[MCP Server: FileSystem] → 读写文件
[MCP Server: Database] → 查询数据库
[MCP Server: WebSearch] → 搜索互联网
```

MCP消除了工具集成碎片化，Agent可以自动发现和使用任何MCP兼容工具。

### 10.4 Agent-to-Agent (A2A) ReAct

Google的A2A协议让ReAct Agent能够将子任务委派给其他Agent：

```
ReAct Agent A:
  Thought: 这个问题需要数据库查询和网页搜索
  Action: delegate_search[query] → Agent B (搜索专家)
  Action: delegate_sql[query] → Agent C (SQL专家)
  Thought: 综合B和C的结果
  Action: finish[综合答案]
```

> ReAct是AI Agent的"原子架构"——几乎所有更复杂的架构
> 都以某种形式的ReAct作为底层执行循环。从学术提示技术
> （ICLR 2023）到驱动大多数生产LLM应用的基础架构，
> ReAct的核心洞察——将推理与工具使用交织在结构化反馈循环中——
> 已被证明是稳健且持久的。但生产就绪的ReAct需要叠加
> Token管理、反思、确定性路由、断路器、MCP标准化和
> 完整可观测性。Vanilla ReAct只是起点，不是终点。
''';
