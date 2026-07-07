#!/usr/bin/env bash
# Installs ONLY the guideline-review skill for Claude Code (global) and/or
# GitHub Copilot CLI (repo-local). Other skillforge skills, if any, have
# their own install-<skill>.sh script and are not touched by this one.
set -euo pipefail

REPO_URL="https://github.com/Manichandra438/skillforge.git"
SKILL_REL_PATH="plugins/guideline-review/skills/guideline-review"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

TARGET_DIR="."
DO_CLAUDE=1
DO_COPILOT=1

while [ $# -gt 0 ]; do
  case "$1" in
    --claude-only) DO_COPILOT=0 ;;
    --copilot-only) DO_CLAUDE=0 ;;
    --dir) TARGET_DIR="$2"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# Resolve source of skill files: use local checkout if present (script run from a
# clone), otherwise shallow-clone into a temp dir (script run via curl | bash).
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/$SKILL_REL_PATH" ]; then
  SRC="$SCRIPT_DIR"
else
  SRC="$(mktemp -d)"
  git clone --depth 1 "$REPO_URL" "$SRC" >/dev/null
fi

if [ "$DO_CLAUDE" = "1" ]; then
  mkdir -p "$HOME/.claude/skills"
  cp -r "$SRC/$SKILL_REL_PATH" "$HOME/.claude/skills/guideline-review"
  echo "Claude Code: installed guideline-review skill -> $HOME/.claude/skills/guideline-review/SKILL.md"
fi

if [ "$DO_COPILOT" = "1" ]; then
  mkdir -p "$TARGET_DIR/.github/skills"
  cp -r "$SRC/$SKILL_REL_PATH" "$TARGET_DIR/.github/skills/guideline-review"
  echo "Copilot CLI: installed guideline-review skill -> $TARGET_DIR/.github/skills/guideline-review/SKILL.md"
fi

echo "Done. Run /review-guidelines in a project with docs/ENGINEERING_GUIDELINES.md."
