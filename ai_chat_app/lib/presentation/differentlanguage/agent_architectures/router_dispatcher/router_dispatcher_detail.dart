/// Router + Dispatcher — 完整详解
const String routerDispatcherFullDetail = '''

# 路由 + 分发模式 (Router + Dispatcher) - 完整详解

## 第一章：架构核心概念

### 1.1 核心思想

Router + Dispatcher是生产环境中最实用、最广泛采用的架构模式之一。
核心洞察：不是所有任务都需要最强大的模型和最复杂的推理。通过"分类-分发"
的架构设计，可以用便宜的模型处理简单任务，只在必要时动用大模型和专业Agent。

**"快速失败，廉價成功"**是这种模式的设计哲学。大部分用户请求（80%+）
都是简单、可预测的，应该用最快的路径处理。只有少数复杂请求才需要
深度推理和多步协调。

### 1.2 与Supervisor的核心区别

| 维度 | Router | Supervisor |
|------|--------|------------|
| 决策次数 | 1次（入口分类） | N次（持续决策） |
| 任务粒度 | 整个请求 | 子任务级别 |
| 上下文 | 用户原始输入 | 完整执行历史 |
| 协调能力 | 无（一发了之） | 强（依赖管理、进度监控） |
| Agent关系 | 无交互 | 协调+仲裁 |
| 适用复杂度 | 简单-中等 | 中等-复杂 |
| 延迟 | 低（一次分类） | 中等（多次协调） |
| 实现成本 | 最低 | 中等 |

Router像一个接线员：分类→转接→结束。
Supervisor像一个项目经理：持续监控→动态委派→协调→调整→聚合。

### 1.3 架构组成

```
                      [用户输入]
                           ↓
                    ┌──────────────┐
                    │    Router    │ ← 轻量模型（如GPT-4o-mini）
                    │   路由器      │    意图分类+置信度评估
                    └──────┬───────┘
                           │ 分发（Dispatch）
            ┌──────────────┼──────────────┐
            ↓              ↓              ↓
      ┌──────────┐  ┌──────────┐  ┌──────────┐
      │  搜索    │  │   SQL    │  │  代码    │  ...
      │  Agent   │  │  Agent   │  │  Agent   │
      └──────────┘  └──────────┘  └──────────┘
            │              │              │
            └──────────────┼──────────────┘
                           ↓
                  ┌────────────────┐
                  │  结果聚合/返回   │
                  └────────────────┘
```

## 第二章：五种路由策略

### 2.1 基于意图的路由 (Intent-based Routing)

最常用的策略。使用预定义的NLU意图分类，将用户输入映射到特定Agent。

```python
# NLU意图分类
intents = {
    "order_status": OrderAgent(),
    "refund_request": RefundAgent(),
    "product_info": ProductAgent(),
    "technical_support": TechSupportAgent(),
    "general_chitchat": GeneralAgent(),
}

intent = nlu_classifier.classify(user_query)
agent = intents.get(intent.name, GeneralAgent())
result = agent.handle(user_query)
```

**优点：** 准确率高（针对已知意图）、易于理解和调试
**缺点：** 需要预定义所有意图、新增意图需要重新训练分类器

### 2.2 语义路由 (Semantic Routing)

基于语义相似度进行路由。使用embedding向量计算用户查询与候选Agent描述
之间的余弦相似度。更灵活但计算量更大。

```python
from semantic_router import SemanticRouter, Route

# 定义路由（用自然语言描述每个Agent的适用场景）
routes = [
    Route("search", "用于搜索信息、查询知识、查找资料"),
    Route("sql", "用于数据库查询、数据统计、报表生成"),
    Route("code", "用于编程帮助、代码生成、调试错误"),
    Route("general", "用于闲聊、简单问答、不确定意图"),
]

router = SemanticRouter(routes=routes, encoder=encoder)
result = router.route(user_query)
```

**开源实现：** Semantic Router（Aurelio AI, 2024）
**优点：** 零样本路由、自动适应新领域、规则维护成本低
**缺点：** 计算量较大、依赖embedding质量

### 2.3 关键词路由 (Keyword-based Routing)

最简单的策略。基于关键词匹配进行路由。

```python
ROUTE_RULES = {
    ("订单", "物流", "配送"): "order_agent",
    ("退款", "退货", "投诉"): "refund_agent",
    ("产品", "规格", "价格"): "product_agent",
    ("登录", "密码", "验证"): "account_agent",
}

def keyword_route(query: str) -> str:
    scores = {}
    for keywords, agent in ROUTE_RULES.items():
        scores[agent] = sum(1 for kw in keywords if kw in query)
    best = max(scores, key=scores.get)
    return best if scores[best] > 0 else "general_agent"
```

**优点：** 最快、零推理开销、可解释
**缺点：** 最粗糙、无法理解语义变体、维护成本高

### 2.4 混合路由 (Hybrid Routing)

组合以上策略。典型的混合方案：
- 第一层：关键词快速过滤（排除明显不相关的Agent）
- 第二层：语义路由精确匹配（在候选集中选择最佳）
- 第三层：LLM分类器最终确认（置信度低时）

### 2.5 置信度回退 (Confidence Fallback)

置信度低时不硬猜，而是走安全默认路径：

```python
def route_with_fallback(query: str, threshold=0.7):
    intent, confidence = router.classify(query)
    if confidence >= threshold:
        return specialized_agents[intent].handle(query)
    elif confidence >= 0.4:
        # 中等置信度：提供前3个可能的路由作为建议
        top3 = router.top_k(query, k=3)
        return clarification_agent.ask("您想使用以下哪个功能？", top3)
    else:
        # 低置信度：转通用Agent或人工
        return general_agent.handle(query)
```

## 第三章：2024-2025 双速架构（生产主流）

这是Router-Dispatcher模式最重要的生产实践。

### 第一层：Router（便宜模型，如GPT-4o-mini）

将请求分为三类：
- **single_tool：** 单步任务，直接调用工具返回（~70%的请求）
- **multi_step：** 多步任务，需要规划（~20%的请求）
- **clarify：** 意图不明确，需要追问澄清（~10%的请求）

```python
def dual_speed_router(query: str):
    # 第一层：轻量分类
    category = cheap_llm.classify(query, [
        "single_tool", "multi_step", "clarify"
    ])

    if category == "single_tool":
        # 快速路径：直接调用工具
        tool = tool_selector.select(query)
        return tool.execute(query)

    elif category == "multi_step":
        # 慢速路径：调用Micro-planner
        plan = micro_planner.plan(query, max_steps=4, max_depth=2)
        return graph_executor.execute(plan)

    else:  # clarify
        return clarify_agent.ask_followup(query)
```

### 第二层：Micro-planner（仅multi_step时调用）

- 生成≤4步、深度≤2的小型DAG
- 为每步指派对应的专业Agent
- 使用更强但更贵的模型（如GPT-4o）

### 第三层：Graph Executor

- 并行执行无依赖的步骤
- 支持中断（Human-in-the-Loop）
- 结果自动聚合
- MCP Edge：JSON Schema校验所有工具I/O

### 优势量化

| 指标 | 纯ReAct | 双速架构 |
|------|---------|---------|
| P50延迟 | ~15s | ~4s |
| P95延迟 | ~45s | ~12s |
| Token消耗/任务 | ~5000 | ~750（简单任务） |
| 月成本（10K DAU） | ~\$106,500 | ~\$28,000 |

比纯ReAct延迟更低、比纯Router更灵活、Token消耗大幅降低。

## 第四章：Router设计最佳实践

### 4.1 Router应该"快速失败"

```python
# 反模式：Router花10秒分析后才决定路由
# 最佳实践：Router < 500ms完成分类

# 超时保护
try:
    intent = asyncio.wait_for(
        router.classify(query),
        timeout=0.5  # 500ms超时
    )
except asyncio.TimeoutError:
    intent = "general"  # 超时走默认路径
```

### 4.2 路由粒度控制

- **太粗：** 3个路由处理所有请求 → 每个Agent需要过于通用化
- **太细：** 50个路由 → 维护困难，分类准确率下降
- **最佳范围：** 5-15个路由目标，每个有明确的能力边界

### 4.3 路由可观测性

必须监控的指标：
```json
{
  "router_metrics": {
    "total_requests": 10000,
    "classification_accuracy": 0.94,
    "avg_confidence": 0.87,
    "fallback_rate": 0.03,
    "avg_latency_ms": 120,
    "p95_latency_ms": 280,
    "error_rate": 0.005,
    "route_distribution": {
      "search": 0.30, "sql": 0.25, "code": 0.20,
      "general": 0.15, "clarify": 0.10
    }
  }
}
```

### 4.4 路由反馈闭环

```python
# 用户拒绝Agent的回答时触发
def on_user_rejection(route, user_feedback):
    # 1. 记录错误路由
    route_error_db.log(route, user_feedback)

    # 2. 如果某路由错误率超过阈值，自动降级
    if route_error_db.error_rate(route, window="1h") > 0.10:
        route_manager.downgrade(route, confidence_threshold=0.95)

    # 3. 将错误案例加入评估数据集
    eval_dataset.add(user_feedback)
```

## 第五章：Dispatcher设计

### 5.1 任务队列管理

```python
class Dispatcher:
    def __init__(self):
        self.queues = {
            Priority.HIGH: asyncio.PriorityQueue(),
            Priority.NORMAL: asyncio.Queue(),
            Priority.LOW: asyncio.Queue(),
        }
        self.agent_status = {}  # agent_id → {busy, last_heartbeat, ...}

    async def dispatch(self, task: Task, agents: List[Agent]):
        # 选择最合适的空闲Agent
        available = [a for a in agents if not self.agent_status[a.id]["busy"]]
        if not available:
            # 无空闲Agent，加入队列
            await self.queues[task.priority].put(task)
            return

        # 能力匹配最佳Agent
        best_agent = max(available, key=lambda a: a.capability_score(task))
        await best_agent.execute(task)
```

### 5.2 并行分发

```python
async def parallel_dispatch(query: str, agents: List[Agent]):
    """某些查询可能需要多个Agent协作"""
    results = await asyncio.gather(
        *[agent.process(query) for agent in agents],
        return_exceptions=True  # 部分失败不影响其他
    )

    successful = [r for r in results if not isinstance(r, Exception)]
    failed = [r for r in results if isinstance(r, Exception)]

    logger.info(f"并行分发：{len(successful)}成功, {len(failed)}失败")

    return aggregator.merge(successful)
```

### 5.3 负载均衡

- **轮询（Round-robin）：** 简单公平
- **最少连接优先：** 动态负载均衡
- **加权路由：** 根据Agent处理能力分配权重
- **健康检查：** 自动摘除和恢复故障Agent

### 5.4 结果聚合策略

| 策略 | 描述 | 适用场景 |
|------|------|---------|
| 简单拼接 | 多个结果直接拼接 | 独立信息的汇总 |
| LLM综合 | LLM分析并综合多个Agent输出 | 需要分析和整合 |
| 多数投票 | 多个Agent对同一问题给出答案后投票 | 需要高可靠性 |
| 置信度加权 | 高置信度Agent输出更高权重 | Agent能力不均衡 |

## 第六章：路由升级——Arbiter模式（AWS 2025）

AWS在2025年提出的下一代路由架构：

### 6.1 语义能力匹配
Arbiter不仅仅是路由到已知Agent，而是推理"什么样的Agent应该存在"
来处理这个任务。它理解任务的深层语义需求，而非表面分类。

### 6.2 Fabricator Agent（动态Agent生成）
如果没有合适的Agent存在，Fabricator动态生成新的Agent代码。
这实现了按需能力增长——系统不再受限于预定义的Agent集合。

### 6.3 Blackboard模型
共享的语义事件空间，Agent可以在其中发布/消费任务状态，
实现机会主义的问题解决——Agent看到自己能处理的任务就主动认领。

### 6.4 热加载包装器
将能力增长与基础设施扩展解耦。单个Lambda/容器可以动态加载和
执行任何Fabricator生成的Agent代码，无需部署新服务。

## 第七章：实际部署案例

### 7.1 企业智能助手
Router将用户问题分类到HR Agent（休假、薪资）、IT Agent（密码、VPN）、
财务Agent（报销、预算）、通用Agent（未分类请求）。

### 7.2 电商客服
订单Agent（状态、修改）、退款Agent（申请、进度）、产品Agent（规格、库存）、
投诉升级Agent（复杂投诉→人工）。

### 7.3 代码平台（双速架构实践）
```
用户输入 → Router
  ├─ "如何写for循环" → 简单回答（0.3s, \$0.001）
  ├─ "帮我写一个登录接口" → 代码生成Agent（3s, \$0.02）
  └─ "重构整个用户系统" → Micro-planner → 多Agent协作（15s, \$0.15）
```

### 7.4 搜索系统
- 网页搜索Agent → 通用搜索
- 数据库Agent → 结构化SQL查询
- 文档Agent → 内部知识库
- 图片/视频Agent → 多媒体搜索

## 第八章：常见陷阱与缓解

### 8.1 路由错误级联放大
分错Agent意味着任务完全无法处理——这是Router模式最严重的风险。

**缓解：**
- 实施置信度阈值（<0.7 → 走安全路径）
- 提供"这不是我需要的"用户反馈机制
- 允许多Agent尝试（前2-3个最可能的路由）

### 8.2 路由表膨胀
随着Agent数量增长，路由规则维护成本急剧上升。

**缓解：**
- 层级路由（粗→细粒度，减少每层选项数）
- 语义路由减少显式规则数量
- 定期审计和合并冗余路由

### 8.3 边界模糊请求
某些请求天然跨越多个领域，难以精确分类。

**缓解：**
- 允许一个请求路由到多个Agent
- 实施"Agent推荐"而非强制路由
- 让用户参与路由决策（低置信度时）

> Router + Dispatcher是性价比最高的Agent架构之一。
> 核心原则：用便宜的模型做路由决策，用专业的Agent处理具体任务，
> 只在必要时动用最强模型。2025年的双速架构代表了最佳实践。
> 对于大多数企业应用，从Router-Dispatcher开始，在需要时再
> 升级到Supervisor或Multi-Agent方案，是最务实的路径。
''';
