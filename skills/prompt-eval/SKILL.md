---
name: prompt-eval
description: Use only for reusable AI prompt templates that have failure examples and measurable success criteria. Iteratively compare prompt variants using mutation, crossover, scoring, and selection. Do not use for one-off prompts or prompts without failure samples.
---

# Prompt Eval

改进长期复用的 AI 提示词模板。不要把一次性 prompt 过度工程化。

## 触发条件

只有同时满足以下条件时才使用：

- 这个 prompt 会被长期复用
- 已经有至少 5 个成功或失败样本，最好 10 个以上
- 能定义评价指标
- 能比较多个版本
- 最终版本会有人 review

不适用于：
- 一次性聊天 prompt
- 没有失败样本的 prompt
- 无法定义好坏标准的开放式创作
- 只是想让 prompt "更高级"

## 核心原则

- Prompt 不是越长越好
- 优先 outcome-first，而不是堆叠流程和口号
- 每一条约束都要有存在理由
- 删除无用规则比新增规则更重要
- 允许经验判断，但必须用样本验证
- 最终 prompt 需要人工 review，因为局部优化可能伤害其他输入

## 输入格式

```md
# Prompt Eval Input

## Current Prompt
当前 prompt。

## Use Case
这个 prompt 用来做什么？

## Inputs
典型输入是什么？

## Desired Outputs
理想输出是什么？

## Failure Examples
| Input | Bad Output | Why Bad |
|---|---|---|

## Success Examples
| Input | Good Output | Why Good |
|---|---|---|

## Constraints
必须遵守什么限制？
```

## 评价指标

从以下指标选择 3-6 个，不要全部使用：

```text
准确性：是否符合事实或代码证据。
可执行性：是否能直接指导下一步行动。
范围控制：是否避免过度扩展。
结构清晰：是否便于 review。
少幻觉：是否区分事实、假设和推测。
验证意识：是否提供验证方式。
简洁性：是否去掉无用废话。
稳定性：不同输入下是否表现一致。
```

## 进化式迭代流程

### 1. 建立初始种群

创建 3-5 个 prompt 版本：

```text
P0：当前版本。
P1：更短、更 outcome-first 的版本。
P2：更严格、更有边界的版本。
P3：更强调验证和证据的版本。
P4：融合版本，可选。
```

### 2. Mutation：局部变异

每次只改变一个方向：
- 删除冗余规则
- 加强输入/输出格式
- 明确禁止事项
- 增加失败处理方式
- 缩短流程描述
- 改善触发边界

### 3. Crossover：交叉融合（可选）

仅当 Mutation 后最高分版本仍与次优版本分差 < 3 分时才执行。
合并两个表现好的版本，但只保留真正有用的约束。
如果 Mutation 已产生明显优胜者，跳过 Crossover 直接进入 Scoring。

### 4. Scoring：评分

使用样本集对每个版本评分：

```md
| Prompt | Accuracy | Scope Control | Actionability | Low Hallucination | Simplicity | Total | Notes |
|---|---:|---:|---:|---:|---:|---:|---|
```

每项 1-5 分。必须写出扣分原因。

### 5. Selection：选择

选择最佳版本，并说明：

```text
保留了什么？
删除了什么？
为什么这个版本更稳？
在哪些输入上仍可能失败？
```

## 输出格式

```md
# Prompt Evolution Report

## Goal

## Dataset
- 样本数量：
- 失败类型：

## Candidate Prompts
### P0
### P1
### P2

## Score Table
| Prompt | Accuracy | Scope | Actionability | Low Hallucination | Simplicity | Total | Notes |
|---|---:|---:|---:|---:|---:|---:|---|

## Winner
最终 prompt。

## Why It Won

## Known Risks

## When Not To Use

## Archive
被淘汰版本和原因。
```

## 停止条件

满足以下条件时停止：
- 最佳 prompt 明显优于当前版本，或确认当前版本已经足够好
- 已记录失败风险
- 已写明适用/不适用场景
- 没有为了优化而无限迭代

如果样本不足，先输出需要收集哪些样本，不要虚构评估结果。
