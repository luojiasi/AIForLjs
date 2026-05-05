/// Workflow + Tool Calling — 完整详解
const String workflowToolCallingFullDetail = '''

# 工作流 + 工具调用 (Workflow + Tool Calling) - 完整详解

## 第一章：历史演进 (2022-2025)

### 1.1 前身：LLM的"能力边界"问题 (2022之前)

在Function Calling出现之前，以GPT-3为代表的LLM虽然规模庞大，但存在
广为人知的局限性：

- 无法进行精确算术运算（175B参数的模型也算不对3位数乘除法）
- 无法获取实时信息（训练数据截止日期之后的世界一无所知）
- 频繁产生"幻觉"（Hallucination）——自信地编造事实
- 无法感知时间推移（不知道"今天"是哪一天）

**根本洞察：** 与其试图把所有能力都编码进模型权重（不可能完成的任务），
不如让模型学会"使用工具"——就像人类一样。

### 1.2 早期探索：ReAct与提示词驱动的工具使用 (2022)

ReAct（Yao et al., 2023, ICLR）是最早将推理与工具使用融合的框架之一。
它完全基于提示词工程，不需要模型微调。模型在Thought→Action→Observation
的循环中交替输出"思考"和"行动"。

但这种方案有明确的局限：
- 工具调用格式完全依赖提示词约束，模型可能不遵守
- 没有结构化的输出保证（JSON格式可能不合法）
- 每次都需要大量Few-shot示例
- 对模型推理能力要求极高

### 1.3 Toolformer：自监督工具学习 (2023年2月)

Meta AI的Toolformer（arXiv:2302.04761）是工具调用的里程碑论文。
在6.7B参数的GPT-J模型上展示了令人惊叹的结果。

**核心方法（四步）：**

```
Step 1 — 采样（Sampling）
用上下文学习让LM在大型文本语料库中标注潜在的API调用。
对于语料库中的每个位置，模型生成一个可能的API调用。

Step 2 — 执行（Execution）
实际执行每个候选API调用，获取真实的工具返回结果。

Step 3 — 基于损失的过滤（Loss-based Filtering）
只保留那些改进了下一个token预测损失的API调用。
这是Toolformer最聪明的设计——如果工具调用没有改善模型的
语言建模能力，它就不会被保留。

Step 4 — 微调（Fine-tuning）
用特殊标记（<API>、</API>、->）在增强数据集上微调模型。
```

**关键结果：** Toolformer（6.7B）在零样本任务上大幅超越了GPT-3（175B）
等大得多的模型——而且没有损失核心语言建模能力。这证明了"会用工具的小模型"
可以胜过"不会用工具的大模型"。

### 1.4 OpenAI Function Calling：工具调用的工业化 (2023年6月)

2023年6月，OpenAI在GPT-3.5-turbo和GPT-4的API中正式引入Function Calling。
这是Agent工具调用能力的"iPhone时刻"——从学术探索变成工业化产品。

关键特征：
- API参数：functions + function_call
- 并行调用：不支持（一次只能调用一个函数）
- 执行模型：同步、单步
- 模型支持：gpt-3.5-turbo-0613、gpt-4-0613

### 1.5 并行工具调用：从串行到并发 (2023年12月-2024年)

2023年12月的API预览版首次引入并行函数调用——模型可以在单次响应中
请求多个函数调用。

2024年成为真正的转折点：
- GPT-4o（5月）、GPT-4o-mini（7月）、GPT-4-turbo（4月）全面支持并行工具调用
- API现代化：functions/function_call被废弃，tools/tool_calls/tool_choice成为新标准
- tool_choice支持"auto"/"none"/"required"三种模式，实现精细控制
- OpenAI Assistants API内置工具：code_interpreter、file_search、function
- Realtime API（10月）为多模态工具调用奠定基础

### 1.6 MCP协议：工具调用的标准化 (2024年11月-2025年)

2024年11月，Anthropic开源了MCP（Model Context Protocol），被业界称为
"AI工具的USB-C接口"——一个统一的AI-工具交互协议。

2025年MCP生态爆炸式增长：
- 2000+ MCP服务器被创建
- Claude Desktop、Cursor、VS Code等主流工具原生支持
- 2025年3月规范重大更新：OAuth 2.1认证、Streamable HTTP取代HTTP+SSE、工具注解、音频数据支持
- 2025年6月：结构化工具输出、Elicitation支持、Resource Links
- 2025年11月：基于任务的工作流（实验性）、URL-based客户端注册、服务端发起的Agent循环
- 2025年底：MCP捐赠给Linux Foundation的Agentic AI Foundation

### 1.7 2025：Agent原生与标准化元年

| 时间 | 里程碑 | 意义 |
|------|--------|------|
| 1月 | OpenAI o3-mini | Function Calling + Structured Outputs, SWE-bench 48.9% |
| 4月 | GPT-4.1 | 1M token上下文, SWE-bench 54.6% |
| 5月 | Claude 4 | 扩展思考+工具调用(beta), SWE-bench 72%+ |
| 8-10月 | GPT-5系列 | 全系列支持并行工具调用 |
| 全年 | MCP生态 | 2000+服务器, 多客户端原生支持 |
| 4月 | Google A2A | Agent间通信协议标准化 |
| 10月 | OpenAI+Stripe ACP | 商业协议（Agent Commerce Protocol） |
| 2026初 | WebMCP | 浏览器原生MCP |

## 第二章：五大子模式详解

### 2.1 单步工具调用（Single Tool Call）

最简单、最基础的模式。用户提问 → LLM选择一个工具 → 工具执行 → 结果回传 →
LLM生成最终回复。

**特征：**
- 最低延迟（只有一次工具调用）
- 最小的失败面（只有一个外部调用）
- 最简单，最易调试和审计

**局限：** 无法处理需要多源信息的任务。

**最佳场景：** 简单事实检索、单API查询、无需组合多数据源的任务。

### 2.2 链式工具调用（Chained Tool Calling）

LLM调用一个工具，接收结果，基于结果推理，然后决定是否调用另一个工具。
这构成了ReAct风格的循环。

**流程：** 用户查询 → LLM规划第1步 → 工具A执行 → LLM基于结果推理 →
工具B执行 → LLM基于结果推理 → LLM综合生成最终答案

**两种变体：**
- **静态链（确定性）：** 开发者预定义精确的工具序列，不需要LLM推理选择
- **动态链：** LLM基于中间结果自主决定下一个工具

**防护栏：**
- 步数限制：防止无限循环（典型值：5-15步）
- 超时机制：总执行时间限制
- 持久检查点：每步保存状态，支持恢复

### 2.3 并行工具调用（Parallel Tool Calling）

LLM同时派发多个独立的工具调用。聚合步骤收集所有结果后LLM综合生成
最终答案。

**实现模式：**
- **FORK/JOIN：** 静态扇出，开发者预定义并行分支
- **DYNAMIC_FORK：** LLM在运行时动态决定并行调用哪些工具

**关键考量：**
- 必须处理部分失败（一个成功一个失败）
- 任务必须真正独立（无数据依赖关系）
- 需要幂等性键和关联ID来追踪每个工具调用的状态

**例子——代码审查：**
```
安全漏洞检查 + 性能优化分析 + 代码可读性审查 → 三者并行执行 →
合并为综合审查报告
```

### 2.4 条件分支工具调用（Conditional / Routing）

分类或路由步骤决定哪个工具（或模型）应该处理输入。

**子模式：**
- **模型路由：** 简单问题→便宜/快速模型，复杂问题→强大模型
- **工具路由：** 不同意图路由到不同专业工具或子Agent
- **护栏门：** 验证中间输出，质量低于阈值时分支到错误处理
- **SWITCH/DECISION节点：** 在工作流引擎中，基于工具输出进行命令式条件分支

### 2.5 Human-in-the-Loop (HITL)

Agent在执行高风险操作前暂停，等待明确的人类批准。

**流程：**
```
用户查询 → LLM规划行动 → LLM标记"needs_approval: true" →
工作流暂停 → 通知发送给人类 → 人类批准/拒绝 →
工作流恢复 → 行动执行（或中止）
```

**关键要求：** 暂停必须是持久的（durable），不是内存中的sleep。
如果服务器在等待期间重启，工作流必须从精确的中断点恢复。

**适用场景：**
- 发送给10000+收件人的邮件："即将发送，是否批准？"
- 金融操作："即将扣款\$500，是否继续？"
- 数据变更："即将删除50条记录，确认？"

**两种实现方式：**
- **双工具分阶段：** 批准操作和目标操作在不同工具中，LLM依次调用
- **单工具门控：** 批准作为工具内部的gating，通过持久暂停机制实现

### 2.6 子模式组合实践

真实生产Agent将这些模式组合使用：
```
路由 → 分类请求
  ↓
并行调用 → 收集多源数据
  ↓
链式调用 → 处理有依赖的后续操作
  ↓
HITL门控 → 在破坏性操作前等待人工确认
```

## 第三章：MCP架构深度解析

### 3.1 三层架构

| 组件 | 职责 |
|------|------|
| **MCP Host** | LLM应用（Claude Desktop、VS Code、Cursor）。创建/管理多个客户端实例，执行安全策略，处理用户同意，协调LLM集成 |
| **MCP Client** | Host生成的轻量连接器。与每个MCP Server保持1:1有状态会话。处理协议协商、能力交换、双向消息路由 |
| **MCP Server** | 通过MCP原语暴露专门能力的程序。可在本地（STDIO）或远程（Streamable HTTP）运行 |

### 3.2 双层设计

**数据层（Data Layer）：**
- 基于JSON-RPC 2.0的交换协议
- 生命周期管理：初始化→能力协商→操作→关闭
- Server原语：Tools（可执行函数）、Resources（上下文/数据）、Prompts（模板消息）
- Client原语：Sampling（Server发起的LLM调用）、Roots（文件系统边界查询）、Elicitation（服务器请求用户输入）

**传输层（Transport Layer）：**
- STDIO传输：用于本地进程通信
- Streamable HTTP传输：HTTP POST/GET，可选SSE流式传输
- 会话管理通过Mcp-Session-Id头
- 可恢复性通过Last-Event-ID
- OAuth 2.1认证

### 3.3 核心设计原则

1. **服务器应该极易构建** — Host处理复杂编排；服务器专注于特定能力
2. **服务器应该高度可组合** — 多个服务器通过共享协议无缝组合
3. **服务器不能读取整个对话** — 完整对话历史保持在Host端；每个服务器连接是隔离的
4. **渐进式功能添加** — 核心协议提供最小必需功能；通过协商按需添加额外能力

### 3.4 能力协商

初始化时，客户端和服务器明确声明支持的特性：
- Server capabilities: prompts, resources, tools, logging, experimental
- Client capabilities: roots, sampling, elicitation, experimental

## 第四章：主流框架实现

### 4.1 LangGraph（生产级推荐）

**核心模式：StateGraph + ToolNode + tools_condition**

```python
from langgraph.prebuilt import create_react_agent

app = create_react_agent(model, tools)
app.invoke({"messages": [{"role": "user", "content": "查询旧金山今天的天气"}]})
```

**高级模式：**
- **UniversalToolNode：** 自定义预执行验证、结构化错误ToolMessages
- **InjectedState/InjectedStore：** 工具访问图状态或持久存储而不暴露给LLM
- **Send API：** LLM发出多个独立工具调用时的并行工具执行
- **interrupt()：** 在敏感操作前实现HITL暂停
- **Checkpointer后端：** SqliteSaver、MongoDBSaver、PostgresSaver用于持久状态

### 4.2 LlamaIndex Agent Workflows

三种Agent类型：
| Agent类型 | 最适合 |
|-----------|--------|
| FunctionAgent | 具有原生函数调用的LLM（OpenAI, Anthropic, Bedrock） |
| ReActAgent | 没有原生函数调用的LLM，使用ReAct提示 |
| CodeActAgent | 需要自动代码执行的复杂任务 |

**多Agent编排：**
```python
from llama_index.core.agent.workflow import FunctionAgent, AgentWorkflow

research_agent = FunctionAgent(tools=[search_tool], ...)
writer_agent = FunctionAgent(tools=[summarize_tool], ...)

workflow = AgentWorkflow(
    agents=[research_agent, writer_agent],
    root_agent="research_agent"
)
response = await workflow.run("调研并总结话题X")
```

### 4.3 Anthropic Claude Agent SDK 最佳实践

- **合并工具：** 不要提供list_users + list_events + create_event，而是提供一个schedule_event处理所有事情
- **返回高信号上下文：** 将UUID解析成语义名称
- **Token效率：** 分页、范围选择、过滤、截断（Claude Code默认限制工具响应为25,000 tokens）
- **命名空间：** 用公共前缀分组相关工具（如asana_projects_search、asana_users_search）

### 4.4 OpenAI (2025现代API)

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "巴黎和伦敦的天气如何？"}],
    tools=[{"type": "function", "function": {"name": "get_weather", ...}}],
    tool_choice="auto",
    parallel_tool_calls=True,  # 2025年默认启用
)
```

**高级特性：**
- allowed_tools：动态限制每回合可用的工具子集
- reasoning_effort (minimal/low/medium/high)：微调思考深度与延迟的平衡
- strict: true：JSON结构化输出成功率从~40%跃升至90%+

## 第五章：生产最佳实践

### 5.1 工具设计原则

1. **原子性和单一职责** — 每个工具一个关注点。避免"万能"工具
2. **一致的命名** — 全snake_case。按服务和资源命名空间化
3. **战略性选择** — 更多工具不等于更好结果。构建与人类自然细分任务相匹配的工具
4. **工具描述作为产品规格** — 使用模板：用于做X的工具。当Y情况发生时使用。保持在1024字符以下

### 5.2 Schema设计准则

- 严格的JSON Schema（additionalProperties: false，明确的required字段）
- 用枚举表示有限集合，避免让模型从文本中读取值
- 显式格式声明（"format": "email", "format": "date-time"）
- 参数描述中包含微型示例
- 更少的顶层参数 → 更少的模型错误
- response_format枚举（如CONCISE vs. DETAILED）让Agents控制输出详细程度

### 5.3 提示词工程策略

```
Policy（策略）:
- 仅在缺少必要数据或需要外部操作时调用工具
- 如果任何必需参数未指定，提出一个澄清问题
- 如果可以直接从上下文回答，不要调用工具
- 永远不要猜测参数值；优先请求澄清

对于强制性工作流：
"始终在回复之前调用必需函数。永远不要从记忆中提供信息。
永远不要跳过工作流序列中的函数。"
```

### 5.4 常见故障模式和修复

| 故障模式 | 修复方案 |
|---------|---------|
| 幻觉的工具调用 | 收紧决策规则；要求前置条件；添加检索基础 |
| 参数指定错误 | 加强JSON Schema；使用验证器反馈重试 |
| 上下文溢出 | 监控Token计数；压缩/窗口化记忆 |
| 多Agent协调问题 | 可视化移交；要求规划者确认；添加检查点 |
| 无限Agent循环 | 最大步数限制和执行预算 |
| 非确定性重试灾难 | 幂等性键；永远不要仅仅因为第一次超时就重试支付API |

### 5.5 可观测性

**最小日志Schema：**
```json
{
  "trace_id": "0af76519...",
  "tool_name": "jira.create_ticket",
  "status": "failed",
  "duration_ms": 2340,
  "retry_attempts": 3,
  "error_category": "rate_limit",
  "original_request": { ... },
  "upstream_response": { ... }
}
```

端到端追踪：在每个步骤中关联Thought → Action → Observation。
使用带有跨子Agent关联ID的OpenTelemetry traces。

### 5.6 安全考量

OWASP LLM Top 10中最相关的风险类别：
- **LLM06: Excessive Agency** — 模型连接的工具超出用例所需范围
- **LLM08/09:** 工具链劫持和沙箱逃逸

**缓解措施：**
- 最小权限工具身份（每个工具以最小权限运行）
- 对高影响操作使用HITL门控
- 步数限制和执行预算防止失控循环
- 按工具允许列表和默认拒绝连接器
- 在Micro VMs或安全运行时中运行工具
- 严格的出口允许列表
- 固定版本和签名制品（SBOM, SLSA provenance）
- 永远不要让LLM生成原始shell命令或SQL——暴露有限的预定义安全函数
- 将用户身份和会话声明绑定到每个工具调用

## 第六章：实际生产部署案例

### 6.1 GS Caltex（能源行业，韩国）
- 50+ Agent由非技术业务团队在财务、法务、HR、生产、销售领域构建
- 约85%的办公室员工是常规用户；95%的生产员工使用过该平台
- 应用场景：岗前安全简报、原油采购合同审查、医疗费用报销

### 6.2 Swisscom（电信，\$19B收入）
- Amazon Bedrock AgentCore + MCP + A2A协议
- 应用场景：个性化销售提案生成、自动化技术支持
- 在瑞士严格的数据保护法下，3-4周交付首个利益相关者演示

### 6.3 CyberArk（身份安全）
- 生产RAG Agent超越聊天——通过API执行操作（创建用户、触发升级、删除记录）
- 使用多模态LLM分析数百万小时的权限会话记录
- 分层分块+Anthropic Contextual Chunking提高准确率5-7%

### 6.4 Salesforce Agentforce

| 组织 | Agent | 用例 | 成果 |
|------|-------|------|------|
| Hampshire Police (UK) | "Bobby" | 非紧急咨询，弱势呼叫者升级 | 正确识别儿童虐待报告，10分钟内升级 |
| Pandora (珠宝) | "Gemma" | 售后咨询，对话式电商 | NPS比纯人工高10.5分 |
| LIV Golf | "Agent Caddy" | 实时评论员统计，粉丝互动 | 统计信息同时传递给评论员、球员和粉丝 |

## 第七章：工具调用的Token成本分析

### 7.1 成本结构分解

| 组件 | 每轮Token | ×3轮 | 占比 |
|------|----------|------|------|
| 工具JSON Schema定义 | 11,100 | 33,300 | 69% |
| 系统提示词 | 2,870 | 8,610 | 18% |
| 工具返回结果(~2000字×2) | 4,000 | 4,000 | 8% |
| 对话消息历史 | 1,750 | 5,250 | 5% |

**关键发现：** 工具定义的Token消耗占总成本的69%——远超过对话本身。

### 7.2 成本优化策略

**P0 — 提示缓存（最大的即时胜利）：**
- 系统提示+工具定义（~14K Token）在所有请求中占据第一个位置
- 利用OpenAI的自动前缀缓存（90%折扣）
- 估算成本降低：~52%

**P1 — 工具Schema缩减：**
- 修剪冗长的工具描述（很多达到700-900 Token）
- 仅包含与当前查询相关的工具（轻量相关性检查分类）
- 分组：核心工具始终加载 vs. 专业工具按需加载

**P2 — 替代架构：**
- 对于结构化可预测工作流，ReWOO用恰好2次LLM调用替换ReAct的N+1次调用
- 实现5倍Token效率

## 第八章：未来趋势

### 8.1 市场增长
- 多Agent系统市场：\$78.1B (2025) → \$549.1B (2030)，CAGR 47.71%
- 企业AI Agent集成：<5% (2025) → ~40% (2026年底)
- 62%的组织积极实验Agent；23%已达到规模化

### 8.2 协议时代

15个月的基础设施爆炸：
- 2024.11：Anthropic开源MCP
- 2025初：社区添加OAuth、long-running task支持
- 2025.04：Google发布A2A
- 2025中：AG-UI、A2UI、MCP-UI（UI协议出现）
- 2025.10：OpenAI+Stripe发布ACP（商业协议）
- 2025底：MCP捐赠给Linux Foundation
- 2026初：WebMCP（浏览器原生MCP）

### 8.3 关键趋势

1. **从"模型竞争"转向"系统互操作性竞争"** — 差异化转向工具访问广度、跨组织Agent协作、可审计性和开放可扩展性
2. **MCP和A2A互补而非竞争** — MCP处理上下文+工具集成（"AI的USB-C"），A2A处理Agent间通信（"Agent的HTTP"）
3. **跨企业Agent经济体** — 联邦架构与零信任模型、可验证身份数字护照、分层自主权
4. **可观测性、评估和治理成为一等关注点** — 不是"第一天能用吗"，而是"第六个月还可靠吗"
5. **工程范式转变** — 核心瓶颈已从"模型智能"转移到"协议、互操作性和治理"

> "2025年是构建Agent的一年。2026年是信任Agent的一年。" — Michael Ni
>
> "Agent的未来不是更像人类——而是更像互联网：
> 标准协议、统一接口、开放连接、可组合服务。" — 行业共识
''';
