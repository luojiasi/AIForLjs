/// Critic-Editor — 完整详解
const String criticEditorFullDetail = '''

# 批评-编辑配对模式 (Critic-Editor Pattern) - 完整详解

## 第一章：核心概念

### 1.1 定义

Critic-Editor是一种双Agent配对架构。Editor负责生成内容，Critic负责
严格审查——强制执行约束（测试用例、代码风格、安全检查、事实准确等）。
如果审查不通过，Editor会收到Critic提供的结构化反馈，修正后重新提交。

这像"作者+编辑"的工作模式：作者创作内容，编辑指出问题，作者修改，
编辑再审，直到满意为止。

### 1.2 与Reflection的关键区别

| 维度 | Reflection | Critic-Editor |
|------|-----------|---------------|
| 审查者 | 同一Agent | **独立Agent** |
| 反馈类型 | 自我反思（可能不客观） | 结构化审查 |
| 客观性 | 中（自我偏差） | **高（独立审查）** |
| 专业度 | 依赖Agent自身能力 | **可专门优化Critic** |
| 模型配置 | 同一模型 | **可不同模型（Critic用严格模型）** |
| 适用场景 | 通用质量提升 | 有明确约束的任务 |

### 1.3 架构设计

```
┌──────────┐    生成（Generate）    ┌──────────┐
│  Editor  │ ─────────────────────→ │  Critic  │
│  编辑者   │ ←───────────────────── │  批评者   │
│ (创造性)  │   反馈（Feedback）      │ (严格性)  │
└──────────┘                        └────┬─────┘
     ↑                                   │
     │         修正（Revise）              │ 通过（Approve）
     └───────────────────────────────────┘ ↓
                                        [最终输出]

配置差异：
  Editor: temperature=0.7, model=强推理模型, 创造性思维
  Critic: temperature=0.1, model=精确严谨模型, 检查性思维
```

## 第二章：五大约束类型

### 2.1 功能约束（Hard — 不可妥协）
代码必须通过所有测试用例。数学计算必须正确。逻辑推理必须有效。
不满足→必须修改。

**例子：**
```python
# Editor生成
def divide(a, b):
    return a / b

# Critic审查
✗ 功能检查：未处理b=0的除零错误 [CRITICAL-FUNCTIONAL]
→ Editor必须添加异常处理
```

### 2.2 安全约束（Hard — 最高优先级）
- 无SQL注入漏洞
- 无XSS漏洞
- 无敏感信息泄露
- 无命令注入
- 不满足→绝不可通过（一票否决）

**检查列表：**
```
□ 参数化查询（非字符串拼接SQL）
□ 输入验证和转义
□ 输出编码（防XSS）
□ 无硬编码密钥/密码
□ 最小权限原则
```

### 2.3 风格约束（Hard）
代码符合PEP8/ESLint/Prettier标准。文档符合格式要求。
通常可以自动格式化，但Critic仍需验证。

### 2.4 事实约束（Medium-Hard）
引用的数据必须来源可查。主张必须有证据支持。
Critic通过工具交叉验证事实声明。

### 2.5 格式约束（Medium）
输出必须符合指定的JSON Schema/Markdown格式/API合约。
Critic进行模式验证和解析测试。

## 第三章：结构化反馈格式

Critic的反馈必须是结构化的，便于Editor精确理解和处理：

```json
{
  "verdict": "REVISE",
  "issues": [
    {
      "severity": "CRITICAL",
      "category": "SECURITY",
      "location": "line 3: query = \"SELECT...\" + user_input",
      "description": "直接字符串拼接SQL查询，可被SQL注入攻击",
      "suggestion": "使用参数化查询：cursor.execute(query, (user_input,))",
      "cwe_id": "CWE-89"
    },
    {
      "severity": "WARNING",
      "category": "STYLE",
      "location": "函数: get_user",
      "description": "缺少类型注解和文档字符串",
      "suggestion": "添加: def get_user(user_id: int) -> Optional[User]:"
    }
  ],
  "summary": "1个关键安全问题（必须修复）和1个风格建议。",
  "revision_round": 1,
  "max_rounds": 5
}
```

**严重度级别：**
- **CRITICAL：** 必须修复（安全漏洞、功能缺陷）
- **WARNING：** 应该修复（风格问题、最佳实践）
- **INFO：** 建议改进（可选优化）

## 第四章：Google Jules — 批评增强生成（2025年8月）

### 4.1 架构
- Critic嵌入到代码生成管道中
- 在提交前审查**每一个提议的更改**
- 执行对抗性审查：挑战逻辑错误、缺失边界情况、静默字段丢失、低效算法（不必要的O(n²)）
- 在**人工审查之前**运行——开发者收到预先审问的代码

### 4.2 工作流
```
开发者提出PR
  ↓
[Editor Agent] 根据PR描述生成代码修改
  ↓
[Critic Agent] 审查修改（安全、功能、风格、效率）
  ↓
如果发现问题 → [Editor Agent] 修改 → 回到审查
  ↓
如果通过 → 人工开发者审查（已过滤掉常见问题）
```

## 第五章：对抗性AI代码审查（gaurav-yadav）

### 5.1 核心创新

**最具对抗性的Critic-Editor实现：**

审查Agent提议发现 → 匹配的开发者Agent尝试驳回 →
只有经受住交叉审查的发现才到达人类。

### 5.2 架构
```
22个专门Agent对（每个对 = Editor + Critic）
  ↓
Phase 1: Critic审查 → 发现潜在问题
  ↓
Phase 2: Editor尝试驳回/辩护 → 交叉审查
  ↓
Phase 3: 只有双方无法达成一致的发现 → 上报人类
```

### 5.3 生产数据

| 指标 | 单次审查（传统） | 对抗性审查 |
|------|--------------|----------|
| 误报率 | 30-60% | **~7%** |
| 漏报率 | ~15% | **~3%** |
| 人类审查时间节省 | — | ~60% |
| 成本/PR | ~\$0.10 | \$0.50-\$3.00 |
| 墙钟时间 | ~30s | 2-6分钟 |
| 生产PR验证 | — | **500+** |

## 第六章：关键设计原则

### 6.1 多样性胜过单一文化
不同模型探索不同解决方案空间。即使相同模型但不同提示、角色和目标的
Agent也能避免橡皮图章效应。

### 6.2 结构化门控，非开放式循环
验证是顺序的：构建→审查→通过/失败门→循环回来。
每次运行产生纸质追踪。

### 6.3 对抗性优于自我审查
研究表明LLM在困难推理任务上无法可靠地自我修正（Huang et al., 2023）。
**永远不要让一个Agent既提出问题又解决问题。**

### 6.4 要求具体证据
代码路径、失败条件、具体示例——不是模糊的"这里可能有问题"。
Critic必须引用具体的行号、CWE编号、测试用例。

### 6.5 专业化优于泛化
22个专门Agent对击败50个通用Agent（gaurav-yadav实验证据）。
领域特定审查者知道他们服务的认证模式、数据模型和红旗信号。

## 第七章：设计决策

### 7.1 同一模型还是不同模型？

| 方案 | 成本 | 客观性 | 推荐场景 |
|------|------|--------|---------|
| 同一模型 | 低 | 低（相同盲点） | 预算有限、低风险任务 |
| 不同模型（如Claude审GPT） | 中 | 高 | 安全审查、合规审查 |
| 多模型委员会 | 高 | 最高 | 高风险决策、医疗/金融 |

### 7.2 Critic严格程度校准

- **太松：** 漏掉关键问题 → 失去审查意义
- **太严：** 无限修改循环 → Editor永远无法通过
- **最佳实践：** 分层级（Critical必须修，Warning可忽略，Info参考）
- **循环限制：** 2-4轮修改（超过3轮收益递减）

### 7.3 最大修改轮次策略

```
Round 1-2: 修复所有Critical和大部分Warning
Round 3: 仅修复Critical
Round 4: 仅修复安全Critical
Round 5+: 接受当前版本或转人工审查
```

## 第八章：实现示例

### 8.1 LangGraph双节点循环

```python
from langgraph.graph import StateGraph, END

class CriticEditorState(TypedDict):
    task: str
    draft: str
    critique: dict
    round: int
    final_output: str

def editor_node(state):
    if state.get("critique"):
        draft = editor_llm.revise(state["task"], state["draft"],
                                   state["critique"])
    else:
        draft = editor_llm.generate(state["task"])
    return {"draft": draft, "round": state.get("round", 0) + 1}

def critic_node(state):
    critique = critic_llm.review(state["draft"],
        check_categories=["security", "functional", "style"])
    return {"critique": critique}

def should_continue(state):
    if critique["verdict"] == "APPROVE":
        return "end"
    if state["round"] >= 5:
        return "end"  # 超限，接受当前版本
    return "revise"

graph = StateGraph(CriticEditorState)
graph.add_node("editor", editor_node)
graph.add_node("critic", critic_node)
graph.add_edge(START, "editor")
graph.add_edge("editor", "critic")
graph.add_conditional_edges("critic", should_continue,
    {"revise": "editor", "end": END}
)
```

### 8.2 AutoGen双Agent循环

```python
from autogen import AssistantAgent

editor = AssistantAgent("Editor",
    system_message="你是内容创作者。根据Critic的反馈修改内容。",
    llm_config={"config_list": [editor_llm_config]})

critic = AssistantAgent("Critic",
    system_message="你是严格的质量审查者。检查安全、功能、风格。",
    llm_config={"config_list": [critic_llm_config]})

# 启动对话循环
editor.initiate_chat(critic, message="请审查我刚生成的代码")
```

## 第九章：生产应用场景

| 领域 | Editor角色 | Critic角色 | 典型改进 |
|------|-----------|-----------|---------|
| **代码审查** | 代码生成 | 安全+功能+风格审查 | 减少60%人工审查时间 |
| **合规内容** | 内容草拟 | 法规合规检查 | 减少90%合规违规 |
| **学术论文** | 初稿撰写 | 同行评审式审查 | 提高50%录用率 |
| **法律文档** | 合同起草 | 法规审查 | 减少80%法律错误 |
| **翻译QA** | 翻译生成 | 对照原文检查 | 提高30%翻译质量 |
| **安全审计** | 系统配置 | OWASP/PCI审查 | 发现95%+常见漏洞 |

> Critic-Editor是保障Agent输出质量的最强架构。
> 核心原则：**永远不要让一个Agent既做又查。**
> 通过将生成者与审查者分离为两个独立Agent（可能使用不同模型），
> 实现了无自我偏差的客观审查。对抗性审查将误报率从30-60%降至~7%。
> 在安全、合规、代码质量等有明确约束的领域，Critic-Editor是
> 不可或缺的质量保障机制。
''';
