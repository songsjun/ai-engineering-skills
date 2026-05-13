---
name: review-gate
description: Gate for YOUR OWN changes before commit/merge — classifies bugs P0-P4, checks tests and rollback safety, auto-resolves P2-P3, escalates P0-P1 to human. Use AFTER implementation-loop or tdd. Triggers: 提交前检查, 验收这个功能, 找 bug. Do NOT use for reviewing OTHER people's code or PRs — use code-review for that.
---

# Review Gate

审查**自己刚写的**改动，找出 bug、架构风险、测试缺口和回滚风险。
**BLOCKED 不是终点：** Agent 根据严重级别自主处理或升级。

**必须用独立 subagent 执行审查。** 不传入实现过程的对话历史，只传入 diff 和验收标准。这是防止自我确认偏差的关键——Agent 审查自己刚写的代码时，倾向于验证而非质疑自己的心智模型。

## 触发场景

- "review 这次改动" / "找 bug" / "提交前检查"
- "验收这个功能" / "看看模块划分和接口是否合理"

## 审查范围

必须检查：
- 是否满足原始需求和验收标准
- 是否存在无关 diff 或需求膨胀
- 模块边界是否清晰
- 接口是否过宽、过抽象或命名不清
- 数据流是否简单明了
- 是否引入不必要依赖
- 是否破坏兼容性
- 是否有测试或可运行验证
- 是否可以安全回滚

## Bug 严重级别

```text
P0：安全问题、数据丢失、核心系统不可用。
P1：主流程不可用，严重阻塞用户。
P2：重要功能错误，但存在 workaround。
P3：边界问题、体验问题、维护风险、潜在不稳定。
P4：风格、微优化、非阻塞建议。
```

## BLOCKED 后的 Agent 行为（关键补充）

review-gate 输出 BLOCKED 后，Agent 不停止，按以下规则处理：

### P0 / P1：立即升级人工

```md
## ESCALATION REQUIRED

严重级别：P0/P1
问题：[精确描述，含文件路径和行号]
影响：[如果不修复会发生什么]
推荐行动：[Agent 的修复建议，供人工决策参考]

Agent 已停止所有代码修改，等待人工指令。
请选择：
A) 接受 Agent 建议的修复方向，Agent 继续
B) 回滚本次改动
C) 提供其他指令
```

**P0/P1 是唯一需要人工决策的场景。**

### P2：Agent 自主修复

条件：必须**同时满足**以下所有条件（可在修复前预判，不依赖写完后计行数）：
- 修复只涉及单一函数或方法内部逻辑
- 不新增或修改公共接口（函数签名、导出类型、API 契约）
- 不跨文件修改（只改一个文件）
- 修复不涉及权限、认证、数据持久化逻辑

不满足任一条件 → 升级为 P1，等待人工决策。

```md
## P2 AUTO-FIX

问题：[描述]
满足自主修复条件：[逐条确认]
修复：[代码变更]
修复后自动重新运行 review-gate。
```

### P3：Agent 自主处理

优先级：修复 > 加测试 > defer。

**defer 的门槛（必须同时满足，不接受自由文本理由）：**
- 影响范围：仅影响边缘路径或极低频操作（说明具体场景）
- 有可验证的 follow-up 记录（文件路径 + 描述，或 ticket 编号）

```md
## P3 Resolution
- [问题]：已修复 / 已加测试覆盖 / defer（影响范围：[具体说明]，follow-up：[路径或编号]）
```

### P4：记录即可

不修改代码。仅在报告中列出。

## 审查方法

### 1. 先理解意图

```text
这次改动想解决什么问题？
明确不做什么？
验收标准是什么？
```

### 2. 审查 diff

重点看：
- 代码是否只服务当前目标
- 是否误改无关路径
- 是否存在 hidden assumption
- 是否在错误层级放置逻辑
- 是否遗漏错误处理、边界条件、权限、并发、空值、兼容性

### 3. 审查测试

检查：
- 是否覆盖主路径
- 是否覆盖关键边界
- 是否有回归测试
- 是否只测实现细节（不是行为）
- Agent 直接运行现有测试套件，确认通过

### 4. 审查架构

```text
模块划分是否仍然合理？
接口是否清晰、窄、稳定？
流程是否能用几句话解释？
是否引入了不必要抽象？
如果这个设计错了，是否容易撤销？
```

## 输出格式

```md
# Review Report

## Verdict
PASS / PASS_WITH_NOTES / BLOCKED

## Summary
一句话说明这次改动是否可以接受。

## Issues
| Severity | Location | Problem | Agent Action |
|---|---|---|---|
| P? | file:line | 问题 | 自主修复 / 已 defer / 等待人工 |

## Architecture Check
- 模块边界：
- 接口清晰度：
- 流程复杂度：
- 是否过度设计：

## Test Check
- 已运行：[命令和结果]
- 覆盖情况：
- 缺口：

## Rollback Check
- 是否可独立 revert：
- 回滚风险：

## Required Before Merge
- [ ] 必须完成项

## Deferred Items
| Item | Reason | Risk |
|---|---|---|
```

## 通过标准

只有同时满足以下条件才给 `PASS`：
- 无 P0/P1/P2
- P3 已处理或有合理 defer
- 验收标准被满足
- 测试套件通过（Agent 已运行）
- 回滚路径清楚
- 无明显需求膨胀或架构偏差

如果无法判断，给 `PASS_WITH_NOTES` 或 `BLOCKED`，说明缺少什么证据。
