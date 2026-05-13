#!/usr/bin/env bash
# Generates AGENTS.md for Codex CLI from individual SKILL.md files.
# Run this script whenever any SKILL.md is updated.
# DO NOT edit AGENTS.md directly — edit the corresponding SKILL.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
OUTPUT="$SCRIPT_DIR/AGENTS.md"

# Collect skills in alphabetical order
skill_dirs=()
while IFS= read -r -d '' d; do
  skill_dirs+=("$d")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

skill_count=${#skill_dirs[@]}

{
cat << 'HEADER'
# General Skills — Codex CLI

> **自动生成文件，请勿手动编辑。**
> 修改 `skills/*/SKILL.md`，然后运行 `install.sh` 重新生成此文件。

## 使用方式

当用户请求匹配某个 skill 的触发条件（见各 skill 的 description 字段）时：
1. 识别对应 skill
2. 按照该 skill 的完整步骤执行，不跳过任何步骤
3. 遵守 skill 内定义的停止条件和人工决策点

Skill 之间的互斥关系见各自的 description 字段（"Do NOT use ... use X instead"）。

HEADER

# Build skill index table
echo "## Skill 索引"
echo ""
echo "| Skill | 触发场景 |"
echo "|---|---|"
for skill_dir in "${skill_dirs[@]}"; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  # Extract description field from frontmatter (first non-empty value after "description:")
  description=$(grep -m1 "^description:" "$skill_file" | sed 's/^description:[[:space:]]*//')
  # Take first sentence (up to first period or 100 chars)
  short_desc=$(echo "$description" | cut -c1-120)
  echo "| \`$skill_name\` | $short_desc |"
done
echo ""
echo "---"
echo ""

# Embed each skill's full content
for skill_dir in "${skill_dirs[@]}"; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  # Strip YAML frontmatter (content between first and second --- line)
  # Then print the body
  awk '
    BEGIN { count=0; body=0 }
    /^---$/ { count++; if (count==2) body=1; next }
    body { print }
  ' "$skill_file"

  echo ""
  echo "---"
  echo ""
done

} > "$OUTPUT"

echo "Generated: $OUTPUT ($skill_count skills, $(wc -l < "$OUTPUT") lines)"
