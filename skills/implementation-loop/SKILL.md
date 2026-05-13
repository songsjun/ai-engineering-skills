---
name: implementation-loop
description: Use when implementing a scoped coding task. Break work into small reversible steps, preserve architecture boundaries, run validation, and prepare one independent commit per feature or fix. Use after product-scope when scope is unclear. If user explicitly requests TDD, use tdd skill instead — they are mutually exclusive.
---

# Implementation Loop

把已收敛的需求变成小步、可验证、可回滚的代码改动。

## 触发场景

- "开始实现" / "开发这个功能"
- "每次提交一个独立功能" / "注意回滚"
- "多 agent 并行开发" / "主对话负责集成"
- 已有明确验收标准
- 任务需要拆解成多个小步骤

## 输入要求

开始前确认已有：

```text
目标：
非目标：
验收标准：
限制条件：
风险：
```

缺失时，不猜测。先补简短 scope brief；必要时调用 product-scope。

## 实现流程

### 1. 读取上下文

Agent 直接读取，不询问用户：
- 相关代码文件和测试
- 项目构建/测试命令（package.json / Makefile 等）
- 现有模块边界和命名风格
- 是否已有类似实现可复用

**上下文预算检查：** 读取前先列出拟读文件和估算行数。如果总量超过当前上下文窗口的 60%，缩小读取范围（优先读接口定义、测试、直接相关文件，跳过大型无关模块），并在 Implementation Plan 中注明"因上下文限制，以下文件未读取：[列表]"。不要静默截断。

### 2. 拆解任务

输出短计划：

```md
# Implementation Plan

## Change Unit
本次只实现什么独立功能或修复？

## Files Likely Affected
- path/to/file: 为什么要改

## Steps
1. 最小代码改动
2. 测试或验证（Agent 直接运行）
3. 清理无关 diff

## Rollback Plan
如何撤销本次改动？
```

### 3. 多 Agent 判断

默认单 agent。只有满足以下任一条件才启用 subagents：

- 改动超过 3 个模块
- 涉及 API、数据结构、权限、持久化或迁移
- 需要比较多个实现方案
- 单 agent 已出现反复失败、误改范围扩大或上下文混乱

如果启用多 agent，**必须先由探索 agent 输出文件级互斥边界**，再分配实现任务：

```text
探索 agent：只读代码，收集证据和风险，不改代码。
  → 必须输出：各实现 agent 的"禁止同时修改文件列表"（共享文件由主对话统一处理）

实现 agent：声明自己的写操作文件范围后才能开始修改。
  → 只改探索 agent 分配给自己的文件，不触碰共享文件。

review agent：审查 diff、测试缺口和边界问题。
主对话：合并判断、架构控制、处理共享文件、最终验收。
```

### 4. 编码纪律

- 只修改完成当前 change unit 必要的代码
- 不做顺手重构
- 不引入新依赖，除非明确必要并说明替代方案
- 不改变公共接口，除非任务需要且说明兼容性
- 保持现有风格
- 发现额外问题时记录为 follow-up，不纳入本次改动

### 5. 验证

Agent 直接运行项目已有测试命令。如果没有现成命令，构造最小验证脚本并执行。

必须输出：

```md
# Validation

## Ran
- 命令或步骤（Agent 已执行）

## Result
- 通过 / 失败 / 部分通过

## Not Run
- 未运行的验证及原因
```

### 6. 提交前检查

```md
# Commit Readiness

## Independent Change
这个 commit 是否只做一件事？

## No Unrelated Diff
是否存在无关改动？

## Tests
验证了什么？

## Rollback
如何撤销？是否只需 revert commit？

## Risks
还有什么风险？
```

推荐 commit message：

```text
type(scope): summary

Why:
What:
Validation:
Rollback:
```

## 停止条件

满足以下条件时停止实现：

- 当前独立功能完成
- 验收标准可验证
- 无 P0/P1/P2 已知问题
- P3 已修复或明确 defer 理由
- 已说明验证和回滚

不要继续做下一个功能，除非用户明确要求。
