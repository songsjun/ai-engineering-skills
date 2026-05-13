#!/usr/bin/env bash
# General Skills Installer
# Sets up skills for Claude Code (global slash commands) and Codex CLI (AGENTS.md).
#
# Usage:
#   ./install.sh                  # Claude Code global install + generate AGENTS.md
#   ./install.sh --project /path  # Also symlink AGENTS.md into a specific project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CLAUDE_COMMANDS="$HOME/.claude/commands"
PROJECT_DIR=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project|-p)
      PROJECT_DIR="${2:?'--project requires a path'}"
      shift 2
      ;;
    --help|-h)
      echo "Usage: install.sh [--project /path/to/project]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

echo "=== General Skills Installer ==="
echo ""

# ── 1. Claude Code: global slash commands ──────────────────────────────────
echo "[ Claude Code ] Installing global slash commands..."
mkdir -p "$CLAUDE_COMMANDS"

installed=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  target="$CLAUDE_COMMANDS/$skill_name.md"
  # Remove stale symlink or file, then create fresh symlink
  rm -f "$target"
  ln -s "${skill_dir%/}/SKILL.md" "$target"
  echo "  /$skill_name"
  ((installed++)) || true
done

echo "  → $installed commands linked to $CLAUDE_COMMANDS"
echo ""

# ── 2. Codex CLI: generate AGENTS.md ───────────────────────────────────────
echo "[ Codex CLI ] Generating AGENTS.md..."
bash "$SCRIPT_DIR/generate-agents.sh"
echo ""

# ── 3. Optional: link AGENTS.md into a project ─────────────────────────────
if [[ -n "$PROJECT_DIR" ]]; then
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: project directory '$PROJECT_DIR' does not exist." >&2
    exit 1
  fi
  target="$PROJECT_DIR/AGENTS.md"
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Warning: $target exists and is not a symlink. Skipping to avoid overwrite."
    echo "  To proceed manually: ln -sf $SCRIPT_DIR/AGENTS.md $target"
  else
    rm -f "$target"
    ln -s "$SCRIPT_DIR/AGENTS.md" "$target"
    echo "[ Codex CLI ] Linked AGENTS.md → $PROJECT_DIR/"
  fi
  echo ""
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo "=== Done ==="
echo ""
echo "Claude Code : slash commands active globally. Type /debug, /spec, etc."
echo "Codex CLI   : copy or symlink general/AGENTS.md to your project root."
if [[ -z "$PROJECT_DIR" ]]; then
  echo ""
  echo "  To link into a project:"
  echo "  ./install.sh --project /path/to/your/project"
fi
