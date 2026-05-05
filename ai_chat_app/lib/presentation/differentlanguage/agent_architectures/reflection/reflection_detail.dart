/// Reflection / Reflexion — 完整详解
const String reflectionFullDetail = '''

# 反思模式 (Reflection / Reflexion) - 完整详解

## 第一章：Reflexion论文深度解读

### 1.1 论文信息
- **标题:** Reflexion: Language Agents with Verbal Reinforcement Learning
- **作者:** Noah Shinn, Federico Cassano, Edward Berman, Ashwin Gopinath, Karthik Narasimhan, Shunyu Yao
- **发表:** NeurIPS 2023
- **arXiv:** 2303.11366
- **代码:** github.com/noahshinn/reflexion

### 1.2 核心创新

Reflexion的核心创新是：**不需要更新模型权重**，仅通过在推理时加入"口头反思"
机制，让Agent从试错中学习。Agent用自然语言反思失败原因，将这些反思存储
在情景记忆（Episodic Memory）中，指导未来的尝试。

这是被Andrew Ng（吴恩达）列为四大Agent设计模式之一的架构。

**为什么是"口头"强化学习？**

传统RL需要大量的试错和环境交互来更新策略。Reflexion创造性地将
"口头反思"作为强化学习的信号——反思文字就是"奖励信号"的语义
表示。这种方法不需要梯度更新，因此可以直接应用于任何现成的LLM，
包括API访问的闭源模型。

### 1.3 三大核心组件

**Actor（生成者）—— 负责行动和文本生成**
- 使用ReAct或Chain-of-Thought进行推理和生成
- 条件化于：当前任务 + 短期记忆（最近轨迹）+ 长期记忆（历史反思）
- 在RL类比中对应于策略（Policy）
- Actor不评估自己的输出——评估由Evaluator独立完成

**Evaluator（评估者）—— 负责评分与批评**
Reflexion使用三种不同类型的评估器，取决于任务：

1. **精确匹配分级（Exact Match Grading）**
   - 用于：HotpotQA推理任务
   - 方法：比较生成的答案与标准答案
   - 信号：二进制（正确/不正确）

2. **启发式函数（Heuristic Functions）**
   - 用于：AlfWorld决策任务
   - 方法：检测幻觉行为（如试图与不存在的物体交互）、检测无意义的重复循环
   - 信号：启发式规则定义的成功/失败

3. **LLM-as-Evaluator（LLM作为评估者）**
   - 用于：HumanEval编程任务
   - 方法：LLM生成单元测试，然后代码执行检查输出
   - 信号：测试用例的通过/失败率
   - 论文发现**自我评估（LLM编写单元测试）产生最强结果**

**Self-Reflection（自我反思）—— 生成口头反馈**
- 接收：Actor的完整执行轨迹 + 稀疏奖励信号（二进制成功/失败）
- 产出：自然语言格式的失败原因总结
- 存储：情景记忆供未来尝试参考
- 示例反思："上次输出在内存管理部分有错误。具体来说，函数foo在第12行
  没有检查指针是否为null就直接使用。下次应先验证指针非空。"

### 1.4 基准测试结果

| 基准 | 任务类型 | 基线方法 | Reflexion | 提升幅度 |
|------|---------|---------|-----------|---------|
| AlfWorld | 具身AI决策(134环境, 6任务类型) | ReAct: 63-73% | **97%（130/134完成）** | +22-34% |
| HotpotQA | 知识密集推理QA | CoT/ReAct: 34% | **51-54%** | +17-20% |
| HumanEval (Python) | Python代码生成(164题) | GPT-4: 80.1% | **91.0%** | +10.9% |
| HumanEval (Rust) | Rust代码生成 | 之前最佳 | **新SOTA** | — |
| LeetcodeHard | 困难算法题 | 新数据集 | **新SOTA** | — |

**HumanEval详细分析：**
- GPT-4基准：80.1% (Pass@1)
- GPT-4 + Reflexion：91.0% (Pass@1)
- 这意味着164题中从约131题正确提升到约149题正确
- 改善了18题，占原本错误题目的54%

### 1.5 关键消融发现

| 消融实验 | 结果 | 关键洞察 |
|---------|------|---------|
| 仅二进制反馈 vs 完整反思 | 二进制反馈已提供有意义增益 | 最简单的反馈形式也能帮助 |
| 自我评估（LLM写测试）vs 外部评估 | 自我评估最强 | LLM评估自己的能力是Reflexion的关键 |
| 记忆大小 1 vs 3 vs 5+ | 1-3条反思是最优的 | 过多反思超出上下文限制反而有害 |
| GPT-3.5 vs GPT-4 | 两个模型都有效 | 更强模型上绝对增益更大 |
| 学习步数（AlfWorld） | 需要~12次迭代收敛 | 复杂任务需要足够的学习步数 |

## 第二章：反思循环详解

### 2.1 完整的执行流程

```
Trial 0 (初始尝试):
  1. Actor基于任务描述产生轨迹 t0
  2. Evaluator计算分数 r0
  3. Self-Reflection生成口头总结 sr0 → 存入记忆 mem = [sr0]

Trial 1:
  1. Actor条件化于（任务 + 记忆[sr0]）→ 产生轨迹 t1
  2. Evaluator计算 r1
  3. if r1 > r0: 反思分析了为什么改进成功
     else: Self-Reflection分析为什么仍然失败 → sr1 → 追加到记忆

Trial 2, 3, ...:
  重复以上过程，直到任务成功或达到最大尝试次数
```

### 2.2 代码生成具体示例

**Attempt 1（初始生成）：**
```
Generate: 实现一个函数 find_duplicates(arr)
  → def find_duplicates(arr):
       seen = set()
       dupes = []
       for x in arr:
         if x in seen: dupes.append(x)
         seen.add(x)
       return dupes

Execute: 运行测试用例 → 3/5通过
  测试1: [] → [] ✓
  测试2: [1,2,3] → [] ✓
  测试3: [1,1,2,2,3] → [1,2,2] ✗ (应输出[1,2]——重复检查错误)
  测试4: [1,2,1] → [1] ✓
  测试5: large_input → 超时 ✗ (O(n²)因为每次x in dupes检查)

Reflect: "测试3失败：当元素出现超过2次时，会被重复加入dupes列表。
         测试5失败：使用list的in操作导致时间复杂度为O(n²)。
         修复方案：测试3——使用set追踪已输出元素。
         测试5——将dupes改为set或使用Counter。"

Store: 反思存入记忆
```

**Attempt 2（基于反思的修正）：**
```
Generate: (已加载反思记忆)
  → from collections import Counter
     def find_duplicates(arr):
       counts = Counter(arr)
       return [x for x, c in counts.items() if c > 1]

Execute: 运行测试用例 → 5/5通过 ✓
  所有测试通过！
  时间复杂度：O(n)
  空间复杂度：O(n)

Return: 最终代码
```

### 2.3 反思策略对比

| 策略 | 实现 | 结果 |
|------|------|------|
| NONE | 不使用任何先前上下文 | 基准线 |
| LAST_ATTEMPT | 仅使用上一次尝试的推理轨迹 | 轻微改善 |
| REFLEXION | 仅使用自我反思摘要 | 显著改善 |
| LAST_ATTEMPT_AND_REFLEXION | 使用上一次轨迹+反思摘要 | **最佳结果** |

## 第三章：三种评估器详解

### 3.1 启发式评估器（Heuristic Evaluator）

**工作原理：**
- 代码生成：运行测试用例，统计通过率
- 数学题：验证最终答案是否正确
- 搜索任务：检查是否找到目标信息
- 决策任务：检测无效循环和幻觉行为

**优点：** 客观、快速、可重复、不依赖LLM判断
**缺点：** 只适用于有明确评判标准的任务
**设计建议：** 启发式规则应覆盖最常见的失败模式，而非所有可能的失败

### 3.2 LLM-as-Judge评估器

**工作原理：**
- 让另一个LLM（或同一LLM但不同配置）评估输出质量
- 评价维度：准确性、完整性、流畅性、安全性、逻辑一致性
- 可提供标量评分或结构化批评

**优点：** 灵活，适用于开放式任务，可评价主观质量
**缺点：** LLM评估本身有偏差（偏好较长输出、偏好权威语气）
**改进方法：**
- 多次采样评估取平均
- 使用不同模型作为评估者（减少自我偏差）
- 提供详细的评分标准（rubric）

### 3.3 工具交互式评估器（CRITIC风格）

**工作原理：**
- 使用外部工具验证输出的具体主张
- 搜索引擎：交叉验证事实声明
- 代码编译器：检查语法和类型正确性
- API验证器：验证数据格式和约束
- 计算器：验证数值计算结果

**优点：** 客观验证、不依赖LLM判断、高度可信
**缺点：** 需要对应的验证工具、某些领域缺乏合适的验证工具

**CRITIC评估流程：**
```
1. LLM生成初始输出
2. 从输出中提取可验证的主张
3. 为每个主张选择合适的验证工具
4. 执行工具验证
5. 将验证结果（支持/反对）反馈给LLM
6. LLM基于验证结果修正输出
```

## 第四章：反思记忆系统

### 4.1 原始Reflexion：滑动窗口记忆

```python
import collections

class EpisodicMemory:
    def __init__(self, max_size=10):
        self.memory = collections.deque(maxlen=max_size)

    def add_reflection(self, reflection: str):
        self.memory.append(reflection)

    def get_reflections(self) -> list:
        return list(self.memory)
```

**局限：** 按时间顺序FIFO淘汰，不管相关性。多任务设置中相关记忆可能丢失。

### 4.2 向量情景记忆（Vector Episodic Memory）

扩展论文用基于向量的检索替换滑动窗口：
- 存储Sentence-BERT嵌入与每个反思一起
- 基于余弦相似度检索（而非时间顺序）
- 9个干扰任务测试：滑动窗口→0%召回，向量记忆→100%召回
- ~14ms检索开销，最多50,000条存储反思
- HumanEval + Gemini 2.5 Flash：Pass@3 = 92.7%（+3.7pp）

```python
class VectorEpisodicMemory:
    def __init__(self, embedding_model, vector_db):
        self.embed = embedding_model
        self.db = vector_db

    def add(self, reflection: str, task_context: str):
        embedding = self.embed(f"{task_context}: {reflection}")
        self.db.insert(embedding, {"reflection": reflection, "task": task_context})

    def retrieve(self, current_task: str, top_k=3) -> list:
        query_embedding = self.embed(current_task)
        results = self.db.search(query_embedding, top_k=top_k)
        return [r["reflection"] for r in results]
```

### 4.3 分层记忆架构

| 记忆类型 | 机制 | 存储后端 | 容量 | 访问延迟 |
|---------|------|---------|------|---------|
| 短期记忆 | 滑动窗口deque（5-10步） | 上下文窗口 | ~10条 | 即时 |
| 长期/情景记忆 | 向量嵌入 + RAG检索 | ChromaDB / FAISS | 50K+条 | ~14ms |
| 目标记忆 | 子目标栈（LIFO） | 提示词中 | ~5个 | 即时 |

### 4.4 反思记忆最佳实践

1. **反思要具体**：不是"代码不好"，而是"第12行缺少空指针检查"
2. **反思要可执行**：不仅指出问题，还要给出具体修改方向
3. **反思要"去重"**：相似反思合并，避免记忆膨胀
4. **定期审计**：清理过时或误导性的反思
5. **设置记忆大小上限**：避免超出上下文限制
6. **任务关联存储**：存储反思时附带任务上下文，检索时按任务相似度排序

## 第五章：CRITIC — 工具交互式批评

### 5.1 论文信息
- **标题:** CRITIC: Large Language Models Can Self-Correct with Tool-Interactive Critiquing
- **作者:** Zhibin Gou et al. (Microsoft Research Asia)
- **发表:** ICLR 2024
- **arXiv:** 2305.11738

### 5.2 核心创新

CRITIC解决了LLM的核心局限——它们会虚构事实、生成有Bug的代码、
产生有毒内容。人类使用外部工具（搜索引擎、代码解释器）来交叉
检查自己的工作，CRITIC让LLM做到同样的事情。

**一个关键洞察：** LLM生成的输出中包含了大量可以客观验证的主张。
CRITIC自动识别这些主张，用外部工具验证，然后让LLM基于验证结果
修正输出。

### 5.3 三阶段流程

```
Phase 1 — 初始生成：
  LLM基于输入产生初步输出

Phase 2 — 工具交互验证：
  LLM被提示：从自己的输出中识别可验证的主张 →
  为每个主张生成工具查询 → 调用外部工具 → 接收客观反馈

Phase 3 — 自我修正：
  LLM基于工具反馈识别错误 →
  修改输出中的不准确之处 →
  生成修正后的版本
```

### 5.4 各任务结果

| 任务类别 | 使用的外部工具 | 数据集 | 最佳增益 |
|---------|-------------|--------|---------|
| 自由形式QA | Google搜索 | TriviaQA, NQ, HotpotQA | **+7.7 F1** |
| 数学程序合成 | Python解释器 | GSM8K, SVAMP | **+7.0%准确率** |
| 毒性降低 | Perspective API | RealToxicityPrompts | **79.2%降低** |

## 第六章：Self-Refine — 同模型自我改进

### 6.1 论文信息
- **标题:** Self-Refine: Iterative Refinement with Self-Feedback
- **作者:** Aman Madaan et al. (CMU, Allen AI)
- **发表:** NeurIPS 2023
- **arXiv:** 2303.17651

### 6.2 与Reflexion的核心区别

| 维度 | Reflexion | Self-Refine |
|------|-----------|-------------|
| 记忆 | 跨试验情景记忆 | 单次会话，无持久记忆 |
| 评估者 | 外部评估器或LLM-as-judge | 同一LLM自我批评 |
| 循环层级 | 试验级（从头重试整个任务） | 输出级（在同一输出上迭代修改） |
| 最佳场景 | 从零完成新任务 | 打磨/润色已有输出 |
| 状态保留 | 跨试验的学习 | 单次会话内的改进 |

### 6.3 三阶段循环

```
Generate（生成初始输出）
  ↓
Feedback（同一LLM对自己的输出进行批评）
  ↓
Refine（基于批评修改输出）
  ↓
(重复约4次迭代)
```

**关键结果：**
- 跨7个不同任务平均**~20%绝对增益**
- 最大增益在最初的1-2次迭代中
- GPT-4效果最好，较弱模型有时会因过度迭代而退化
- 任务包括：对话回复、代码生成、数学推理、文本润色等

## 第七章：三种反思方法的对比与选择

### 7.1 综合对比

| 维度 | Reflexion | CRITIC | Self-Refine |
|------|-----------|--------|-------------|
| 评估机制 | 多层次（启发式+LLM+工具） | 纯工具验证 | 同一LLM自我评估 |
| 记忆系统 | 有（情景记忆+向量检索） | 无（仅会话内） | 无 |
| 跨任务学习 | 支持 | 不支持 | 不支持 |
| 事实准确性 | 中 | 高（工具验证） | 低（自我评估偏差） |
| 实现复杂度 | 高 | 中 | 最低 |
| Token开销 | 高（记忆检索+反思生成） | 中（工具调用+修正） | 低（仅迭代修改） |
| 最佳场景 | 可反复尝试的任务 | 高风险事实准确性 | 主观质量打磨 |

### 7.2 选择决策框架

```
你的任务适合哪种反思方法？

├── 任务可以反复尝试（允许多次从头开始）？
│   ├── 答案有明确对错标准？
│   │   └── 使用 Reflexion（原始框架）
│   └── 答案质量可以逐步改善？
│       └── 使用 Self-Refine
│
├── 需要高事实准确性（不能容忍幻觉）？
│   └── 使用 CRITIC（工具交互验证）
│
├── 需要从历史错误中持续学习？
│   └── 使用 Reflexion + 向量情景记忆
│
└── 延迟敏感或Token预算紧张？
    └── 使用 Self-Refine（开销最小）
```

## 第八章：Andrew Ng的使用原则

Andrew Ng将Reflection列为四大Agent设计模式之一，并给出了实用的
决策框架：

> "问自己两个问题：
> 1. 一个聪明的人类领域专家能通过给予反馈显著改进LLM的初稿吗？
> 2. 你能写一个提示词让另一个LLM充当那个聪明的人类专家吗？
>
> 两个都回答'是' → 使用Critic-Editor模式。
> 只有第一个回答'是' → 从简单的Reflection开始。
> 两个都回答'否' → 反思可能没有帮助。"

## 第九章：实现示例

### 9.1 最小Reflexion实现

```python
class SimpleReflexion:
    def __init__(self, llm, evaluator, max_trials=3):
        self.llm = llm
        self.evaluator = evaluator
        self.max_trials = max_trials
        self.memory = []

    def solve(self, task: str) -> str:
        for trial in range(self.max_trials):
            # 构建提示（包含历史反思）
            prompt = self._build_prompt(task, self.memory)

            # Actor生成答案
            answer = self.llm.generate(prompt)

            # Evaluator评分
            score, feedback = self.evaluator.evaluate(task, answer)

            if score >= 1.0:  # 完美
                return answer

            # Self-Reflection生成反思
            reflection = self.llm.generate(
                f"以下答案未通过评估。分析失败原因并提出改进策略：\n"
                f"任务：{task}\n答案：{answer}\n评估反馈：{feedback}"
            )
            self.memory.append(reflection)

        # 返回最佳尝试
        return answer

    def _build_prompt(self, task, memory):
        base = f"完成以下任务：{task}"
        if memory:
            lessons = "\n".join(f"教训{i+1}：{m}" for i, m in enumerate(memory))
            base = f"从之前的尝试中学习：\n{lessons}\n\n{base}"
        return base
```

### 9.2 LlamaIndex IntrospectiveAgent

```python
from llama_index.agent.introspective import IntrospectiveAgent
from llama_index.llms.openai import OpenAI

# 主Agent（Actor）
main_agent = FunctionAgent.from_tools(tools=[...], llm=main_llm)

# 反思Agent（Evaluator + Self-Reflection合二为一）
reflective_agent = FunctionAgent.from_tools(
    tools=[...],
    llm=reflective_llm,
    system_prompt="你是一个负责审查和改进输出的Agent。严格但建设性。"
)

# 创建IntrospectiveAgent
introspective_agent = IntrospectiveAgent.from_llm(
    main_agent=main_agent,
    reflective_agent=reflective_agent,
    max_iterations=3
)
```

## 第十章：何时避免使用反思

反思并非万能药。以下情况应避免使用：

1. **任务基线准确率已经接近100%**
   额外开销产生的边际增益不划算

2. **延迟敏感的实时应用**
   迭代循环增加不可接受的延迟（每次反思=额外LLM调用）

3. **模型不能自我评估的任务**
   需要模型缺乏的专业领域知识才能判断对错

4. **评估标准在提示词中无法定义**
   过于主观或模糊的评估标准导致反思无意义

5. **过度反思的风险**
   修改了不该修改的正确部分，导致输出退化

6. **成本敏感场景**
   每次反思=额外的Token成本。在生产中可能翻倍

> Reflection是提升Agent输出质量的强大机制。核心公式很简单：
> 生成→评估→反思→改进→重复。但有效实施需要精心设计评估标准、
> 管理反思记忆和设置合理的迭代边界。
> Reflexion、CRITIC和Self-Refine代表了三种不同的设计哲学——
> 分别为：从历史中学习、用工具验证、就地迭代打磨。
> 选择哪种取决于你的任务性质、延迟要求和基础设施条件。
''';
