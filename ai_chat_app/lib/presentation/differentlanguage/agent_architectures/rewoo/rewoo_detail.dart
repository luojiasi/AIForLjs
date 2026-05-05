/// ReWOO — 完整详解
const String rewooFullDetail = '''

# ReWOO 无需观察的推理 - 完整详解

## 第一章：论文深度解读

### 1.1 论文信息
- **标题:** ReWOO: Decoupling Reasoning from Observations for Efficient Augmented Language Models
- **作者:** Binfeng Xu, Zhiyuan Peng, Bowen Lei, Subhabrata Mukherjee, Yuchen Liu, Dongkuan Xu
- **发表:** arXiv:2305.18323, May 2023 (v2: October 2023)
- **代码:** github.com/billxbf/ReWOO

### 1.2 问题根源：ReAct的Token二次增长

要理解ReWOO，必须先理解ReAct的根本效率瓶颈。

在ReAct中，每一轮的LLM调用都必须包含完整的对话历史。当Agent执行k步时：
- 第1步：提示包含 问题 + 第1步的推理+行动
- 第2步：提示包含 问题 + 第1步完整内容(推理+行动+观察) + 第2步推理+行动
- 第3步：提示包含 问题 + 前2步完整内容 + 第3步推理+行动
- ...
- 第k步：提示包含 问题 + 前k-1步所有内容 + 第k步推理+行动

这意味着第i步的提示长度是O(i)，所有k步的Token总消耗为：
\$\$\\text{Total Tokens}_{\\text{ReAct}} \\propto \\sum_{i=1}^{k} i = \\frac{k(k+1)}{2} = O(k^2)\$\$

也就是说，5步任务是1步任务的15倍Token消耗（而非5倍）。对于工具密集型的Agent任务（10+次工具调用），Token成本变得难以承受。

**ReWOO的解决方案：**
将推理（Reasoning）与观察（Observation）完全解耦。ReWOO只进行恰好2次LLM调用：
1. **Planner（规划器）：** 第1次LLM调用，生成完整的解决方案蓝图，用占位符替代工具输出
2. **Solver（求解器）：** 第2次LLM调用，综合所有证据生成最终答案

中间的工具执行完全不经过LLM，由纯工程代码（Worker）按蓝图执行。

Token复杂度从 O(k²) 降为 O(1) —— 与工具调用次数k无关。

### 1.3 为什么"无需观察"是可能的？

ReWOO的关键洞察：**现代LLM具有足够的世界知识来预见需要什么信息，而不需要在每步之后看到实际的工具输出。**

例如，当用户问"比较《盗梦空间》和《星际穿越》的票房"时：
- ReAct方式：搜索《盗梦空间》票房 → 看到结果 → 推断需要搜索《星际穿越》票房 → 搜索 → 看到结果 → 生成比较
- ReWOO方式：LLM在规划阶段就能推断出"需要搜这两部电影的票房"——不需要看到第一部的结果才能知道要搜第二部

这个洞察的适用边界：对于确定性查询（已知信息空间），LLM可以预见所有需要的信息检索步骤。对于高度不确定性、探索性的任务（如代码调试——不看到错误信息不知道下一步该查什么），ReWOO的适用性下降。

### 1.4 关键贡献

1. **Token效率的阶跃提升**：从O(k²)到O(1)，与工具调用次数无关
2. **知识蒸馏突破**：175B GPT-3.5 → 7B Alpaca Planner，25倍参数缩减且保持性能
3. **工具失败鲁棒性**：ReWOO在工具返回空结果时比ReAct更鲁棒
4. **解耦设计**：推理与执行分离使得Planner和Solver可以独立优化和微调
5. **极简架构**：只有3个模块（Planner → Worker → Solver），实现极其简单

## 第二章：三模块架构深度解析

### 2.1 架构总览

```
                     [用户问题]
                          ↓
┌──────────────────────────────────────────────┐
│              第1次LLM调用                      │
│  ┌────────────────────────────────────────┐  │
│  │         Planner（规划器）                 │  │
│  │  - 使用"可预见推理"生成完整执行蓝图        │  │
│  │  - 输出格式: Plan: <推理> #E1 = Tool[args]│  │
│  │  - #Ex是变量占位符，代表未知的工具输出     │  │
│  │  - 一次性输出所有步骤，不等待任何工具结果   │  │
│  └────────────────┬───────────────────────┘  │
└───────────────────┼──────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│               0次LLM调用                      │
│  ┌────────────────────────────────────────┐  │
│  │         Worker（执行器）                  │  │
│  │  - 纯工程实现——没有任何LLM推理            │  │
│  │  - 按顺序执行Planner输出的工具调用         │  │
│  │  - 将#E1替换为工具1的实际输出              │  │
│  │  - 将#E2替换为工具2的实际输出 ...         │  │
│  │  - 不做推理，不做决策，只做变量替换        │  │
│  └────────────────┬───────────────────────┘  │
└───────────────────┼──────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│              第2次LLM调用                      │
│  ┌────────────────────────────────────────┐  │
│  │         Solver（求解器）                  │  │
│  │  - 接收: 原始计划 + 所有真实证据           │  │
│  │  - 综合推理，生成最终答案                   │  │
│  │  - 提示中包含谨慎指令（证据可能有噪声）     │  │
│  │  - 被指示引用特定证据ID以增加可信度         │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
                    ↓
               [最终答案]
```

### 2.2 Planner（规划器）— 详细设计

Planner是ReWOO的智能核心。它需要在**看不到任何工具输出的情况下**预测完整的解决方案路径。

**输入：**
- 用户问题/任务描述
- 可用工具列表（名称 + 描述）
- 可选的Few-shot示例（展示Plan → #E的格式）

**输出格式：**
```
Plan: <自由文本推理——为什么需要这个信息检索步骤>
#E1 = ToolName[argument1, argument2, ...]

Plan: <下一步推理——基于假设E1的内容，需要什么额外信息>
#E2 = ToolName[argument_with_E1_ref, ...]

Plan: <后续推理...>
#E3 = ToolName[arguments_with_refs...]

#E4 = ToolName[arguments...]
```

**设计原则：**

1. **Plan文本是推理链**
   每个Plan段落解释了为什么需要该步骤。Plan文本本身构成了一个虚拟的推理链——它假设了#E变量包含的内容，并基于该假设推进推理。这种"假设性推理"使Plan序列形成逻辑连贯的叙事：
   ```
   Plan: 首先需要找到《盗梦空间》的导演信息
   #E1 = Wikipedia[Inception]

   Plan: 然后需要《星际穿越》的导演信息进行对比
   #E2 = Wikipedia[Interstellar]

   Plan: 现在比较E1和E2中的导演信息，判断是否为同一人
   ```

2. **变量占位符#Ex是延迟绑定的**
   #E1、#E2在Planner输出时是空占位符，在执行时才被实际工具输出填充。这使得Planner可以在不知道工具输出的情况下"引用"它们——就像编程中的变量声明（声明但未赋值）。

3. **Plan中的引用是"假设性思考"**
   当Plan文本说"根据E1中的导演信息"时，Planner并不知道#E1的实际内容——它在进行假设性推理。这种能力依赖于LLM的世界知识：LLM"知道"Wikipedia搜索通常会返回导演信息，因此可以合理地基于这个假设规划后续步骤。

4. **工具调用参数可以引用先前的#Ex**
   ```
   #E1 = Search[Microsoft market cap]
   #E2 = Search[Apple market cap]
   #E3 = Calculator[#E1 / #E2]  ← 引用E1和E2的数值输出
   ```
   这在概念上与LLMCompiler的\${N}引用相同，但ReWOO的Worker不构建DAG——它只是顺序执行并做朴素的字符串替换。

**Few-Shot设计的要点：**

```python
PLANNER_FEW_SHOT = """
示例1:
问题: Tesla的CEO和SpaceX的CEO是同一个人吗？

Plan: 首先查询Tesla的CEO是谁
#E1 = Wikipedia[Tesla CEO]

Plan: 然后查询SpaceX的CEO是谁
#E2 = Wikipedia[SpaceX CEO]

Plan: 比较E1和E2的信息，判断CEO是否为同一人

---

示例2:
问题: 2025年全球GDP最高的三个国家的GDP总和是多少？

Plan: 搜索2025年全球GDP排名
#E1 = Search[2025 global GDP ranking by country]

Plan: 从E1中提取排名前三国家的GDP数值
#E2 = LLM[Extract top 3 GDP values from E1]

Plan: 计算三个GDP数值的总和
#E3 = Calculator[sum of values from E2]

---

示例3:
问题: Python和JavaScript中异步编程的主要区别是什么？

Plan: 搜索Python异步编程的核心机制（asyncio）
#E1 = Search[Python asyncio async programming overview]

Plan: 搜索JavaScript异步编程的核心机制（Promise/async-await）
#E2 = Search[JavaScript Promise async await overview]

Plan: 搜索两种语言异步模型的对比分析
#E3 = Search[Python vs JavaScript async programming comparison]
"""
```

**Planner提示词模板：**
```
你是一个任务规划专家。你需要为以下问题制定完整的信息检索计划。

规则：
1. 每步以"Plan:"开头，描述该步的推理逻辑
2. 接着用#E{编号} = 工具名[参数] 指定工具调用
3. 工具调用可以引用之前的#E变量
4. 输出所有必要的步骤，一次性完成规划
5. 不需要等待任何工具结果——基于你的世界知识预测需要什么信息

可用工具：
- Search[query]: 搜索网络信息
- Wikipedia[topic]: 查询维基百科
- Calculator[expression]: 执行数学计算
- LLM[instruction]: 调用LLM进行推理或提取

问题: {user_question}

请生成完整的执行计划:
```

### 2.3 Worker（执行器）— 详细设计

Worker是ReWOO中**唯一没有LLM调用的组件**。它的全部工作就是：
1. 解析Planner的输出
2. 逐行执行工具调用
3. 将工具输出替换到对应的#Ex占位符

```python
import re
from typing import Dict, List, Tuple

class ReWOOWorker:
    def __init__(self, tool_registry: dict):
        """
        tool_registry: {"Search": search_function, "Wikipedia": wiki_function, ...}
        """
        self.tools = tool_registry
        self.evidence_store: Dict[str, str] = {}

    def execute(self, plan_text: str) -> Tuple[List[str], Dict[str, str]]:
        """
        执行Planner的完整计划。
        返回: (plan_lines, evidence_store)
        """
        lines = plan_text.strip().split('\n')
        plan_lines = []  # 保留所有Plan:行供Solver使用

        for line in lines:
            line = line.strip()
            if not line:
                continue

            if line.startswith('Plan:'):
                # 推理行：直接保留
                plan_lines.append(line)

            elif line.startswith('#E'):
                # 工具调用行：执行并替换
                # 格式: #E1 = ToolName[arg1, arg2, ...]
                match = re.match(
                    r'(#E\d+)\s*=\s*(\w+)\s*\[(.*)\]', line
                )
                if match:
                    ev_id = match.group(1)    # '#E1'
                    tool_name = match.group(2) # 'Search'
                    args_str = match.group(3)  # 'query text'

                    # 解析参数（替换已有的#Ex引用）
                    args = self._resolve_args(args_str)

                    # 执行工具调用
                    tool = self.tools.get(tool_name)
                    if tool:
                        try:
                            result = tool(**args)
                            result_str = self._format_result(result)
                        except Exception as e:
                            result_str = f"[Error: {str(e)}]"
                    else:
                        result_str = f"[Tool '{tool_name}' not found]"

                    # 存储证据
                    self.evidence_store[ev_id] = result_str

                    # 将#Ex替换为实际结果
                    line = f"{ev_id} = {result_str}"

                plan_lines.append(line)

        return plan_lines, self.evidence_store

    def _resolve_args(self, args_str: str) -> dict:
        """解析参数字符串，替换其中的#Ex引用"""
        args = {}
        if not args_str.strip():
            return args

        # 简单实现：假设参数是逗号分隔的key=value
        # 更完整的实现可能需要解析引号、嵌套结构等
        current_key = None
        current_value = []

        for part in args_str.split(','):
            part = part.strip()
            if '=' in part and not part.startswith('#'):
                # 新的key=value
                if current_key:
                    args[current_key] = self._sub_evidence(
                        ','.join(current_value).strip()
                    )
                key, val = part.split('=', 1)
                current_key = key.strip()
                current_value = [val.strip()]
            else:
                current_value.append(part)

        if current_key:
            args[current_key] = self._sub_evidence(
                ','.join(current_value).strip()
            )

        return args

    def _sub_evidence(self, text: str) -> str:
        """将文本中的#Ex引用替换为已存储的证据"""
        def replacer(match):
            ev_id = match.group(0)
            return self.evidence_store.get(ev_id, ev_id)
        return re.sub(r'#E\d+', replacer, text)

    def _format_result(self, result) -> str:
        """将工具输出格式化为文本"""
        if isinstance(result, str):
            return result
        elif isinstance(result, (int, float)):
            return str(result)
        elif isinstance(result, dict):
            # 提取最关键的值
            return str(result.get('answer', result.get('result', str(result))))
        else:
            return str(result)
```

**Worker的关键特性：**

1. **零LLM开销**：Worker不进行任何LLM调用，所有操作都是确定性的字符串解析和替换
2. **顺序执行**：ReWOO Worker按Planner输出的顺序逐行执行（与LLMCompiler的DAG并行调度不同）
3. **失败不回退**：如果某个工具调用失败，Worker将错误信息作为#Ex的值继续执行——不像ReAct会看到错误并调整策略
4. **不验证输出质量**：Worker不做质量检查，直接将工具输出存入证据库

### 2.4 Solver（求解器）— 详细设计

Solver是ReWOO的"法官"——综合所有Plan文本和实际证据，产生最终答案。

**输入：**
- 原始用户问题
- 完整的Plan序列（包含所有Plan:行的推理文本）
- 所有#Ex的实际值（工具输出）

**Solver的提示词设计：**

```python
SOLVER_PROMPT_TEMPLATE = """你是一个信息综合专家。你的任务是基于收集的证据回答用户的问题。

用户问题: {question}

以下是为了回答该问题所执行的计划和收集的证据:

{plan_and_evidence}

请综合以上所有信息，生成准确、全面的最终答案。

重要规则:
1. 基于证据回答问题，引用具体的证据编号（如"根据#E1..."）
2. 如果证据中有矛盾，指出矛盾并给出最合理的结论
3. 如果关键证据缺失或不可靠，诚实说明
4. 如果证据充分，提供清晰、结构化的答案
5. 如果Plan中的推理与证据不符（Plan假设某些信息但证据不同），以证据为准

最终答案:"""

def build_solver_input(question: str, plan_lines: List[str],
                       evidence: Dict[str, str]) -> str:
    """构建Solver的输入"""
    plan_and_evidence = '\n'.join(plan_lines)

    # 在Plan的每行后面追加实际证据（如果该行有#Ex）
    for ev_id, ev_value in evidence.items():
        # 在plan_and_evidence中，#Ex应该已经被替换
        # 这里确保证据可见
        plan_and_evidence += f"\n\n{ev_id} 的实际值:\n{ev_value[:500]}"  # 截断长文本

    return SOLVER_PROMPT_TEMPLATE.format(
        question=question,
        plan_and_evidence=plan_and_evidence
    )
```

**Solver的推理能力需求：**
- 区分可靠和不可靠的证据
- 识别证据与Plan假设之间的不一致
- 综合多个独立来源的信息
- 在证据不足时适度保守

**Solver的输出策略：**
- 事实问题：直接引用证据给出答案
- 分析问题：基于证据进行推理分析
- 比较问题：并排引用证据进行比较
- 证据不足：诚实说"现有证据不足以回答，需要[具体信息]"

## 第三章：执行示例深度解析

### 3.1 HotpotQA多跳问答

**问题：** "《盗梦空间》的导演与《记忆碎片》的导演是同一个人吗？这两部电影中哪一部获得的奥斯卡提名更多？"

**Step 1 — Planner输出（1次LLM调用）：**
```
Plan: 首先需要查《盗梦空间》的导演信息
#E1 = Wikipedia[Inception film]

Plan: 然后查《记忆碎片》的导演信息
#E2 = Wikipedia[Memento film]

Plan: 比较E1和E2中的导演信息，判断是否为同一人

Plan: 查询《盗梦空间》获得的奥斯卡提名数量
#E3 = Search[Inception Oscar nominations count]

Plan: 查询《记忆碎片》获得的奥斯卡提名数量
#E4 = Search[Memento Oscar nominations count]

Plan: 比较E3和E4的提名数量，判断哪部更多
```

**Step 2 — Worker执行（0次LLM调用）：**
```
执行 #E1 = Wikipedia[Inception film]
→ 返回: "Director: Christopher Nolan... Academy Awards: 8 nominations..."

替换 #E1 = "Director: Christopher Nolan..."

执行 #E2 = Wikipedia[Memento film]
→ 返回: "Director: Christopher Nolan... Academy Awards: 2 nominations..."

替换 #E2 = "Director: Christopher Nolan..."

执行 #E3 = Search[Inception Oscar nominations count]
→ 返回: "8 nominations including Best Picture"

替换 #E3 = "8 nominations including Best Picture"

执行 #E4 = Search[Memento Oscar nominations count]
→ 返回: "2 nominations including Best Original Screenplay"

替换 #E4 = "2 nominations including Best Original Screenplay"
```

**Step 3 — Solver综合（第2次LLM调用）：**
```
输入: 问题 + Plan文本 + 所有证据
输出: "是的，《盗梦空间》和《记忆碎片》的导演都是Christopher Nolan，
      他们是同一位导演。在奥斯卡提名方面，《盗梦空间》获得8项提名
      （根据#E3），而《记忆碎片》获得2项提名（根据#E4），因此
      《盗梦空间》获得的奥斯卡提名更多。"
```

**Token对比分析：**
```
ReAct方式（假设5步，每步3200 token上下文）:
  第1步: 3200 tokens
  第2步: 4200 tokens (包含步骤1的1000 token历史)
  第3步: 5200 tokens
  第4步: 6200 tokens
  第5步: 7200 tokens
  总计: ~26,000 tokens

ReWOO方式:
  Planner: ~1,500 tokens (问题+提示+输出)
  Solver: ~1,200 tokens (问题+Plan+证据+输出)
  总计: ~2,700 tokens

节省: ~89% Token消耗
```

### 3.2 复杂数学问题

**问题：** "一个圆柱体容器，底面半径5cm，高20cm。装满水后倒出一个底面半径3cm、高10cm的圆锥体容器中的水量。问容器中还剩多少水？（π取3.14）"

**Planner输出：**
```
Plan: 计算圆柱体的体积 V_cylinder = π × r² × h
#E1 = Calculator[3.14 * 5^2 * 20]

Plan: 计算圆锥体的体积 V_cone = (1/3) × π × r² × h
#E2 = Calculator[(1/3) * 3.14 * 3^2 * 10]

Plan: 计算剩余水量 V_remaining = V_cylinder - V_cone
#E3 = Calculator[#E1 - #E2]
```

Worker依次执行3个计算器调用（都是简单的算术），Solver综合输出最终答案。整个过程仅2次LLM调用，而传统方法可能需要LLM在每个计算步骤之间进行推理。

### 3.3 批量文档处理

**问题：** "分析以下5家公司的2025年Q1财报，找出营收增长率最高的公司，总结其增长驱动因素。"

**Planner输出：**
```
Plan: 搜索Apple 2025 Q1财报
#E1 = Search[Apple 2025 Q1 earnings report revenue growth]

Plan: 搜索Microsoft 2025 Q1财报
#E2 = Search[Microsoft 2025 Q1 earnings report revenue growth]

Plan: 搜索Google 2025 Q1财报
#E3 = Search[Alphabet Google 2025 Q1 earnings report revenue growth]

Plan: 搜索Amazon 2025 Q1财报
#E4 = Search[Amazon 2025 Q1 earnings report revenue growth]

Plan: 搜索Nvidia 2025 Q1财报
#E5 = Search[Nvidia 2025 Q1 earnings report revenue growth]

Plan: 从E1-E5中提取每家公司的营收增长率
#E6 = LLM[Extract revenue growth rates from #E1, #E2, #E3, #E4, #E5]

Plan: 确定增长率最高的公司，分析增长驱动因素
#E7 = LLM[Analyze growth drivers for top performer from #E6]
```

注意：这个例子中，#E6和#E7使用了"LLM"作为工具——这表示在Worker阶段也可以嵌套LLM调用来处理中间推理（如提取和比较）。但关键是这些LLM调用发生在Worker阶段，而不是每次工具调用之间。

## 第四章：知识蒸馏——25倍参数缩减

### 4.1 蒸馏流程

这是ReWOO论文最具突破性的贡献。它证明了一个7B参数的小模型可以匹配175B参数GPT-3.5在Planning任务上的性能。

**阶段1 — 教师模型生成训练数据：**
```
工具: GPT-3.5 (175B)
任务: 在HotpotQA + TriviaQA训练集上
  - 对每个问题生成 (Plan, #E) 蓝图
  - 生成约4,000个蓝图
  - 每个蓝图包含完整的Plan序列和#Ex工具调用
```

**阶段2 — 数据过滤：**
```
- 执行每个蓝图的Worker阶段（实际工具调用）
- 仅保留导致正确答案的蓝图
- 过滤后得到约2,000个高质量 (问题, Plan蓝图, 答案) 三元组
```

**阶段3 — 学生模型训练：**
```
模型: Alpaca 7B (LLaMA 7B在52K Self-Instruct数据上微调)
训练数据: 2,000个蒸馏后的 (问题 → Plan蓝图) 对
训练方式: 标准监督微调（SFT, Supervised Fine-Tuning）
任务: 给定问题 → 生成完整Plan蓝图
```

**阶段4 — 评估：**
```
结果: 蒸馏后的7B Planner + GPT-3.5 Solver
  → 匹配甚至超过原始GPT-3.5 (175B) Planner + Solver的性能
```

### 4.2 为什么蒸馏能成功？

1. **Planner的输入空间受限**
   Planner只需要接收问题+工具列表，输出固定的格式化文本。这比开放域对话的训练目标明确得多。

2. **解耦设计的优势**
   Planner不需要处理工具输出——它的输入只是一段文本（问题），输出是另一段文本（计划）。这使得训练数据非常"干净"，没有复杂的交互轨迹。

3. **答案驱动的数据过滤**
   只保留导致正确答案的蓝图，相当于用人造"奖励信号"做数据筛选。学生模型学到的是"哪些计划模式倾向于成功"。

4. **小模型足够的规划能力**
   生成"先搜A再搜B然后比较"这种结构化计划不需要175B参数的世界知识。7B参数模型通过训练可以学会这类"元推理"模式。

### 4.3 蒸馏的影响

这个结果的意义远超ReWOO论文本身：
- **成本民主化**：7B模型可在消费级GPU上运行，使复杂Agent推理不再是大公司的专利
- **隐私保障**：Planner可在本地执行，敏感问题不需要发送到云端
- **延迟改善**：本地7B推理延迟<100ms，vs 云端API的500ms-2s
- **Agent-on-Device**：直接在手机上运行Agent规划成为现实

## 第五章：工具失败鲁棒性

### 5.1 实验设置

论文设计了一个关键的鲁棒性实验：
- 所有工具调用被强制返回 "No evidence found"（模拟搜索结果全空的最坏情况）
- 对比ReAct和ReWOO在这类失败场景下的表现

### 5.2 结果与分析

**ReAct在工具失败时的行为：**
```
Step 1: search(query) → "No evidence found"
Step 2 (LLM收到失败消息): "搜索结果为空，我需要换一个搜索词"
         → search(different_query) → "No evidence found"
Step 3 (LLM再次收到失败消息): "还是没找到，再试另一种方式"
         → search(yet_another_query) → "No evidence found"
Step 4: → 可能进入无限循环或给出"我无法找到信息"的回复

问题: 每次失败的观察（"No evidence found"）进入LLM上下文后，
      扰乱下一步推理。LLM倾向于"再试一次"而非承认失败。
      每个失败步骤推高Token消耗，形成恶性循环。
```

**ReWOO在工具失败时的行为：**
```
Planner一次性生成所有步骤（未看到任何工具输出）:
  #E1 = Search[query1]  → Worker执行 → "No evidence found"
  #E2 = Search[query2]  → Worker执行 → "No evidence found"
  #E3 = Search[query3]  → Worker执行 → "No evidence found"

Solver接收:
  问题 + Plan（包含Planner的逻辑推理文本） + 所有#Ex = "No evidence found"

Solver推理:
  "所有搜索都没有返回有用信息。基于Plan中的推理框架，
   我可以在自己的参数知识基础上尝试回答这个问题。
   Plan中的推理表明这个问题涉及[领域X]，据我所知..."
```

**关键区别：**
- ReAct的LLM在每步看到失败后可能陷入"重试陷阱"
- ReWOO的Solver一次性看到所有失败，做出理性的整体判断
- ReWOO的Plan文本仍然提供了逻辑框架，即使证据缺失，推理结构仍然存在
- Solver可以退回到LLM的参数知识（LLM自身训练中存储的知识）

### 5.3 定量结果

在工具100%失败率的最极端条件下：
- ReAct：性能严重退化，经常进入无效重试循环
- ReWOO：保持相对鲁棒（下降<10%），Solver在Plan结构上推理并退回到参数知识

这个结果对生产环境至关重要——在工具可用性不稳定的环境中（如网络问题、API限流），ReWOO提供了更好的降级体验。

## 第六章：ReWOO vs 其他范式

### 6.1 完整对比表

| 维度 | ReAct | ReWOO | LLMCompiler | Plan-Execute |
|------|-------|-------|-------------|-------------|
| LLM调用次数 | N+1 (N=工具数) | **恰好2次** | 2-4次 | 3-10次 |
| Token复杂度 | O(N²) | **O(1)** | O(1) | 中 |
| 工具执行模式 | 交替：推理→行动→观察→... | 批量：规划→全执行→综合 | DAG调度：并行 | 分阶段：规划→执行 |
| 中间LLM在环路 | 每步都在 | 不在 | 不在 | 可选（Replanner） |
| 并行执行 | 不支持 | 不支持（顺序Worker） | **最佳** | 中-高 |
| 知识蒸馏 | 困难（需完整轨迹） | **最容易** | 中 | 中 |
| 工具失败鲁棒性 | 中 | **高** | 中-高（Replan） | 中-高 |
| 实现复杂度 | 中 | **最低** | 中 | 中-高 |
| 探索性任务 | **最适合** | 不适合 | 中 | 中 |
| 结构化任务 | 中 | **最适合** | 最适合 | 最适合 |

### 6.2 ReWOO vs LLMCompiler

两者都追求效率，但侧重点不同：

| 维度 | ReWOO | LLMCompiler |
|------|-------|-------------|
| 核心理念 | 最小化LLM参与 | 最大化工具并行 |
| LLM调用 | 2次（极致） | 2-4次（含Replan） |
| 工具执行 | 顺序 | 并行DAG |
| 依赖建模 | 隐式（Planner推理中） | 显式（DAG边） |
| 复杂依赖处理 | 弱（Worker顺序执行） | 强（拓扑调度） |
| 代码复杂度 | 简单（~200行） | 中等（~500行） |

**选择建议：**
- 工具调用之间依赖简单或线性 → ReWOO（更简单，Token更省）
- 工具调用之间依赖复杂或可高度并行 → LLMCompiler（更快，虽然实现更复杂）

## 第七章：实现指南

### 7.1 LangGraph完整实现

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, List, Dict, Any
import re

class ReWOOState(TypedDict):
    task: str
    plan_string: str        # Planner的原始输出
    plan_lines: List[str]   # 解析后的行序列
    steps: List[dict]       # [(plan_text, ev_id, tool, args), ...]
    results: Dict[str, str] # {#E1: result_string, #E2: ...}
    final_answer: str

# ── Planner ──
def planner(state: ReWOOState) -> dict:
    prompt = f"""你是一个任务规划专家。为用户问题生成完整的信息检索计划。

可用工具:
- Search[query]: 搜索网络信息
- Wikipedia[topic]: 查询维基百科
- Calculator[expression]: 数学计算
- LLM[instruction]: 调用LLM进行子任务处理

格式要求:
- 每步以Plan:开头，描述推理逻辑
- 工具调用格式: #E{{编号}} = 工具名[参数]
- 可以引用之前的#Ex作为参数
- 一次性输出所有步骤

用户问题: {state['task']}

请生成完整计划:"""

    plan_string = llm.invoke(prompt)
    steps = parse_plan_to_steps(plan_string)
    return {
        "plan_string": plan_string,
        "steps": steps,
        "results": {}
    }

def parse_plan_to_steps(plan_string: str) -> List[dict]:
    """解析Planner输出为结构化步骤列表"""
    steps = []
    current_plan = ""

    pattern = r'(#E\d+)\s*=\s*(\w+)\s*\[([^\]]*)\]'

    for line in plan_string.strip().split('\n'):
        line = line.strip()
        if not line:
            continue

        if line.startswith('Plan:'):
            current_plan = line
        elif re.match(pattern, line):
            match = re.match(pattern, line)
            steps.append({
                'plan': current_plan,
                'ev_id': match.group(1),
                'tool': match.group(2),
                'args_str': match.group(3),
            })

    return steps

# ── Worker ──
def worker_execute(state: ReWOOState) -> dict:
    """顺序执行所有工具调用"""
    results = {}

    for step in state['steps']:
        ev_id = step['ev_id']
        tool_name = step['tool']
        args_str = step['args_str']

        # 替换参数中的#Ex引用
        for prev_ev in results:
            args_str = args_str.replace(prev_ev, results[prev_ev])

        # 执行工具
        tool = tool_registry.get(tool_name)
        if tool:
            try:
                result = tool(args_str)
                results[ev_id] = str(result)
            except Exception as e:
                results[ev_id] = f"[Error executing {tool_name}: {e}]"
        else:
            results[ev_id] = f"[Unknown tool: {tool_name}]"

    return {"results": results}

# ── Solver ──
def solver(state: ReWOOState) -> dict:
    # 构建包含证据的完整计划文本
    plan_with_evidence = state['plan_string']

    for ev_id, result in state['results'].items():
        # 将#Ex替换为实际结果
        plan_with_evidence = plan_with_evidence.replace(
            f"{ev_id} =", f"{ev_id} = {result[:200]}  #"
        )

    prompt = f"""基于以下计划和收集的证据回答问题。

用户问题: {state['task']}

收集的计划和证据:
{plan_with_evidence}

请综合所有信息给出最终答案。引用具体证据。"""

    final_answer = llm.invoke(prompt)
    return {"final_answer": final_answer}

# ── 构建图 ──
graph = StateGraph(ReWOOState)
graph.add_node("planner", planner)
graph.add_node("worker", worker_execute)
graph.add_node("solver", solver)

graph.add_edge(START, "planner")
graph.add_edge("planner", "worker")
graph.add_edge("worker", "solver")
graph.add_edge("solver", END)

app = graph.compile()
```

### 7.2 核心解析正则详解

```python
# ReWOO的核心解析正则——匹配 #E{数字} = 工具名[参数]
PLAN_PATTERN = re.compile(
    r'(Plan:\s*.+)'          +  # 捕获组1: Plan文本
    r'\s*'                   +
    r'(#E\d+)'               +  # 捕获组2: 证据变量名
    r'\s*=\s*'               +
    r'(\w+)'                 +  # 捕获组3: 工具名
    r'\s*\[([^\]]*)\]'       ,  # 捕获组4: 参数字符串（不包含]）
    re.VERBOSE
)

# Compiled for production use
import re
PLAN_REGEX = re.compile(PLAN_PATTERN, re.VERBOSE)

# 提取#Ex引用的正则
EVIDENCE_REF_PATTERN = r'#E\d+'

# 示例解析
example = "Plan: 搜索电影信息\n#E1 = Search[Inception director]"
match = PLAN_REGEX.match(example)
# match.group(1): "Plan: 搜索电影信息"
# match.group(2): "#E1"
# match.group(3): "Search"
# match.group(4): "Inception director"
```

## 第八章：何时使用ReWOO —— 决策指南

### 8.1 最佳场景

**1. 结构化信息检索任务**
- 事实问答（"X的Y是什么？"）
- 多跳问答（HotpotQA风格——需要多个信息来源）
- 比较分析（"比较A和B的C"）
- 属性查询流水线

**2. Token预算极度敏感**
- 大规模部署（月调用百万次）
- 边缘设备（上下文窗口有限）
- 使用昂贵模型（如GPT-4/Opus作为LLM骨干）

**3. 需要从大模型蒸馏小模型**
- Planner和Solver可以独立蒸馏
- 7B参数匹配175B性能的潜力
- 隐私保护（规划在本地执行）

**4. 工具可用性不稳定的环境**
- 有频繁网络中断的移动环境
- API速率限制严格的生产环境
- 需要优雅降级的面向用户应用

**5. 清晰的批处理管道**
- 合规文档检查
- 信息提取管道
- 批量内容审核

### 8.2 不适合的场景

**1. 高度探索性的任务**
- 代码调试（错误信息决定下一步查什么）
- 交互式数据探索（可视化结果决定下一步分析方向）
- 开放式研究（研究发现改变后续方向）

**2. 需要动态决策的任务**
- 实时策略调整
- 条件分支密集的任务
- 需要人机交互确认的流程

**3. 复杂依赖关系**
- 多层嵌套的依赖（如果#E3依赖#E2，#E2依赖#E1的具体内容）
- 需要并行执行工具加速的任务（LLMCompiler更适合）

**4. 初始计划可能完全错误的任务**
- 对领域一无所知（无法预判需要什么信息）
- 任务描述极其模糊

### 8.3 决策检查清单

```
□ 所有必要的工具调用可以在执行前预测吗？（>80%可以 → ReWOO）
□ 工具调用的参数不严重依赖之前工具的具体输出内容吗？
□ 有10个以上的独立信息检索需要执行吗？
□ Token成本是你的主要考量吗？
□ 你需要将模型蒸馏到更小的规模吗？
□ 工具偶尔会失败但你需要系统保持鲁棒吗？

如果3个或以上答"是" → ReWOO非常适合
如果少于2个答"是" → 考虑ReAct（灵活）或LLMCompiler（并行）
```

> ReWOO代表了Agent效率的极致追求——用2次LLM调用完成可能需要数十次调用的任务。虽然不是所有任务都适合"一次规划、批量执行"的模式，但对于结构化信息检索和大规模部署场景，ReWOO提供了5倍+的Token节省和更好的工具失败鲁棒性。知识蒸馏（175B → 7B保持性能）的结果证明了这种推理与执行解耦设计的深远价值——它不仅让Agent更快更省，还让Agent能力民主化到可以在本地设备上运行。
''';
