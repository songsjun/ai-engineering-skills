---
name: code-review
description: Structured code review across three independent dimensions: correctness, security, maintainability. Use for reviewing OTHERS' code or PRs before approving. Triggers: review this PR, 帮我 review 一下这个 PR, 代码审查, review this code. Do NOT use for gating your OWN commits — use review-gate for that.
---

# Code Review（代码审查）

三个独立维度的结构化审查：正确性、安全性、可维护性。

## 范围说明

**本 skill 不覆盖性能分析。** 性能问题需要 profiling 数据，静态审查无法可靠判断。如需性能审查，明确告知用户需要运行时数据。

## 严重程度

- **BLOCK**：合并前必须修复。Bug、安全漏洞或数据丢失风险。
- **WARN**：应当修复。可能引发问题或困惑。
- **SUGGEST**：可选改进。优先级低，可推迟。

## 步骤零：获取审查材料

- 用户粘贴了 diff/代码 → 直接使用
- 用户提供了文件路径 → Agent 直接读取
- 用户没有提供 → 询问："请粘贴需要审查的 diff 或代码文件，或者提供文件路径"

**在有审查材料之前不开始审查。**

## 步骤一：理解变更

审查前确认：
- 这段代码变更做什么？
- 有没有对应的 spec 或 ticket 可以核对？
- 变更范围是什么？（新功能、Bug 修复、重构、性能优化）

## 步骤二：并行三维审查

启动**三个并行 subagent**，每个只负责一个维度：

**Subagent 1（正确性）：**
```
你是一位专注于代码正确性的审查者。只审查以下一个维度。

代码变更：[完整 diff 或代码]
变更意图：[一句话说明]

请检查：
- 代码是否实现了声称的功能？
- 边界情况是否处理了？（null/undefined、空集合、边界值、并发访问）
- 错误处理是否正确？
- 逻辑是否与变更意图一致？
- 是否处理了外部依赖失败的情况？

格式：[BLOCK/WARN/SUGGEST] 正确性 — [标签] | [问题] | [建议]
```

**Subagent 2（安全性）：**
```
你是一位专注于代码安全性的审查者。只审查以下一个维度。

代码变更：[完整 diff 或代码]
变更意图：[一句话说明]

请检查：
- 注入风险：用户输入是否在未过滤情况下用于 SQL、shell 命令或 HTML 输出？
- 认证问题：受保护操作是否有访问检查？token/session 是否正确处理？
- 敏感数据：密码、token 或 PII 是否被日志记录、明文存储或暴露在响应中？
- 输入验证：外部输入在使用前是否经过验证？
- 新依赖：如有新引入的依赖，标记出来，提示用户运行 npm audit / pip-audit 等工具验证。
- 错误信息：是否向用户暴露内部堆栈或系统细节？

格式：[BLOCK/WARN/SUGGEST] 安全性 — [标签] | [问题] | [建议]
```

**Subagent 3（可维护性）：**
```
你是一位专注于代码可维护性的审查者。只审查以下一个维度。

代码变更：[完整 diff 或代码]
变更意图：[一句话说明]

请检查：
- 命名是否清晰准确？（变量、函数、类）
- 函数职责是否单一？
- 是否有重复代码应该提取？
- 不逐行阅读，代码意图是否可理解？
- 新逻辑是否有对应测试？
- 下一个开发者能理解"为什么"，而不只是"是什么"吗？

格式：[BLOCK/WARN/SUGGEST] 可维护性 — [标签] | [问题] | [建议]
```

**合并规则：**
- 按 BLOCK → WARN → SUGGEST 严重程度分组
- 同一代码位置的多维度问题合并为一条，注明涉及维度
- 维度冲突时取更严重的级别，注明两方分析

## 步骤三：输出报告

```
**[严重程度] [维度] — [简短标签]**
文件：[文件名]，行：[N]
问题：[具体说明]
建议：[具体修复方向]
```

## 步骤四：总结

- BLOCK / WARN / SUGGEST 各自数量
- 最终结论：
  - **APPROVED**：可以合并
  - **APPROVED WITH SUGGESTIONS**：可以合并，SUGGEST 项可跟进
  - **CHANGES REQUESTED**：有 BLOCK 项，必须解决后再合并
- 如果 CHANGES REQUESTED：列出具体 BLOCK 项

## 审查原则

- 批准能改善代码库的代码，即使不完美
- 不要求完美——只要求正确性、安全性和足够的可维护性
- 留下具体、可操作的评论
- **不因个人风格偏好阻塞合并**（除非有 linter/style guide 明确规定）
