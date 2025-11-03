#!/usr/bin/env bash
set -euo pipefail

# Copy .claude command prompts into Codex's prompts directory so they are available everywhere.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_COMMANDS_DIR="$PWD/.claude/commands"
CLAUDE_COMMANDS_DIR="${CLAUDE_COMMANDS_DIR:-$DEFAULT_COMMANDS_DIR}"


if [[ ! -d "$CLAUDE_COMMANDS_DIR" ]]; then
  echo "error: missing Claude commands directory at $CLAUDE_COMMANDS_DIR" >&2
  exit 1
fi

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PROMPTS_DIR="$CODEX_HOME/prompts"

mkdir -p "$PROMPTS_DIR"

copy_prompt() {
  local src="$1"
  local dest="$2"

  local src_path="$CLAUDE_COMMANDS_DIR/$src"
  local dest_path="$PROMPTS_DIR/$dest"

  if [[ ! -f "$src_path" ]]; then
    echo "warning: source prompt missing: $src_path" >&2
    return
  fi

  rm -f "$dest_path"
  cp "$src_path" "$dest_path"
}

for path in "$CLAUDE_COMMANDS_DIR"/*.md; do
  base="$(basename "$path")"
  copy_prompt "$base" "$base"
done

while read -r src dest || [[ -n "${src:-}" ]]; do
  [[ -z "${src:-}" ]] && continue
  copy_prompt "$src" "$dest"
done <<'ALIASES'
ci_commit.md ci-commit.md
ci_describe_pr.md ci-describe-pr.md
create_handoff.md handoff-create.md
resume_handoff.md handoff-resume.md
create_plan.md plan.md
create_plan_generic.md plan-generic.md
create_plan_nt.md plan-nt.md
create_worktree.md create-worktree.md
describe_pr.md describe-pr.md
founder_mode.md founder-mode.md
implement_plan.md implement.md
iterate_plan.md iterate.md
local_review.md local-review.md
oneshot_plan.md oneshot-plan.md
ralph_impl.md ralph-impl.md
ralph_plan.md ralph-plan.md
ralph_research.md ralph-research.md
research_codebase.md research.md
research_codebase_generic.md research-generic.md
research_codebase_nt.md research-nt.md
validate_plan.md validate-plan.md
ALIASES

echo "Copied prompts into $PROMPTS_DIR"
