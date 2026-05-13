---
name: adr
description: Record an architectural decision with context, tradeoffs, and consequences. Use when a technology is chosen, a pattern is established that others must follow, a constraint is accepted that limits future options, or a previous decision is reversed. Triggers: 架构决策, ADR, 记录这个决策, 为什么选 X, document this decision, 把这个决策写下来. If the user is still deciding ("help me choose A vs B"), help analyze first, then offer to record the outcome as an ADR.
---

# ADR（架构决策记录）

记录重要技术决策的上下文、内容和后果，让未来的人知道"为什么"，不只是"是什么"。

## Step 0：识别场景

**场景 A — 帮助决策**（用户还未决定）：
1. 收集上下文（见 Step 1）
2. 列出各选项的权衡分析
3. 给出分析结论（不替用户最终决定）
4. 确认方向后，询问是否记录为 ADR，进入 Step 2

**场景 B — 记录已有决策**（用户已决定）：
直接进入 Step 1，收集信息后写 ADR 文件。

## Step 1：收集决策上下文

从对话和代码库中确认（已明确的跳过）：

1. 决策是什么？（一句话描述技术选择）
2. 触发原因是什么？（新需求、性能瓶颈、事故、技术债）
3. 考虑过哪些选项？（至少 2 个；只有 1 个时，说明为何没有其他选项）
4. 约束条件是什么？（性能、成本、团队技能、现有技术栈兼容性）
5. 影响哪些模块或接口？（从代码库直接读取，不猜测）

## Step 2：写 ADR 文件

**位置：** `docs/decisions/ADR-NNNN-短标题.md`（NNNN 为顺序编号，无此目录则创建）

```md
# ADR-NNNN: [现在时标题，如"使用 PostgreSQL 作为主存储"]

Date: YYYY-MM-DD
Status: Proposed | Accepted | Superseded by ADR-XXXX
Deciders: [姓名或角色，可选]

## Context
[2–4 句：什么情况迫使做这个决定，有哪些相关约束]

## Decision
We will [do X] because [core reason].

## Options Considered
| Option | Pros | Cons |
|--------|------|------|

## Consequences

**Positive:** [预期收益]
**Negative / Tradeoffs:** [被接受的代价]

## Interface / Module Impact
- 影响哪些模块或接口边界？
- 是否新增或移除依赖？
- 是否破坏现有兼容性？

## Validation
[如何知道这个决策是对的——可观测指标、复查日期、或具体条件]

## Rollback
[如果决策错误，如何撤销——或说明"不可逆，因为 X"]

## Follow-ups
- [ ] [后续行动] — owner — date
```

## 维护规则

- 决策被推翻时：将状态更新为 `Superseded by ADR-XXXX`，写新 ADR 说明原因
- **不删除旧 ADR** — 错误决策的历史记录防止重蹈覆辙
- 在相关代码处添加注释引用 ADR 编号，方便后人查找

## Stop Condition

ADR 文件已写入 `docs/decisions/`，状态已设置，相关代码或 PR 中已引用 ADR 编号。
