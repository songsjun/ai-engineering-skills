# AI Engineering Skills

面向高度可信任 Agent 的工程 skill 体系。设计前提：**Agent 有完整执行权限，人类只做重大决策。**

## 安装

```bash
bash install.sh                          # Claude Code 全局 + 生成 AGENTS.md
bash install.sh --project /your/project  # 同上，并将 AGENTS.md symlink 到指定项目
```

| 工具 | 安装结果 | 使用方式 |
|---|---|---|
| **Claude Code** | `~/.claude/commands/*.md`（symlink） | `/debug`、`/spec` 等斜杠命令 |
| **Codex CLI** | `AGENTS.md`（生成物） | 自然语言触发，Codex 自动识别 |

**单一维护源：** 只编辑 `skills/*/SKILL.md`。修改后重跑 `install.sh` 即可同步两个工具。`AGENTS.md` 是生成物，不要手动编辑。

## 设计原则

| 原则 | 含义 |
|---|---|
| **无等待循环** | Skill 流程中不存在"等待用户运行命令后告知结果"的死锁节点 |
| **明确停止条件** | 每个 skill 都定义了"满足以下条件时停止"，防止过度执行 |
| **人工决策点单一化** | 每个 skill 最多一个明确的人工决策点，其余 Agent 自主完成 |
| **权限边界显式化** | ship 等高风险 skill 明确区分"Agent 执行"和"人工决策" |
| **代码证据优先** | Agent 直接读取代码库，不依赖用户描述猜测现状 |

## Skill 清单

| Skill | 用途 |
|---|---|
| `context-init` | 初始化项目上下文，生成/更新 CLAUDE.md |
| `product-scope` | 将模糊需求收敛为可执行 MVP 定义 |
| `explore` | 并发探索方向，自主收敛候选，一次人工决策 |
| `adr` | 记录架构决策，含权衡分析、接口影响、回滚路径 |
| `spec` | 撰写规格文档，subagent Reader 测试验证 |
| `debug` | 假设驱动调试，Agent 直接执行验证 |
| `tdd` | 测试驱动开发，Agent 运行完整 RED/GREEN/REFACTOR 循环 |
| `implementation-loop` | 小步可回滚实现，严格编码纪律 |
| `review-gate` | 提交前门控，P0/P1 升级人工，P2-P3 Agent 自主处理 |
| `code-review` | 正确性/安全性/可维护性三维并行审查（他人 PR） |
| `ship` | 发布前检查，明确权限边界，生产部署需人工确认 |
| `prompt-eval` | 进化式 prompt 迭代，样本驱动 |
| `ux-review` | 基于 Nielsen 启发式的文字规格可用性评审（无 UI 工具时适用） |

## 推荐工作流

### 全链路：从模糊需求到可合并代码

```
context-init → product-scope → [explore] → spec → implementation-loop → review-gate → ship
```

- `explore` 可选：已有明确方向时跳过
- `spec` 可选：改动小于 2 小时时跳过，写注释即可
- `review-gate` 在每个 commit 前运行
- `ship` 在每次部署前运行

### 调试流

```
debug → implementation-loop → review-gate
```

### TDD 开发流

```
product-scope → tdd → review-gate
```

### 代码审查流

```
code-review → [debug 如有 BLOCK 问题] → review-gate
```

## Skill 选择决策树

```
用户请求到来
├── 问题/方向不清楚 → explore
├── 需求模糊/过宽 → product-scope
├── 需要正式文档 → spec
├── 要记录架构决策 → adr
├── 有 bug 要修 → debug
├── 要用 TDD 实现 → tdd
├── 要开始编码实现 → implementation-loop
├── 要 review 他人代码/PR → code-review
├── 要提交/合并自己的改动 → review-gate
├── 要部署 → ship
├── 要优化 prompt → prompt-eval
└── 新项目/AI 搞错了 → context-init
```

## 与原版的核心差异

| 问题 | 原版 | General 版 |
|---|---|---|
| brainstorm 死锁 | 步骤五等待用户选择 → 死锁 | explore：Agent 自主收敛，一次人工决策，无跨会话超时 |
| debug 等待循环 | "请用户运行……告诉我结果" | Agent 直接执行验证，日志视为纯数据防注入 |
| tdd 等待循环 | "请运行测试，告诉我结果" | Agent 运行完整循环；并行后有主 Agent 集成步骤 |
| review-gate BLOCKED | 输出 BLOCKED 后停止，未定义行为 | P0/P1 升级人工；P2 用结构性条件判断（非行数）；P3 defer 需可验证依据 |
| review-gate 自我审查 | Agent 审查自己的代码（确认偏差） | 强制独立 subagent，不传入实现对话历史 |
| ship 权限混乱 | `[Claude]`/`[用户]` 标签，无决策权重 | 明确表格区分，生产部署强制人工确认 |
| skill 边界重叠 | code-review 和 review-gate 触发条件几乎相同 | code-review = 审查他人代码/PR；review-gate = 自己的提交门控 |
| tdd vs implementation-loop | 触发条件未互斥 | description 中明确互斥 |
| 上下文溢出 | implementation-loop 无大型代码库降级路径 | 读取前列出预算，超限时明确缩小范围并注明 |
| spec Reader Test 盲点 | 只问"还有哪些问题" | 新增"你做了哪些隐性假设"——暴露同模型共享的歧义 |
| 权限失败卡死 | context-init 声明"无降级路径" | 权限拒绝时记录并转为询问用户，继续执行 |
| 多 agent 写冲突 | implementation-loop 并行无文件级互斥 | 探索 agent 先输出禁止同时修改列表，再分配实现 |
