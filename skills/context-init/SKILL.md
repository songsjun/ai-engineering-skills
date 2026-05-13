---
name: context-init
description: Initialize or update project context so the Agent works from real codebase evidence, not assumptions. Use at the start of a new project, when onboarding to an existing codebase, or when the Agent keeps making the same class of mistakes. Triggers: 初始化项目, 创建 CLAUDE.md, AI 老是搞错, onboard to codebase, set up project context.
---

# Context Init

让 Agent 基于真实代码库运作，而不是靠猜测。

## 核心原则

优先直接读取文件和执行命令。如遇权限拒绝（CI runner、只读挂载、沙箱环境等），记录不可访问的路径，转为询问用户该部分信息，不要卡死重试。

## 步骤一：探索代码库

直接执行，不询问用户：

```bash
ls -la
find . -maxdepth 2 -type d | head -40
```

如果某个命令因权限失败，在 CLAUDE.md 中记录"以下信息因环境限制由用户提供"，继续后续步骤。

优先读取：
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`（技术栈和依赖）
- 现有 README
- CI 配置（`.github/workflows/`、`Makefile`、`justfile`）
- 现有的 `CLAUDE.md`（如有，在此基础上更新，不要覆盖）

对从文件无法确认的信息才询问用户。不猜测。

## 步骤二：访谈用户

只问以下问题中**文件中找不到答案**的：

1. 这个项目做什么？（一段话，给新加入者看）
2. 最常用的命令是什么？（构建、测试、运行、lint）
3. 团队遵守哪些约定？（命名、文件结构、PR 流程）
4. **AI 在这个代码库中最常犯哪些错误？**（这条最重要）
5. 有没有未经讨论不能直接修改的文件或目录？
6. 有没有项目专有的术语或概念？

## 步骤三：创建或更新 CLAUDE.md

在项目根目录写入 `CLAUDE.md`。如果已存在，先读取再增量更新，不要覆盖已有内容。

```
# [项目名]

## 这是什么
[1-2 段。项目做什么、谁在用它。]

## 快速开始
[安装/启动/测试/构建命令，来自文件证据]

## 技术栈
- 语言：
- 框架：
- 数据库：
- 关键依赖：[非显而易见的依赖及用途]

## 项目结构
[关键目录及职责，2-3 层深]

## 代码约定
- [命名约定]
- [文件组织模式]
- [import 风格]
- [lint/format 工具]

## 重要约束（未经讨论不得违反）
- [不得修改的文件或目录]
- [自动生成的文件]
- [需要安全审查的区域]

## AI 常见错误（高优先级）
- [来自用户访谈的具体错误类型]

## 词汇表
[项目专有术语，尤其与通用含义不同的词]
```

## 步骤四：Reader 验证

写完后立即启动 subagent 验证 CLAUDE.md 的可用性：

```
你是一个刚加入项目的开发者，没有参与过任何讨论。只根据以下 CLAUDE.md 回答：

[粘贴 CLAUDE.md 全文]

1. 你能运行这个项目吗？需要哪些命令？
2. 哪些事项是你绝对不能做的？
3. 开始工作前你还有哪些问题没有答案？（不超过 5 个）
```

判断标准：
- 问题 3 超过 3 条具体问题 → 补充信息，重新测试
- 问题 1 无法回答 → 快速开始部分缺失，补充
- 问题 2 无法回答 → 重要约束部分缺失，补充

## 维护原则

以下情况必须更新 CLAUDE.md：
- 技术栈变化
- 团队采用新约定
- Agent 反复犯同一错误（加入"AI 常见错误"节）
- 新成员会感到困惑的任何地方

**过时的 CLAUDE.md 比没有更糟**——它以确定的方式误导 Agent。
