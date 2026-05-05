/// Self-Consistency — 完整详解
const String selfConsistencyFullDetail = '''

# 自一致性 (Self-Consistency / CoT-SC) - 完整详解

## 第一章：论文深度解读

### 1.1 论文信息
- **标题:** Self-Consistency Improves Chain of Thought Reasoning in Language Models
- **作者:** Xuezhi Wang, Jason Wei, Dale Schuurmans, Quoc Le, Ed H. Chi, Sharan Narang, Aakanksha Chowdhery, Denny Zhou
- **发表:** ICLR 2023 (Spotlight)
- **arXiv:** 2203.11171
- **作者背景:** Google Research, Brain Team

### 1.2 核心思想

Self-Consistency的核心洞察既简单又深刻：**对于有确定答案的复杂推理问题，存在多条不同的推理路径可以到达同一个正确答案。**

给定一个推理问题，如果让LLM生成多条不同的推理链（通过提高temperature和多次采样），这些推理链可能：
- 采用不同的推理策略（归纳、演绎、类比等）
- 使用不同的中间步骤
- 引用不同的背景知识
- 从不同的角度切入问题

但是——如果问题是良定义的（有唯一正确答案），这些不同的推理路径应该在最终答案上趋于一致。

基于这一洞察，Self-Consistency将标准CoT的单次贪心解码替换为"多次采样+多数投票"策略：
1. 用较高的temperature从LLM采样k条推理链
2. 从每条链提取最终答案
3. 选择出现频率最高的答案作为最终输出

这种方法不需要任何额外的训练、模型修改或外部知识库——仅仅改变了解码策略。

### 1.3 为什么叫"自一致性"

"自"（Self）指的是：不需要外部验证、不需要参考答案、不需要人类标注——一致性完全来自模型自身多个输出的比较。

"一致性"（Consistency）指的是：**正确的推理趋同，错误的推理趋散**。

对于正确的推理：
- 多个独立采样倾向于收敛到相同的正确答案
- 即使表述不同（"答案是5" vs "计算结果为5"），语义一致

对于错误的推理：
- 错误的方式千差万别（计算错误、逻辑跳跃、误解问题等）
- 导致分散的错误答案（4、6、7、-2...）

这种"正确答案收敛，错误答案发散"的现象是Self-Consistency有效的理论基础。

### 1.4 与大数定律的关系

如果单条推理链产生正确答案的概率是p，那么k次独立采样后，多数投票选出的答案正确的概率为：

\$\$P_{correct}(k) = \\sum_{i=\\lceil k/2 \\rceil}^{k} \\binom{k}{i} p^i (1-p)^{k-i}\$\$

随着k增大，如果p > 0.5，正确概率趋近于1。如果p < 0.5，多数投票反而有害（可能放大系统性错误）。

**实际数据：**
- p=0.55, k=5: P_correct ≈ 0.59 (改善4%)
- p=0.55, k=21: P_correct ≈ 0.68 (改善13%)
- p=0.60, k=5: P_correct ≈ 0.68 (改善8%)
- p=0.60, k=21: P_correct ≈ 0.83 (改善23%)

这解释了为什么Self-Consistency在所有模型和所有基准上都能一致改善——单链正确率p通常在0.5以上（大多数推理任务LLM能做到>50%），而且k的增大放大了p>0.5的优势。

### 1.5 关键前提（必须满足）

1. **问题有确定的正确答案**
   开放式问题（如"写一首诗"）不适用——没有"正确"的诗

2. **可以可靠地从推理链中提取答案**
   如果答案嵌入在复杂的自由文本中而无法自动提取，投票无法进行

3. **单条推理链的正确率p > 0.5（至少不显著低于0.5）**
   如果模型系统性偏见导致大多数链都错，Self-Consistency可能放大错误

## 第二章：完整五步流程

### 2.1 Step 1 — 构建CoT提示

**好的CoT提示要素：**
```
系统指令: "请逐步推理，将最终答案放在最后一行。"

问题陈述: [清晰的数学/逻辑问题陈述]

少样本示例:
示例1:
问题: 小明有5个苹果，给了小红2个，又买了3个，现在有几个？
推理: 小明开始有5个→给出2个后剩3个→又买了3个→现在有6个
答案: 6

示例2:
问题: ...

现在请回答以下问题:
[目标问题]
```

**提示设计的关键考虑：**
- Few-shot示例应与目标问题同域（数学→数学，逻辑→逻辑）
- 示例数量：2-3个通常足够，过多浪费Token
- 示例应展示完整的推理过程，而非仅展示答案
- 要求明确的答案格式（"答案: X"或"最终答案: X"）以便提取

### 2.2 Step 2 — 多次采样

```python
def sample_reasoning_chains(prompt: str, k: int,
                            temperature: float = 0.7,
                            model: str = "gpt-4o") -> List[str]:
    """
    从LLM采样k条不同的推理链。

    temperature=0.7是关键——既保持合理推理（不太高导致退化），
    又产生足够多样性（不太低导致所有链相同）。
    """
    chains = []
    for i in range(k):
        response = llm.generate(
            prompt=prompt,
            temperature=temperature,
            max_tokens=1024,
            # 不设置seed参数，让每次调用独立（增加多样性）
        )
        chains.append(response)
    return chains
```

**Temperature对多样性的影响：**

| Temperature | 推理链多样性 | 每条链的质量 | 推荐场景 |
|-------------|------------|------------|---------|
| 0.0-0.2 | 几乎相同 | 最高（确定性输出） | 标准CoT（非SC） |
| 0.3-0.5 | 中等 | 高 | 简单推理任务 |
| **0.5-0.8** | **高** | **中-高** | **Self-Consistency推荐范围** |
| 0.8-1.0 | 很高 | 中（有退化风险） | 探索性采样 |
| >1.0 | 极高 | 低（推理退化） | 不推荐 |

### 2.3 Step 3 — 答案提取

这是Self-Consistency产线中最关键也是最容易出错的环节。

```python
import re
from typing import Optional

def extract_answer(chain: str,
                   answer_patterns: List[str] = None) -> Optional[str]:
    """
    从推理链中提取最终答案。

    多重策略按优先级尝试：
    1. 显式答案标记: "答案: X" / "正确答案是: X"
    2. 最后一行: 链的最后一句话通常是结论
    3. 数值提取: 如果问题是数学题，提取最后出现的数字
    """
    if answer_patterns is None:
        answer_patterns = [
            r'(?:最终)?答案\s*[:：]\s*(.+)',
            r'(?:正确答案)\s*(?:是|为)?[:：]?\s*(.+)',
            r'(?:所以|因此|综上)[,，]\s*(?:答案\s*(?:是|为)?)?[:：]?\s*(.+)',
            r'(?:Answer|Final Answer)\s*[:：]\s*(.+)',
        ]

    for pattern in answer_patterns:
        match = re.search(pattern, chain, re.IGNORECASE)
        if match:
            return match.group(1).strip()

    # 回退: 取最后一行非空内容
    lines = [l.strip() for l in chain.split('\n') if l.strip()]
    if lines:
        return lines[-1]

    return None

def normalize_answer(answer: str) -> str:
    """
    答案归一化——确保语义相同但表述不同的答案计为相同。

    处理:
    - "5" vs "五" vs "five" → "5"
    - "是" vs "Yes" → "yes"
    - "不" vs "No." → "no"
    - 去除标点、多余空格
    - 统一大小写
    """
    answer = answer.strip().lower()
    # 去除尾部标点
    answer = re.sub(r'[.!。！,，;；]\$', '', answer)
    # 中英文数字统一（简化版）
    num_map = {'一': '1', '二': '2', '三': '3', '四': '4', '五': '5',
               '六': '6', '七': '7', '八': '8', '九': '9', '十': '10'}
    for cn, num in num_map.items():
        answer = answer.replace(cn, num)
    return answer
```

**答案提取的常见陷阱：**
1. 推理链中说"小明最后有6个苹果"，但提取器错误地取了"3个"（中间数字）
2. 推理链没有明确的答案标记，导致提取了推理文本而非答案
3. 答案归一化失败："5个"、"五个"、"五"被计为不同答案
4. 推理链中存在多个"答案："标记（先给一个再更正），提取了错误的那个

### 2.4 Step 4 — 投票

```python
from collections import Counter
from typing import List, Tuple

def majority_vote(answers: List[str]) -> Tuple[str, int, float]:
    """
    多数投票——简单但有效

    返回: (得票最多的答案, 得票数, 置信度)
    """
    if not answers:
        return None, 0, 0.0

    counter = Counter(answers)
    top_answer, top_count = counter.most_common(1)[0]
    confidence = top_count / len(answers)  # 得票比例作为置信度

    return top_answer, top_count, confidence

def weighted_vote(chains: List[str],
                  answers: List[str]) -> Tuple[str, float]:
    """
    加权投票——根据推理链质量加权

    权重因子:
    - 推理链长度（更详细的推理可能更可靠）
    - 推理链一致性（中间步骤是否自洽）
    - 推理链格式化程度（结构化程度）

    注意: 原论文发现简单多数投票通常等于或优于加权投票
    """
    weights = []
    for chain, answer in zip(chains, answers):
        # 示例权重: 推理长度（超过平均值加分）
        length_score = min(len(chain) / 500, 2.0)  # 上限2.0

        # 是否有编号的分步推理（结构化）
        structure_score = 1.5 if re.search(r'(步骤|Step)\s*\d', chain) else 1.0

        weight = length_score * structure_score
        weights.append(weight)

    # 按答案聚合权重
    answer_weights = {}
    for answer, weight in zip(answers, weights):
        answer_weights[answer] = answer_weights.get(answer, 0) + weight

    top_answer = max(answer_weights, key=answer_weights.get)
    confidence = answer_weights[top_answer] / sum(weights)

    return top_answer, confidence
```

**为什么简单多数投票通常最优？**

原论文的一个重要发现是：简单的多数投票（每个样本1票）与更复杂的加权方法（如按推理链长度或log概率边缘化）表现相当，有时甚至更好。原因：
- 推理链的长度不一定与正确性相关
- 更复杂的加权可能放大不相关的特征
- 简单投票的"民主"特性避免了过度拟合某个质量指标

### 2.5 Step 5 — 返回结果

```python
def self_consistency_solve(question: str,
                           k: int = 10,
                           temperature: float = 0.7) -> dict:
    """完整的Self-Consistency执行流程"""
    # Step 1: 构建提示
    prompt = build_cot_prompt(question)

    # Step 2: 多次采样
    chains = sample_reasoning_chains(prompt, k, temperature)

    # Step 3: 答案提取
    raw_answers = [extract_answer(chain) for chain in chains]
    answers = [normalize_answer(a) for a in raw_answers if a]

    # Step 4: 投票
    top_answer, vote_count, confidence = majority_vote(answers)

    # Step 5: 返回结构化结果
    return {
        "question": question,
        "answer": top_answer,
        "confidence": confidence,
        "total_samples": k,
        "valid_samples": len(answers),
        "votes_for_answer": vote_count,
        "vote_distribution": dict(Counter(answers).most_common()),
        "chains": chains,  # 可选：用于审计
        "raw_answers": raw_answers  # 可选：用于调试
    }
```

## 第三章：基准测试结果

### 3.1 主要基准结果

| 基准 | 任务类型 | CoT基线 | CoT-SC | 提升（绝对值） | 提升（相对） |
|------|---------|---------|--------|-------------|-----------|
| GSM8K | 小学数学应用题（8.5K题目） | 56.5% | **74.4%** | +17.9% | +32% |
| SVAMP | 数学应用题变体 | 69.9% | **80.9%** | +11.0% | +16% |
| AQuA | 代数应用题 | 35.8% | **48.0%** | +12.2% | +34% |
| StrategyQA | 多步推理QA | 73.0% | **79.4%** | +6.4% | +9% |
| ARC-challenge | 科学推理 | 75.2% | **79.1%** | +3.9% | +5% |
| CSQA | 常识QA | 76.7% | **80.7%** | +4.0% | +5% |
| Date Understanding | 日期推理 | 65.1% | **71.1%** | +6.0% | +9% |
| Sports Understanding | 体育规则推理 | 73.1% | **79.5%** | +6.4% | +9% |
| SNLI | 自然语言推理 | 67.5% | **72.1%** | +4.6% | +7% |

### 3.2 最重要的发现

**1. 即使标准CoT无效，Self-Consistency仍有效**

在GSM8K上：
- 标准CoT (temperature=0, 单次贪心): 56.5%
- CoT-SC (k=5): 68.7% (+12.2%)
- CoT-SC (k=10): 72.8% (+16.3%)
- CoT-SC (k=20): 74.4% (+17.9%)
- CoT-SC (k=40): ~75.0% (+18.5%，收益递减)

即使在单次贪心解码表现不佳的任务上，Self-Consistency仍能显著改善。

**2. 采样数的收益递减**

| k (采样数) | GSM8K准确率 | 边际增益 | 成本增加 |
|-----------|------------|---------|---------|
| 1 (CoT) | 56.5% | — | 1× |
| 5 | 68.7% | +12.2% | 5× |
| 10 | 72.8% | +4.1% | 10× |
| 20 | 74.4% | +1.6% | 20× |
| 40 | ~75.0% | +0.6% | 40× |

- k=5: 最显著的提升（+12.2%），成本适中
- k=10: 仍显著提升，但边际增益已减半
- k=20+: 收益递减明显
- **推荐范围：k=5-10** 对于大多数应用是最佳性价比

**3. 跨模型的通用性**

Self-Consistency在所有测试的模型上（GPT-3系列、PaLM系列、LaMDA等）和所有模型规模上都一致改善推理性能。这是它最强大的特性——不依赖特定模型，适用范围极广。

### 3.3 不同温度下的表现

| Temperature | 多样性 | GSM8K准确率 (k=10) | 评估 |
|-------------|--------|-------------------|------|
| 0.0 | 无（所有链相同） | 56.5%（=标准CoT） | SC无效果 |
| 0.3 | 低 | 62.1% | SC有一定效果 |
| 0.5 | 中 | 69.3% | SC效果好 |
| 0.7 | 高 | 72.8% | **最佳** |
| 0.9 | 很高 | 70.2% | 多样性好但链质量下降 |
| 1.2 | 极高 | 64.8% | 推理退化 |

**最佳策略：temperature=0.7, k=5-10**

## 第四章：投票策略进阶

### 4.1 简单多数投票（Plurality Voting）

```python
def plurality_vote(answers: List[str]) -> str:
    """每个答案一票，得票最多者胜出"""
    return Counter(answers).most_common(1)[0][0]
```

优点：最简单、最快、原论文验证效果最好
缺点：对票数接近的情况不敏感（49% vs 51%与90% vs 10%无区别）

### 4.2 加权多数投票（RASC, 2024）

基于推理链质量的加权：

```python
def rasc_weighted_vote(chains: List[str], answers: List[str]) -> str:
    """
    RASC (Relevance-Aware Self-Consistency) 加权策略

    三个质量维度:
    1. 完整性 (40%): 推理链是否覆盖了问题的所有方面？
    2. 连贯性 (30%): 推理步骤之间是否逻辑自洽？
    3. 准确性 (30%): 中间计算/推理是否正确？
    """
    weights = []
    for chain in chains:
        completeness = evaluate_completeness(chain) * 0.4
        coherence = evaluate_coherence(chain) * 0.3
        factual = evaluate_factual_accuracy(chain) * 0.3
        weights.append(completeness + coherence + factual)

    # 加权投票
    answer_scores = {}
    for answer, weight in zip(answers, weights):
        answer_scores[answer] = answer_scores.get(answer, 0) + weight

    return max(answer_scores, key=answer_scores.get)
```

### 4.3 排名投票（RankedVotingSC, 2025）

2025年的新进展——将社会选择理论的高级投票方法引入Self-Consistency：

**1. Instant-Runoff Voting (IRV):**
```python
def irv_vote(ranked_ballots: List[List[str]]) -> str:
    """
    即时决选投票。
    每轮淘汰得票最多的最少票答案，将其投票重新分配给下一选择。
    重复直到有答案获得多数票。
    """
    while True:
        first_choices = Counter(b[0] for b in ranked_ballots if b)
        total = sum(first_choices.values())
        majority_threshold = total / 2

        # 检查是否有答案获得多数
        for answer, count in first_choices.items():
            if count > majority_threshold:
                return answer

        # 淘汰最少票的答案
        min_votes = min(first_choices.values())
        eliminated = {a for a, c in first_choices.items() if c == min_votes}

        # 重新分配投票
        new_ballots = []
        for ballot in ranked_ballots:
            new_ballot = [a for a in ballot if a not in eliminated]
            if new_ballot:
                new_ballots.append(new_ballot)
        ranked_ballots = new_ballots
```

**2. Borda Count:**
```python
def borda_count(ranked_ballots: List[List[str]]) -> str:
    """
    Borda计分: 排名第一得n-1分，排名最后得0分。
    奖励始终出现在高排名的答案。
    """
    if not ranked_ballots:
        return None

    # 收集所有候选答案
    all_answers = set()
    for ballot in ranked_ballots:
        all_answers.update(ballot)
    n = len(all_answers)

    scores = {answer: 0 for answer in all_answers}
    for ballot in ranked_ballots:
        for rank, answer in enumerate(ballot):
            scores[answer] += (n - 1 - rank)

    return max(scores, key=scores.get)
```

**3. Mean Reciprocal Rank (MRR):**
```python
def mrr_vote(ranked_ballots: List[List[str]]) -> str:
    """
    平均倒数排名: MRR(answer) = avg(1/rank(answer, ballot))
    奖励始终出现在高排名的答案。
    """
    scores = {}
    counts = {}

    for ballot in ranked_ballots:
        for rank, answer in enumerate(ballot):
            reciprocal = 1.0 / (rank + 1)
            scores[answer] = scores.get(answer, 0) + reciprocal
            counts[answer] = counts.get(answer, 0) + 1

    # 除以出现次数得到平均
    avg_scores = {a: scores[a] / counts[a] for a in scores}

    return max(avg_scores, key=avg_scores.get)
```

### 4.4 自适应一致性（Adaptive-Consistency）

2024年的重要改进——不需要固定k值，而是动态决定何时停止采样：

```python
import numpy as np
from scipy import stats

def adaptive_consistency(prompt: str,
                         max_samples: int = 40,
                         confidence_threshold: float = 0.95,
                         min_samples: int = 3) -> dict:
    """
    自适应采样——在已有足够证据时提前停止。

    使用贝塔分布建模答案分布的不确定性。
    当某个答案的后验概率超过阈值时停止采样。
    """
    chains = []
    answers = []

    for k in range(1, max_samples + 1):
        # 采样一条新链
        chain = llm.generate(prompt, temperature=0.7)
        answer = normalize_answer(extract_answer(chain))

        chains.append(chain)
        answers.append(answer)

        if k < min_samples:
            continue  # 最少采样数

        # 统计当前答案分布
        counter = Counter(answers)
        top_answer, top_count = counter.most_common(1)[0]
        proportion = top_count / k

        # 使用贝塔分布的累积概率判断
        # Beta(top_count+1, k-top_count+1) 的后验
        beta_cdf = stats.beta.cdf(0.5, top_count + 1, k - top_count + 1)

        # 如果最可能答案的后验概率超过阈值
        if (1 - beta_cdf) > confidence_threshold:
            return {
                "answer": top_answer,
                "confidence": proportion,
                "samples_used": k,
                "stopped_early": True
            }

    # 达到max_samples仍未收敛
    top_answer, top_count = Counter(answers).most_common(1)[0]
    return {
        "answer": top_answer,
        "confidence": top_count / len(answers),
        "samples_used": len(answers),
        "stopped_early": False
    }
```

**自适应一致性的优势：**
- 简单问题可能在k=3-5时就收敛（节省60-80%调用）
- 困难问题继续采样直到足够证据或达到上限
- 相比固定k=20的SC，平均减少3-6倍的采样量

### 4.5 逆熵投票（Inverse-Entropy Voting, NeurIPS 2025）

这是2025年NeurIPS接收的最具创新性的投票策略之一。与传统的并行独立采样不同，IEV进行顺序改进：

```python
def inverse_entropy_voting(prompt: str, max_chains: int = 20) -> str:
    """
    逆熵投票: 每条新链在前一条的基础上改进。

    关键: 并非采样20条独立链，而是生成一条链后，
    让LLM"改进上一条链的不足之处"。
    这种顺序改进产生比并行采样更多样、更高质量的结果。

    与并行SC的区别:
    - 并行SC: 20条链独立生成，彼此不知道对方的存在
    - IEV: 每条链看到前一条的"弱点"，针对性改进
    """
    chains = []
    improvement_hints = ""

    for i in range(max_chains):
        # 基于改进提示生成链
        chain_prompt = f"""{prompt}

{improvement_hints}
请给出你的推理和答案。"""

        chain = llm.generate(chain_prompt, temperature=0.7)
        chains.append(chain)

        # 分析当前链的弱点（作为下一条链的改进方向）
        if i < max_chains - 1:
            analysis = llm.generate(
                f"分析以下推理链的潜在弱点或不确定之处：\n{chain}\n"
                f"弱点: ",
                temperature=0.3
            )
            improvement_hints = f"之前的推理可能存在以下弱点: {analysis}\n请针对性地改进。"

    # 使用逆熵加权
    answers = [extract_answer(c) for c in chains]
    weights = compute_iev_weights(chains)  # 后来的链（改进了前面的）权重更高

    return weighted_vote(answers, weights)

def compute_iev_weights(chains: List[str]) -> List[float]:
    """
    逆熵加权: 计算每条链的信息增益。

    原则: 早期链权重低（可能尚未发现最优路径），
          后期链权重高（基于早期链的弱点的针对性改进）。
          但如果后期链退化，权重降低。
    """
    n = len(chains)
    # 基础权重: 后期链略高
    base_weights = [1.0 + (i / n) * 0.5 for i in range(n)]

    # TODO: 实际实现中需要计算每条链的信息熵增益
    # 为简化，这里返回基础权重

    return base_weights
```

IEV在95.6%的配置中（相同计算预算下）优于并行SC。这证实了"顺序改进"比"独立并行"产生更高质量的结果——更接近人类的问题解决方式（迭代改进而非重新开始）。

## 第五章：Self-Consistency vs 其他推理增强方法

### 5.1 全面对比

| 维度 | 直接采样 (t=0) | Self-Consistency | ToT (Tree of Thoughts) | Reflective改进 | Multi-Agent辩论 |
|------|-------------|-----------------|----------------------|----------------|----------------|
| LLM调用次数 | 1次 | k次 | b^d级别 | 3-10次/条链 | N×M次（N个Agent, M轮） |
| 推理路径 | 单条贪心 | k条独立并行 | 树形依赖探索 | 同一链迭代改进 | 多条链相互辩论 |
| 是否需要评估 | 否 | 否（仅投票） | 是（每层评估） | 是（每轮评估） | 是（其他Agent评论） |
| 路径关系 | — | 独立 | 依赖（父子） | 依赖（改进链） | 依赖（反馈链） |
| 成本 | 1× | k× | 5-50× | 3-10× | 10-50× |
| 实现难度 | 最低 | 极低 | 中-高 | 中 | 高 |
| 适用任务 | 所有任务 | 有确定答案的推理 | 需前瞻规划 | 有改进空间的任务 | 开放式推理 |

### 5.2 Self-Consistency vs ToT

这是最重要的对比——两者都在NeurIPS 2023上提出，都被广泛采纳：

```
Self-Consistency适合:
├── 问题空间: 推理路径多样但独立
├── 答案空间: 确定、离散、可提取
├── 最佳场景: 数学应用题、常识推理、事实QA
├── 优势: 极简实现（~20行代码）、线性成本增长
└── 局限: 不改善单条链的质量，只通过投票选择最佳

ToT适合:
├── 问题空间: 推理路径相互依赖（每步影响后续）
├── 答案空间: 需要序列决策（如24点、规划）
├── 最佳场景: 数学搜索、逻辑谜题、约束满足
├── 优势: 深度探索、前瞻规划、回溯能力
└── 局限: 指数成本增长、依赖评估器质量
```

**量化对比（GSM8K数学）：**
- CoT: 56.5%, 1次调用
- SC (k=5): 68.7%, 5次调用, +12.2pp
- SC (k=20): 74.4%, 20次调用, +17.9pp
- ToT在此任务上不适用（数学应用题没有自然的树状推理结构）

**量化对比（Game of 24）：**
- CoT: 4.0%, 1次调用
- SC (k=100): 9.0%, 100次调用, +5.0pp (oracle: 20%)
- ToT (b=5): **74%**, ~190次调用
- → 搜索结构优于采样数量（ToT 190次 >>> SC 100次）

## 第六章：关键设计参数

### 6.1 完整参数表

| 参数 | 推荐值 | 范围 | 说明 |
|------|--------|------|------|
| 采样数k | 5-10 | 3-40 | 更多=更高准确率但边际递减 |
| Temperature | 0.5-0.7 | 0.3-0.9 | 平衡多样性和质量 |
| 投票策略 | 简单多数 | — | 原论文发现最优或接近最优 |
| 答案提取 | 正则+归一化 | — | 最关键的非模型组件 |
| 最大Token长度 | 512-1024 | 256-2048 | 根据问题复杂度调整 |

### 6.2 参数调优指南

**k（采样数）的选择：**
- 预算极紧：k=3（效率优先）
- 标准场景：k=5-7（成本/效果平衡）
- 高准确度要求：k=10-15
- 理论研究/基准：k=20-40（追求上限）
- 不建议超过k=40（收益递减+成本高）

**Temperature的选择：**
- 保守（确保每条链质量）：0.3-0.5
- 标准（多样性与质量平衡）：0.5-0.7
- 探索性（最大化多样性）：0.7-0.9
- 避免>1.0（推理退化风险）

**Temperature schedule（递增温度策略）：**
```python
def temperature_schedule(i: int, k: int) -> float:
    """
    第i次采样的温度（i从0开始）。

    早期采样低温度（确保基础质量），
    后期采样高温度（增加多样性探索新模式）。
    """
    base_temp = 0.3
    max_temp = 0.8
    # 线性递增
    return base_temp + (i / max(k - 1, 1)) * (max_temp - base_temp)

# 使用示例
for i in range(k):
    temp = temperature_schedule(i, k)
    chain = llm.generate(prompt, temperature=temp)
```

## 第七章：为什么Self-Consistency有效？——深入分析

### 7.1 多样性带来鲁棒性

单一贪心解码（temperature=0）的问题是：LLM可能被"固定"在某个特定推理路径上——这个路径可能恰好是错误的。提高temperature让模型探索不同的推理方向，增加了至少有一条路径正确的概率。

**类比：** 单一贪心路径像在迷宫中直线前进——如果迷宫没有分叉，你顺利到达。但如果有分叉且你需要转弯，直线前进会导致撞墙。Self-Consistency让多个探索者各自尝试不同路径——有人会找到正确的转弯。

### 7.2 正确推理趋向一致

这是一个经验观察而非理论保证，但它在广泛的基准上被验证：

- **正确推理的收敛性：** 对于有确定答案的问题，不同的正确推理路径虽然在表述、中间步骤、使用的知识来源上不同，但最终答案趋向一致。
- **错误推理的发散性：** 错误的方式多种多样——计算错误可能得到偏大的数字，逻辑错误可能得到完全相反的结论，误解可能得到不同类别的问题。

这种"收敛-发散"不对称性是Self-Consistency有效的基础。如果错误答案也趋向于一致（如模型对某类问题存在系统性偏见），Self-Consistency可能反而有害。

### 7.3 单链依赖 vs 多链冗余

系统可靠性理论中的基本概念——冗余（Redundancy）——完美解释了Self-Consistency的有效性：

- 单条推理链 = 单点故障（SPOF）
  - 一个计算错误 → 整个答案错误
  - 一次逻辑跳跃 → 整个答案错误
  - 一个误解 → 整个答案错误

- 多条推理链 = N模冗余（N-Modular Redundancy）
  - 多数链必须同时出错才导致错误（概率大幅降低）
  - 不同链的出错模式通常不同（不相关故障）
  - 假设每条链独立犯错概率为q=0.3，5条链中≥3条同时出错的概率 = 0.16（从0.30降低约一半）

### 7.4 失效模式分析

**模式1：系统性偏见**
所有链都存在相同的偏见 → 即使采样20条，所有链都给出相同的错误答案 → Self-Consistency无效。
- 例子：训练数据中"美国总统"问题的回答偏见
- 检测：所有k条链给出相同答案 + 答案分布极其集中（>90%） + 但答案实际上是错的
- 缓解：使用不同模型作为交叉验证

**模式2：错误答案的共识**
大多数链错误但巧合地收敛到相同的错误答案 → 多数投票选择错误答案 → Self-Consistency有害。
- 例子：数学问题有"看起来合理"的错误解
- 检测：如果得票最多的答案仅以微弱优势获胜（如6/10 vs 4/10）
- 缓解：置信度阈值（如果<0.7，降低temperature重试或转交人工）

**模式3：答案提取失败**
答案提取器的系统性错误 → 不同的正确答案被归一化为不同的字符串 → 投票分散。
- 例子："5"、"五"、"5个"被计为三个不同答案
- 检测：观察答案分布是否不合理地分散
- 缓解：改进答案归一化逻辑

## 第八章：生产应用案例

### 8.1 数学教育平台 — 自动批改助手

**场景：** 某教育科技公司使用Self-Consistency自动批改学生数学作业。

**实现：**
```python
def grade_math_homework(question: str, student_answer: str) -> dict:
    """
    自动批改数学作业——用Self-Consistency生成参考答案
    """
    # Step 1: 用SC生成高置信度的参考答案
    ref_result = self_consistency_solve(question, k=10, temperature=0.6)

    # Step 2: 如果SC置信度>0.8，使用其结果作为标准答案
    if ref_result["confidence"] >= 0.8:
        correct_answer = ref_result["answer"]

        # Step 3: 比较学生答案与参考答案
        is_correct = compare_math_answers(student_answer, correct_answer)

        if not is_correct and ref_result["confidence"] >= 0.95:
            # 极高置信度+学生答案不同→一定错
            feedback = generate_correction_feedback(
                student_answer, correct_answer,
                ref_result["chains"]
            )
            return {"correct": False, "feedback": feedback}
    else:
        # 置信度不足→标记需人工批改
        return {"correct": None, "needs_human_review": True}

# 效果:
# - 自动批改率: 78%（SC置信度足够高的题目）
# - 准确率: 99.2%（与人工批改对比）
# - 成本: ~\$0.01/题（k=10, GPT-4o-mini）
```

### 8.2 医疗问答 — 症状分析辅助

**场景：** 基于症状描述的初步诊断建议。由于风险高，使用高k值和混合策略。

```python
def symptom_analysis(symptoms: str) -> dict:
    """
    症状分析——使用高k值（k=40）+ 多模型交叉验证
    """
    # 使用多个模型独立做SC
    models = ["claude-sonnet-4-6", "gpt-4o", "gemini-2.5-pro"]
    all_results = []

    for model in models:
        result = self_consistency_solve(
            symptoms, k=20, temperature=0.5, model=model
        )
        all_results.append(result)

    # 跨模型一致性检查
    model_answers = [r["answer"] for r in all_results]
    model_consensus = Counter(model_answers).most_common(1)[0]

    if model_consensus[1] >= 2:  # 至少2/3模型同意
        return {
            "diagnosis": model_consensus[0],
            "confidence": "high" if model_consensus[1] == 3 else "medium",
            "model_agreement": model_consensus[1] / 3,
            "cross_validated": True
        }
    else:
        return {
            "diagnosis": None,
            "confidence": "low",
            "needs_specialist_review": True,
            "model_opinions": model_answers
        }

# 效果:
# - 高置信度诊断率: 65%（足够确信自动输出）
# - 自动输出准确率: 96.5%（vs 专家诊断）
# - 低置信度病例自动转专科医生
```

### 8.3 代码生成 — 多版本测试驱动

**场景：** 生成代码的多个实现版本，通过测试运行选择最优版本。

```python
def generate_robust_code(spec: str, test_cases: List[dict]) -> dict:
    """
    代码生成 + Self-Consistency + 测试驱动选择
    """
    # Step 1: 生成k个代码版本
    code_versions = []
    for i in range(10):
        code = llm.generate(
            f"根据以下规格生成Python函数:\n{spec}\n"
            f"请输出完整的函数代码。",
            temperature=0.6
        )
        code_versions.append(code)

    # Step 2: 对每个版本运行测试
    test_results = []
    for i, code in enumerate(code_versions):
        passed, total = run_tests(code, test_cases)
        test_results.append({
            "version": i,
            "code": code,
            "passed": passed,
            "total": total,
            "score": passed / total if total > 0 else 0
        })

    # Step 3: 选择最佳版本（测试通过率最高）
    test_results.sort(key=lambda r: r["score"], reverse=True)
    best = test_results[0]

    # Step 4: 如果多个版本满分→用SC投票（选择最一致的实现风格）
    if best["score"] == 1.0:
        perfect_versions = [r for r in test_results if r["score"] == 1.0]
        if len(perfect_versions) > 1:
            # 有多个满分版本→选择最"优雅"的（通过代码风格投票）
            best = select_most_elegant(perfect_versions)

    return {
        "code": best["code"],
        "test_score": best["score"],
        "total_versions": len(code_versions),
        "perfect_versions": len(perfect_versions) if best["score"] == 1.0 else 0
    }
```

## 第九章：实现极简指南

### 9.1 30行最小实现

```python
import re
from collections import Counter

def self_consistency(question: str, llm, k: int = 7) -> str:
    """
    最小Self-Consistency实现 —— 仅30行。
    """
    prompt = f"问题: {question}\n\n请逐步推理，最后以'答案: X'格式给出答案。\n\n推理:"

    # 采样k条链
    chains = [llm(prompt, temperature=0.7) for _ in range(k)]

    # 提取答案
    answers = []
    for chain in chains:
        match = re.search(r'答案\s*[:：]\s*(.+?)(?:\n|\$)', chain)
        if match:
            answers.append(match.group(1).strip().lower())

    if not answers:
        return chains[0]  # 无法提取，返回第一条链

    # 多数投票
    best_answer = Counter(answers).most_common(1)[0][0]

    # 返回对应最佳答案的第一条链（最详细的推理）
    for chain, answer in zip(chains, answers):
        if answer == best_answer:
            return chain

    return chains[0]

# 使用示例
# answer = self_consistency("一个水池有两个进水管...", llm, k=5)
```

### 9.2 LangChain Integration

```python
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from collections import Counter

class SelfConsistencyChain:
    def __init__(self, llm, k=5, temperature=0.7):
        self.llm = llm
        self.k = k
        self.temperature = temperature

    def run(self, question: str) -> dict:
        prompt = PromptTemplate(
            input_variables=["question"],
            template=(
                "问题: {question}\n\n"
                "请逐步推理。\n"
                "推理过程:\n"
                "最终答案: "
            )
        )
        chain = LLMChain(llm=self.llm, prompt=prompt)

        # 多次采样
        chains = []
        for _ in range(self.k):
            result = chain.run(question=question)
            chains.append(result)

        # 提取和投票（同上）
        answers = [self._extract(c) for c in chains]
        best = Counter(answers).most_common(1)[0][0]

        return {
            "answer": best,
            "confidence": answers.count(best) / len(answers),
            "chains": chains
        }

    def _extract(self, text: str) -> str:
        """从推理文本中提取最终答案"""
        # 实现提取逻辑
        pass
```

## 第十章：何时使用Self-Consistency

### 最佳场景
- **数学应用题：** GSM8K、SVAMP、AQuA等，多路径推理→投票选最优
- **多选题/判断题：** 多角度分析→投票→最一致的选项
- **事实问答：** 多来源推理→交叉验证→最一致的答案
- **代码生成（有测试）：** 多版本实现→运行测试→选最优版本
- **数值估算：** 多方估算→平均→更准确的预测（Wisdom of Crowds效应）

### 不适合的场景
- **开放式/创造性任务：** 写诗、故事创作（无"正确"答案）
- **实时应用：** k倍延迟不可接受（每次额外调用增加延迟）
- **极长推理任务：** 单条链成本已很高（如10K token/链），k倍将不可承受
- **系统性偏见任务：** 所有链有相同偏见→SC无法纠正
- **主观评价任务：** 无客观标准判断哪个答案"正确"

### 快速决策：
```
□ 问题有唯一的正确答案吗？ → 继续
□ 可以从LLM输出中可靠提取答案吗？ → 继续
□ 单次LLM调用的延迟和成本可接受吗？ → 继续
□ 愿意支付k倍的成本换取更高的准确率吗？ → 使用Self-Consistency
□ 以上任一项为否 → 考虑标准CoT或其他方法
```

> Self-Consistency是提升LLM推理可靠性最简单、最有效的方法之一。它的核心公式只有三步：多次采样→提取答案→多数投票。不需要修改模型、不需要复杂的搜索策略、不需要额外训练或外部知识库。它利用了推理问题的一个深刻不对称性：正确的推理趋向一致，错误的推理趋向发散。在2025年，Self-Consistency已成为几乎任何有确定答案的复杂推理任务的默认增强策略。对于预算充足但追求准确率的场景，结合自适应一致性（提前停止）和排名投票策略，Self-Consistency提供了目前最佳的投入产出比。
''';
