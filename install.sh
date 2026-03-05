#!/bin/bash
# Install a skill from this repo to ~/.claude/skills/
# Usage: bash install.sh <skill-name>

set -euo pipefail

SKILL_NAME="${1:-}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$REPO_DIR/skills/$SKILL_NAME"
SKILL_DST="$HOME/.claude/skills/$SKILL_NAME"

if [ -z "$SKILL_NAME" ]; then
  echo "Usage: bash install.sh <skill-name>"
  echo ""
  echo "Available skills:"
  for d in "$REPO_DIR/skills"/*/; do
    [ -d "$d" ] && echo "  $(basename "$d")"
  done
  exit 1
fi

if [ ! -d "$SKILL_SRC" ]; then
  echo "Error: Skill '$SKILL_NAME' not found in skills/"
  exit 1
fi

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "Error: No SKILL.md found in skills/$SKILL_NAME/"
  exit 1
fi

if [ -d "$SKILL_DST" ]; then
  echo "Skill '$SKILL_NAME' already exists at $SKILL_DST"
  read -p "Overwrite? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  rm -rf "$SKILL_DST"
fi

cp -r "$SKILL_SRC" "$SKILL_DST"
echo "Installed '$SKILL_NAME' to $SKILL_DST"
echo "Restart Claude Code to activate. Invoke with /$SKILL_NAME"
