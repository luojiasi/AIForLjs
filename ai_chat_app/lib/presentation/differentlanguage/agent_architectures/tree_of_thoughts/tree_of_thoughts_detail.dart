/// Tree of Thoughts — 完整详解
const String treeOfThoughtsFullDetail = '''

# 思维树 (Tree of Thoughts / ToT) - 完整详解

## 第一章：论文深度解读

### 1.1 论文信息
- **标题:** Tree of Thoughts: Deliberate Problem Solving with Large Language Models
- **作者:** Shunyu Yao, Dian Yu, Jeffrey Zhao, Izhak Shafran, Thomas L. Griffiths, Yuan Cao, Karthik Narasimhan
- **发表:** NeurIPS 2023 (Oral Presentation —— 接收率<1.5%的顶级论文)
- **arXiv:** 2305.10601
- **代码:** github.com/princeton-nlp/tree-of-thought-llm
- **作者背景:** Princeton NLP Group + Google DeepMind

### 1.2 从链到树：认知科学视角

ToT的灵感来自人类问题解决的双过程理论（Dual-Process Theory）：

**系统1（快思维）：** 直觉、自动、线性——对应标准CoT的贪婪解码（一次生成一条链，不回头）
**系统2（慢思维）：** 深思熟虑、需要努力、探索分支——对应ToT的多路径探索和评估

人类解决复杂问题（如24点游戏、填字游戏、数学证明）时，不会沿着第一条思路一直走下去。我们会在心中尝试多种可能，评估哪个方向最有前景，必要时回溯到之前的决策点重新选择。ToT将这种"深思熟虑的搜索"赋予了LLM。

**类比：**
- CoT = 直行者——选定一条路走到黑，不回头不探索
- CoT-SC（Self-Consistency）= 多个直行者——各走各的，最后投票选最优路
- ToT = 探险家——在每个分岔口尝试多个方向，评估前景，只深入最有希望的分支，必要时回溯

### 1.3 四个可替换组件

ToT的优雅之处在于它将树搜索分解为四个独立的、可替换的组件。这为不同任务定制搜索策略提供了极大的灵活性。

**组件1：思维分解（Thought Decomposition）**

将复杂问题的中间推理分解为"思维"——语义上有意义、可以独立评估的推理单元。

设计原则：
- 思维必须**足够小**以使LLM能够生成多样化的候选（粒度太粗→生成僵化）
- 思维必须**足够大**以使LLM能够有意义地评估其前景（粒度太细→评估噪声太大）
- 不同任务有天然不同的思维粒度

| 任务 | 思维粒度 | 为什么这样设计？ |
|------|---------|----------------|
| Game of 24 | 一个公式步骤（如"13-9=4"，剩余[4,4,10]） | 每步明确、不可再分 |
| Creative Writing | 段落级写作计划 | 太细（句子级）失去整体结构感 |
| Mini Crosswords | 单个单词填写 + 置信度 | 每格是自然决策单元 |

**组件2：思维生成器 G(p_θ, s, k)**

从状态s生成k个候选下一步思维。

两种生成策略：

**Sample（独立采样）：**
```python
def generate_thoughts_sample(state, k, temperature=0.7):
    """每次独立采样的CoT生成"""
    thoughts = []
    for _ in range(k):
        thought = llm.generate(
            prompt=build_prompt(state),
            temperature=temperature,  # 高温度增加多样性
            max_tokens=100
        )
        thoughts.append(thought)
    return thoughts
```
适用于：丰富的、开放的思维空间（如Creative Writing），多样性很重要。
每个思维是独立采样的CoT提示。

**Propose（顺序提案）：**
```python
def generate_thoughts_propose(state, k):
    """单次调用顺序生成k个不同思维"""
    prompt = f"""当前状态: {state}
请提出{k}个不同的下一步操作。每个操作应该是独特且合理的。

1. """
    response = llm.generate(prompt, temperature=0.3)  # 低温度确保一致性
    # 解析response中的k个步骤
    thoughts = parse_numbered_list(response)
    return thoughts[:k]
```
适用于：受限空间（Game of 24, Crosswords），需要避免重复。
单次调用中按顺序产生k个不同思维——LLM被训练为"已经生成了1和2，现在生成一个不同的3"。

**组件3：状态评估器 V(p_θ, S)**

LLM自身作为启发式评估器。两种评估方法：

**独立评分（Value）：**
```python
def evaluate_state_value(state, n_samples=3):
    """对单个状态独立评分，多次采样聚合"""
    scores = []
    for _ in range(n_samples):
        prompt = f"""评估以下中间状态的质量和完成前景。

状态: {state}
评价标准: 是否朝着最终目标前进？推理是否合理？

请给出1-10的评分（10=最佳），并简要说明理由。
评分: """
        response = llm.generate(prompt, temperature=0.1)
        score = extract_score(response)
        scores.append(score)

    # 聚合：多数投票或平均
    return statistics.mode(scores)  # 或 mean(scores)
```

**比较投票（Vote）：**
```python
def evaluate_states_vote(states, n_samples=5):
    """并排比较多个状态，选择最佳"""
    prompt = f"""请比较以下{len(states)}个候选状态，选择最有前景的一个。

候选状态:
{format_states_for_comparison(states)}

请选择最佳状态并说明理由。
最佳状态编号: """

    votes = collections.Counter()
    for _ in range(n_samples):
        response = llm.generate(prompt, temperature=0.2)
        best_idx = extract_choice(response)
        votes[best_idx] += 1

    return votes.most_common(1)[0][0]  # 返回得票最多的状态
```

**两种评估方法的对比：**

| 维度 | 独立评分（Value） | 比较投票（Vote） |
|------|-----------------|-----------------|
| 评估方式 | 每个状态单独评分 | 状态之间并排比较 |
| 适用场景 | 状态很多，需要排名 | 状态较少（2-5个），需要选出最佳 |
| 一致性 | 中（绝对评分标准难一致） | 高（相对比较更一致） |
| 计算量 | n_samples × n_states | n_samples × 1（虽然输入包含多个状态） |
| 用于 | BFS的剪枝阶段 | DFS的回溯决策 |

**组件4：搜索算法**

BFS（广度优先搜索）或DFS（深度优先搜索）对状态树进行系统搜索。

选择BFS还是DFS取决于任务特征：

| 特征 | BFS更适合 | DFS更适合 |
|------|---------|---------|
| 分支因子 | 小（b≤3） | 大（b≥5） |
| 树深度 | 浅（d≤4） | 深（d≥5） |
| 正确路径密度 | 高（多条路径可达目标） | 低（需要深度探索） |
| 评估器准确度 | 低（需要比较多个同级状态） | 高（可以可靠剪枝） |
| 代表任务 | Game of 24 | Mini Crosswords |

## 第二章：BFS算法详解

### 2.1 Game of 24的完整BFS流程

**Game of 24规则：** 给定4个数字（如4, 9, 10, 13），用加减乘除运算得到24。每步选两个数，用运算符组合，得到一个中间结果，继续用剩下的数和中间结果运算。

**BFS搜索流程：**

```
初始化: S0 = {输入: "4,9,10,13"}

步骤1 (深度1):
  对S0中每个状态生成k=5个候选思维（一次Propose，避免重复）:
    候选1: "13-9=4" → 剩余: [4,10,4]     ← 因为4已存在
    候选2: "10-4=6" → 剩余: [6,9,13]
    候选3: "10-9=1" → 剩余: [1,4,13]
    候选4: "4+9=13" → 剩余: [13,10,13]
    候选5: "13-10=3" → 剩余: [3,4,9]

  评估每个状态（独立评分，每个3次采样）:
    候选1: 平均分 7.3 ← 最佳
    候选2: 平均分 5.0
    候选3: 平均分 4.0
    候选4: 平均分 6.7
    候选5: 平均分 3.3

  剪枝: b=3，保留前3:
    候选1: [4,10,4], 分数7.3
    候选4: [13,10,13], 分数6.7
    候选2: [6,9,13], 分数5.0

步骤2 (深度2):
  for 每个保留状态:
    候选1状态[4,10,4]:
      生成k=5个候选 → 评估 → 保留b=3
      最佳: "10-4=6" → [6,4] 分数8.0
      次佳: "4*4=16" → [16,10] 分数7.5
      第三: "10+4=14" → [14,4] 分数4.0

    候选4状态[13,10,13]:
      最佳: "13+13=26" → [26,10] 分数6.0
      ...

    候选2状态[6,9,13]:
      最佳: "13-6=7" → [7,9] 分数5.5
      ...

  剪枝: 从3×3=9个候选状态中保留b=3:
    [6,4] 分数8.0  ← 最高
    [16,10] 分数7.5
    [26,10] 分数6.0

步骤3 (深度3——最终步):
  for 每个保留状态:
    [6,4]:
      候选: "6*4=24" → [24] ← 达到目标! 分数10.0 ✓✓✓

  → 找到解: 13-9=4, 10-4=6, 6×4=24
```

**BFS的关键参数：**
- `k` (生成宽度): 每个状态生成的候选数（Game of 24: k=5）
- `b` (束宽度/剪枝宽度): 每步保留的状态数（Game of 24: b=5 最优）
- `n_evaluate_sample`: 每个状态的评分采样次数（默认3，多数/平均聚合）
- `T` (最大深度): Game of 24的步数固定为3（4个数→3次运算）

### 2.2 BFS的束搜索实现

```python
from typing import List, Tuple
import heapq

class ToTBFS:
    def __init__(self, llm, k_generate=5, beam_width=3,
                 max_depth=3, n_evaluate=3):
        self.llm = llm
        self.k = k_generate
        self.b = beam_width
        self.max_depth = max_depth
        self.n_eval = n_evaluate

    def search(self, problem: str) -> List[Tuple[str, float]]:
        """
        对问题执行BFS束搜索。
        返回: [(解路径, 分数), ...] 按分数降序排列
        """
        # 初始化: 根节点
        frontier = [ThoughtNode(state=problem, path=[], depth=0)]
        solutions = []

        for depth in range(1, self.max_depth + 1):
            candidates = []

            # 对前沿中的每个状态生成候选
            for node in frontier:
                if node.is_terminal():
                    solutions.append(node)
                    continue

                next_thoughts = self._generate(node.state, self.k)
                for thought_text in next_thoughts:
                    new_state = self._apply_thought(node.state, thought_text)
                    new_path = node.path + [thought_text]
                    candidates.append(
                        ThoughtNode(state=new_state, path=new_path, depth=depth)
                    )

            if not candidates:
                break  # 搜索停止

            # 评估所有候选
            for candidate in candidates:
                candidate.score = self._evaluate_state(
                    problem, candidate.state, self.n_eval
                )

            # 剪枝: 仅保留top-b
            frontier = sorted(candidates, key=lambda n: n.score, reverse=True)
            frontier = frontier[:self.b]

        # 收集结果
        solutions.extend(frontier)
        solutions = [s for s in solutions if s.is_valid_solution(problem)]
        return sorted(solutions, key=lambda s: s.score, reverse=True)

    def _generate(self, state: str, k: int) -> List[str]:
        """Propose模式: 一次调用生成k个候选思维"""
        prompt = f"""当前数字: {state}
请提出{k}个不同的运算步骤。每步选择一个运算符(+,-,*,/)和两个数字。

1. """
        response = self.llm.generate(prompt, temperature=0.3)
        return self._parse_k_thoughts(response, k)

    def _evaluate_state(self, problem: str, state: str, n: int) -> float:
        """独立评分: n次采样取平均值"""
        scores = []
        for _ in range(n):
            prompt = f"""目标: 用{problem}得到24。
当前进展: {state}
评估这个中间状态有多接近目标。1-10分。
评分: """
            score = float(self.llm.generate(prompt, temperature=0.1))
            scores.append(score)
        return sum(scores) / len(scores)

    def _apply_thought(self, state: str, thought: str) -> str:
        """执行思维: 更新状态（移除用掉的数，加入结果）"""
        # 解析thought中的运算（如"13-9=4"）
        # 从state中移除用到的数字，加入结果
        # 简化的实现
        return apply_arithmetic_step(state, thought)
```

### 2.3 束宽度的影响分析

Game of 24实验中b的消融分析揭示了关键的设计权衡：

| 束宽度b | 搜索节点数 | LLM调用次数 | 成功率 | 效率（成功率/调用数） |
|---------|----------|------------|--------|---------------------|
| b=1 | ~4 | ~15 | 45% | 3.0% |
| b=2 | ~12 | ~40 | 62% | 1.6% |
| b=3 | ~22 | ~70 | 68% | 0.97% |
| b=5 | ~62 | ~190 | **74%** | 0.39% |
| b=7 | ~110 | ~330 | 74% | 0.22% |

关键发现：
- b=1→b=5：成功率单调提升（45%→74%），证实了"探索宽度"的价值
- b=5→b=7：成功率收敛（74%→74%），说明束宽度已有冗余——更大的搜索不再带来更多正确解
- **最优束宽度b=5**在Game of 24上提供了成功率与计算成本的最佳平衡
- Self-Consistency + CoT在100个样本中的最佳成绩（49%）不如ToT b=1（45%）+ CoT样本最佳（49%） vs ToT b=5（74%）——结构化搜索即使使用更少的节点也远超随机采样

## 第三章：DFS算法详解

### 3.1 Mini Crosswords的DFS回溯搜索

Mini Crosswords（5×5填字游戏）与Game of 24的本质差异决定了DFS更适合：
- **更大的搜索空间**：每个位置可能的字母选择更多
- **更深的前瞻需求**：错误的早期选择可能在后来的步骤才暴露
- **回溯的必要性**：贪心前进容易陷入死胡同

**DFS+回溯算法：**

```python
class ToTDFS:
    def __init__(self, llm, k_generate=5, max_steps=100,
                 max_solutions=5):
        self.llm = llm
        self.k = k_generate
        self.max_steps = max_steps
        self.max_solutions = max_solutions

    def search(self, puzzle: str) -> List[str]:
        """
        对填字谜题进行DFS+回溯搜索。
        """
        solutions = []
        stack = []  # 使用栈实现DFS

        # 根节点: 空状态
        root = CrosswordState(grid={}, remaining_clues=puzzle)
        stack.append(root)

        steps = 0
        while stack and steps < self.max_steps:
            state = self._pop_best_unexplored(stack)

            # 深度检查
            if state.depth > 25:  # 5×5=25格
                continue

            # 评估当前状态
            evaluation = self._evaluate_state(state)
            state.evaluation = evaluation

            # 如果是"不可能"状态 → 剪枝（回溯）
            if evaluation.verdict == "impossible":
                continue

            # 如果是完整终端状态
            if state.is_complete():
                if state.is_valid_solution():
                    solutions.append(state.grid)
                    if len(solutions) >= self.max_solutions:
                        break
                continue

            # 生成k个候选下一步（为最空白的下一个位置填字）
            candidates = self._generate_candidates(state, self.k)

            # 按启发式分数排序，最有希望的先入栈
            candidates.sort(key=lambda c: c.heuristic_score, reverse=True)
            for candidate in candidates:
                stack.append(candidate)

            steps += 1

        return solutions

    def _evaluate_state(self, state) -> EvaluationResult:
        """评估填字状态的前景"""
        prompt = f"""当前填字进度:
{state.render_grid()}

剩余线索: {state.remaining_clues()}

评估这个状态：sure（确定可行）/ likely（可能可行）/ impossible（不可能）

评估及理由: """
        response = self.llm.generate(prompt, temperature=0.1)

        if "impossible" in response.lower():
            return EvaluationResult(verdict="impossible", confidence=0.9)
        elif "sure" in response.lower():
            return EvaluationResult(verdict="sure", confidence=0.8)
        else:
            return EvaluationResult(verdict="likely", confidence=0.5)

    def _pop_best_unexplored(self, stack: list):
        """从栈中弹出最有希望的未探索状态（启发式+深度加权）"""
        # 不是简单的LIFO——基于启发式+深度选择
        unexplored = [s for s in stack if not s.explored]
        if not unexplored:
            return None
        # 选择最有希望的（启发式分数×深度惩罚）
        best = max(unexplored,
                   key=lambda s: s.heuristic_score / (s.depth + 1))
        best.explored = True
        return best
```

### 3.2 回溯的必要性：消融实验

论文在Mini Crosswords上做了关键消融——移除了回溯能力（贪心DFS，类似BFS的b=1）：

| 配置 | 单词准确率 | 字母准确率 | 解出谜题数 |
|------|----------|----------|-----------|
| 贪心DFS（无回溯） | 20% | ~40% | 0/20 |
| **DFS+回溯** | **60%** | **78%** | **4/20 (20%)** |
| Oracle DFS（完美评估器） | — | — | 7/20 (35%) |

关键结论：
- 没有回溯 = 0个谜题被解出——贪心填字面对错误选择只能继续前进，必然失败
- 回溯使解出率从0%提升到20%——这是质的飞跃
- Oracle结果（7/20）表明评估器是上限瓶颈——如果评估器100%准确，可解出35%的谜题

### 3.3 剪枝权衡

```python
# 剪枝策略
def should_prune(state: CrosswordState) -> bool:
    """
    剪枝决策——需要在"探索宽度"和"计算效率"之间权衡
    """
    # 硬剪枝: 明确不可能的状态
    if state.has_violated_constraints():
        return True  # 违反填字约束（如横向词和纵向词同一位置字母矛盾）

    # 软剪枝: 评估判定为impossible
    eval_result = evaluate_state(state)
    if eval_result.verdict == "impossible" and eval_result.confidence > 0.8:
        return True  # LLM高置信度判定为不可行

    # 不剪枝: 可能浪费计算在死胡同
    # 剪枝过多: 可能错剪可行分支（评估器不完美）

    return False  # 保守策略：宁可多探索也不错剪
```

**剪枝的实证权衡：**
- 不剪枝：更多正确状态在搜索树中发现，但计算消耗大
- 积极剪枝：效率高但风险大——评估器可能剪去可行的分支
- 论文发现适度剪枝（保守阈值）在Mini Crosswords上最佳

## 第四章：实验与成果

### 4.1 Game of 24 — 完整结果表

对100个来自4nums.com的困难题目（人工解决平均耗时>2分钟）进行评估：

| 方法 | 成功率 | LLM调用预算 | vs CoT提升 |
|------|--------|------------|-----------|
| IO prompting (标准输入输出) | 7.3% | 1次/题 | — |
| Chain-of-Thought (CoT) | 4.0% | 1次/题 | — |
| CoT + Self-Consistency (k=100) | 9.0% | 100次/题 | +5.0% |
| **ToT BFS (b=1)** | **45%** | ~15次/题 | +41.0% |
| **ToT BFS (b=5)** | **74%** | ~190次/题 | **+70.0%** |
| IO oracle (100样本最佳) | 33% | 100次/题 | — |
| CoT oracle (100样本最佳) | 49% | 100次/题 | — |

**核心发现：**
1. CoT甚至不如标准IO prompting（4.0% vs 7.3%）——对于需要前瞻规划的数学问题，线性推理反而引入错误
2. Self-Consistency 100个样本最佳成绩（49% oracle）仍不如ToT b=1（45%）——结构化搜索以更少的总调用次数取得近似或更好的结果
3. ToT b=5（74%）远超最佳CoT oracle（49%）——不是采样数量的问题，而是搜索结构的问题
4. ToT的节点访问与成功率单调递增，而CoT/IO在100样本后饱和——搜索宽度确实在带来新信息

### 4.2 Mini Crosswords — 详细分析

20个GooBix 5×5迷你填字谜题的评估：

| 指标 | IO | CoT | ToT (DFS+b=5) |
|------|-----|------|---------------|
| 字母级准确率 | 38.8% | 40.6% | **78%** |
| 单词级准确率 | 14% | 15.6% | **60%** |
| 完整谜题解出 | 0/20 | 0/20 | **4/20 (20%)** |

**为什么Crosswords特别难？**
- 约束密集：每个字母同时属于横向和纵向两个单词
- 组合爆炸：5×5的格子有26^25种可能
- 需要前瞻：早期的选择可能到后期才被证明矛盾
- 回溯必不可少：无回溯方法无法解决任何谜题

### 4.3 Creative Writing — 质量评估

对于创意写作任务（撰写有特定约束的段落），ToT使用BFS b=1：

| 指标 | CoT基线 | ToT | 提升 |
|------|---------|-----|------|
| 连贯性评分 (1-10) | 6.2 | **7.8** | +26% |
| 约束满足率 | 45% | **82%** | +37% |

Creative Writing中的思维粒度是"段落计划"而非逐句生成——先规划大结构，再填充内容。这避免了在低层级细节上做不必要的搜索。

### 4.4 消融分析

**1. 生成策略 — Sample vs Propose**

| 任务 | 策略 | 结果 | 洞察 |
|------|------|------|------|
| Game of 24 | Sample | 冗余严重（许多重复/相似运算） | 受限空间不适合Sample |
| Game of 24 | **Propose** | 每次生成5个不同运算 | 受限空间适合Propose |
| Creative Writing | **Sample** | 提供丰富的多样性 | 开放空间适合Sample |
| Creative Writing | Propose | 生成僵化，缺乏多样性 | 开放空间不适合Propose |

**2. 评估策略 — Value vs Vote**

| 任务 | 策略 | 结果 | 洞察 |
|------|------|------|------|
| Game of 24 (b=5) | **Value** | 更准确的排名 | 多状态排名适合独立评分 |
| Mini Crosswords | **Vote** | 回溯时选择更有意义 | 决策点需要比较投票 |

**3. 搜索算法 — BFS vs DFS**

| 任务 | BFS | DFS | 原因 |
|------|-----|-----|------|
| Game of 24 | ✓ 最优 | 不适合（深度固定） | BFS层层剪枝更适合浅搜索 |
| Mini Crosswords | 不适合 | ✓ 最优 | DFS回溯更适合深搜索 |

## 第五章：Graph of Thoughts (GoT) 扩展

### 5.1 论文信息
- **标题:** Graph of Thoughts: Solving Elaborate Problems with Large Language Models
- **作者:** Maciej Besta, Nils Blach, Ales Kubicek, Robert Gerstenberger, Michal Podstawski, Lukas Gianinazzi, Joanna Gajda, Tomasz Lehmann, Hubert Niewiadomski, Piotr Nyczyk, Torsten Hoefler (ETH Zurich)
- **发表:** AAAI 2024
- **arXiv:** 2308.09687

### 5.2 从树到图

GoT将ToT从"树"推广到"任意有向图"：

| 范式 | 结构 | 每个思维的前驱数 | 关键能力 | 限制 |
|------|------|-----------------|---------|------|
| CoT | 线性链 | 1 | 简单逐步推理 | 无分支 |
| ToT | 树 | 1（仅一个父节点） | 分支探索+剪枝 | 无合并，无循环 |
| GoT | 任意有向图 | 任意多 | 聚合思维、反馈循环 | 复杂度更高 |

**为什么需要图？**
- 多个独立探索的分支可能产生互补的洞察——需要**合并**（Aggregation）
- 某个思维可能需要**增强**（Refinement）——反馈循环
- 整个子搜索树的精华需要被**提炼**（Distillation）

### 5.3 四种思维转换操作

**操作1: Generation（生成）**
```
输入: 一个或多个已有思维
输出: 一个新思维
→ 从已有的产生新思维（ToT已有的能力）
```

**操作2: Aggregation/Merging（聚合/合并）**
```
输入: 多个独立思维
输出: 一个综合思维，整合所有输入的最佳元素
→ GoT区别于ToT的标志性操作

示例（排序任务）:
  思维1: [3,7,1,5] → 排序结果1: [1,3,5,7]
  思维2: [2,8,4,6] → 排序结果2: [2,4,6,8]
  聚合: [1,3,5,7] + [2,4,6,8] → Merge → [1,2,3,4,5,6,7,8]
```

**操作3: Refinement（增强）**
```
输入: 一个思维
输出: 增强后的思维
→ 通过反馈循环改进。允许图中的循环（在有向无环的约束下需要特殊处理）

示例:
  初始思维: "使用冒泡排序"
  增强1: "使用归并排序（更快）"
  增强2: "使用快速排序（且已优化pivot选择）"
```

**操作4: Distillation（提炼）**
```
输入: 一个子图（多个思维+连接）
输出: 一个紧凑的提炼思维，包含子图的精华
→ 用于将大型子图压缩为上下文友好的摘要

示例:
  子图包含50个思维节点，代表一个完整的问题解决过程
  提炼: "核心洞察是X，通过方法Y和Z验证，关键步骤为..."
```

### 5.4 性能结果

在排序任务上的表现（核心基准）：

| 方法 | 排序质量 | 成本（LLM调用） | vs CoT质量提升 |
|------|---------|----------------|---------------|
| CoT | 基准 | 1× | — |
| ToT | +52% | 5-8× | +52% |
| **GoT** | **+62%** | **比ToT少31%** | **+62%** |

关键发现：GoT不仅质量更高，还通过聚合操作减少了不必要的重复探索——这体现了"合并优于重复"的原则。多个独立思维可以共享成果，而非各自独立完成到终点。

## 第六章：ToT vs 其他推理范式

### 6.1 全面对比

| 维度 | Chain-of-Thought | Self-Consistency | ToT | GoT |
|------|-----------------|------------------|-----|-----|
| 推理拓扑 | 线性链 | 多条独立链 | 树 | 有向图 |
| 分支 | 无 | 在起点分支N条独立路径 | 在每层分支+剪枝 | 在任意节点分支+合并 |
| 评估 | 无 | 在终点投票 | 每层评估+剪枝 | 评估+聚合+提炼 |
| 探索策略 | 贪心 | 采样+多数投票 | BFS/DFS束搜索 | 图遍历+转换 |
| 回溯 | 无 | 无 | DFS支持 | 支持 |
| LLM调用 | 1次 | k次 | b^d级别 | >ToT（因为有更多操作） |
| 正确率天花板 | 受单链质量限制 | 受采样多样性限制 | 受评估器质量限制 | 受操作设计限制 |
| 适用任务 | 简单多步推理 | 有确定答案的推理 | 需要前瞻的复杂问题 | 需要合并多来源的复杂问题 |

### 6.2 成本效益分析

**对于不同场景选择最优方案：**

```
任务特征 → 推荐方案

"简单几步推理" (如小学数学)
  └→ CoT（1次调用，足够）

"有确定答案，多路径可达" (如数学应用题)
  └→ Self-Consistency (k=5-10)

"需要前瞻规划，早期选择至关重要" (如24点、数独)
  └→ ToT (BFS b=3-5 或 DFS)

"多来源洞察需要合并" (如多角度排序、多专家评估)
  └→ GoT

"实时对话，几乎无延迟容忍"
  └→ CoT（最低延迟）

"非确定性答案，需在质量与成本间平衡"
  └→ Self-Consistency (k可配置)
```

## 第七章：ToT的局限与成本分析

### 7.1 计算成本的指数性质

即使是最保守的b=2, d=3，最坏情况需要 1+2+4+8 = 15次LLM调用。如果使用b=5, d=5，理论上需要 1+5+25+125+625+3125 = 3906次调用（实际通过剪枝大幅减少，但理论最坏仍然很高）。

**实际调用数 vs 理论最坏：**

| 任务 | 参数 | 理论最坏调用 | 实际平均调用 | 剪枝效率 |
|------|------|------------|------------|---------|
| Game of 24 | b=5, d=3 | 156 | ~190 | -22%（评估额外开销） |
| Mini Crosswords | k=5, d=25 | 巨大 | ~200-300 | 高（剪枝+回溯） |

### 7.2 评估器质量瓶颈

评估器是ToT的阿喀琉斯之踵：

1. **评估错误导致错误剪枝**
   好的路径被误判为差 → 被剪掉 → 永远无法到达正确解
   这是不可恢复的错误——一旦剪去，该分支永远消失

2. **评估错误导致保留死胡同**
   差的路径被误判为好 → 保留在束中 → 浪费计算在无效探索上
   这是可恢复的效率损失——虽然浪费但不阻止找到其他路径

3. **Oracle分析揭示了上限**
   Mini Crosswords的Oracle（完美评估器）实验：7/20（35%解出）vs ToT 4/20（20%）
   论文估计如果将评估器提升到完美，Crosswords解出率可从20%上升到约35%
   → 评估质量改善是ToT最重要的改进方向

4. **评估偏差**
   LLM评估器有已知的偏差：
   - 偏好较长的输出（长度偏差）
   - 偏好更权威/自信的语气（风格偏差）
   - 对位置敏感（候选1比候选5更容易被选）

### 7.3 任务适用边界

**ToT显著有效的条件（必须同时满足）：**

1. ✓ 任务有**明确的中间状态**可以评估
2. ✓ 状态有**客观或主观的评价标准**
3. ✓ 有**多个不同的可能路径**到达目标
4. ✓ 错误路径在**中间状态就能识别**（不需要走到终点才知道错）
5. ✓ 任务的计算预算**允许额外的LLM调用**

**ToT无帮助或有害的场景：**
- ✗ 简单的单步或两步任务（树搜索开销 > 收益）
- ✗ 开放式生成无评价标准（无法评估中间状态质量）
- ✗ 延迟敏感的应用（额外调用不可接受）
- ✗ 路径长度不确定的任务（难以设置d上限）

## 第八章：实现指南

### 8.1 完整BFS实现

```python
from dataclasses import dataclass
from typing import List, Callable
import heapq

@dataclass
class ThoughtNode:
    state: str
    path: List[str]
    depth: int
    score: float = 0.0

class TreeOfThoughts:
    """可通用的ToT框架"""

    def __init__(self,
                 thought_generator: Callable,
                 state_evaluator: Callable,
                 search_strategy: str = "bfs"):
        self.generate = thought_generator
        self.evaluate = state_evaluator
        self.strategy = search_strategy

    def solve(self, problem: str, k: int = 5, b: int = 3,
              max_depth: int = 5) -> List[ThoughtNode]:
        """主搜索入口"""
        root = ThoughtNode(state=problem, path=[], depth=0)
        solutions = []

        if self.strategy == "bfs":
            solutions = self._bfs_search(root, k, b, max_depth)
        elif self.strategy == "dfs":
            solutions = self._dfs_search(root, k, b, max_depth)

        return sorted(solutions, key=lambda n: n.score, reverse=True)

    def _bfs_search(self, root: ThoughtNode, k: int, b: int,
                    max_depth: int) -> List[ThoughtNode]:
        frontier = [root]
        solutions = []

        for depth in range(max_depth):
            candidates = []

            for node in frontier:
                if self._is_terminal(node):
                    solutions.append(node)
                    continue

                # 生成k个候选思维
                next_thoughts = self.generate(node.state, k)
                for thought in next_thoughts:
                    new_state = self._apply(node.state, thought)
                    candidates.append(ThoughtNode(
                        state=new_state,
                        path=node.path + [thought],
                        depth=depth + 1
                    ))

            # 评估+剪枝
            for candidate in candidates:
                candidate.score = self.evaluate(
                    root.state, candidate.state
                )

            frontier = sorted(candidates,
                            key=lambda n: n.score,
                            reverse=True)[:b]

        solutions.extend(frontier)
        return solutions

    def _dfs_search(self, root, k, b, max_depth):
        """DFS+回溯实现"""
        stack = [(root, 0)]  # (node, child_index)
        solutions = []
        visited = set()
        steps = 0
        max_steps = 500

        while stack and steps < max_steps:
            node, child_idx = stack[-1]

            if node.depth >= max_depth:
                stack.pop()
                continue

            state_key = (node.state, node.depth)
            if state_key in visited:
                stack.pop()
                continue

            # 评估
            evaluation = self.evaluate(root.state, node.state)
            if evaluation.get("verdict") == "impossible":
                visited.add(state_key)
                stack.pop()
                continue

            if self._is_terminal(node) and self._is_valid(node):
                solutions.append(node)
                if len(solutions) >= 3:
                    break
                stack.pop()
                continue

            # 生成子节点
            if child_idx == 0:
                node._children = [
                    ThoughtNode(
                        state=self._apply(node.state, t),
                        path=node.path + [t],
                        depth=node.depth + 1
                    )
                    for t in self.generate(node.state, k)
                ]
                node._children.sort(key=lambda c: self.evaluate(
                    root.state, c.state
                ).get("score", 0), reverse=True)

            # 深入最有希望的子节点
            if child_idx < len(node._children):
                stack[-1] = (node, child_idx + 1)
                stack.append((node._children[child_idx], 0))
            else:
                visited.add(state_key)
                stack.pop()

            steps += 1

        return solutions
```

### 8.2 LangGraph ToT实现

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, List

class ToTState(TypedDict):
    problem: str
    current_state: str
    path: List[str]
    depth: int
    thought: str
    evaluation: dict
    final_solution: str

def generate_thoughts(state: ToTState) -> dict:
    thoughts = llm.propose(
        f"当前状态: {state['current_state']}\n"
        f"生成5个候选下一步。"
    )
    return {"thoughts": thoughts}

def evaluate_state(state: ToTState) -> dict:
    eval_result = llm.evaluate(
        f"评估状态 '{state['current_state']}' 在问题 "
        f"'{state['problem']}' 中的前景。"
    )
    return {"evaluation": eval_result}

def prune_states(state: ToTState, beam_width=3) -> str:
    """基于评估分数剪枝"""
    evaluated = sorted(
        state["candidates"],
        key=lambda c: c["score"],
        reverse=True
    )
    return {"frontier": evaluated[:beam_width]}

# 构建ToT图
graph = StateGraph(ToTState)
graph.add_node("generate", generate_thoughts)
graph.add_node("evaluate", evaluate_state)
graph.add_node("prune", prune_states)
graph.add_edge(START, "generate")
graph.add_edge("generate", "evaluate")
graph.add_edge("evaluate", "prune")

def route_after_prune(state):
    if state.get("final_solution"):
        return END
    if state["depth"] >= state["max_depth"]:
        return END
    return "generate"

graph.add_conditional_edges("prune", route_after_prune, {
    "generate": "generate",
    END: END
})
```

## 第九章：何时使用ToT

### 最佳场景
- **数学推理：** 24点游戏、数学证明、复杂多步算术、需要试错的问题
- **逻辑谜题：** 数独、填字游戏、逻辑推理、规划问题
- **创意写作（有约束）：** 需要满足多个约束条件，如特定结构+特定主题+特定风格
- **策略游戏和规划：** 需要提前考虑多步后果的决策问题
- **代码生成（有测试）:** 多方案生成→基于测试结果选择最佳

### 不适合的场景
- 实时对话（延迟完全不可接受）
- 简单单步问答（ToT开销完全浪费）
- 开放式无评价标准（无法评估中间状态）
- Token预算极度紧张（ToT的调用量是CoT的5-50倍）
- 任务本身没有"状态"概念（无法分解为中间步骤）

> Tree of Thoughts将经典AI的搜索算法与LLM的生成能力深度结合，证明了在需要前瞻规划的复杂任务上，"有策略的系统搜索"远远优于"随机采样投票"。虽然计算成本较高（5-50倍于CoT），但对于一次正确性远重要于成本的场景（如数学证明、科学推理、高价值决策），ToT提供了其他方法无法比拟的推理深度和质量保障。Graph of Thoughts进一步将推理拓扑从树扩展到图，使思维不再是单向分叉的，而是可以合并和循环增强的。
''';
