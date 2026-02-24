#!/usr/bin/env bash
set -euo pipefail

# dcg-antigravity-skill installer
# Installs the dcg-guard skill for Google Antigravity IDE

SKILL_DIR="$HOME/.gemini/antigravity/skills/dcg-guard"
SKILL_FILE="$SKILL_DIR/SKILL.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILL="$SCRIPT_DIR/SKILL.md"

echo "dcg-antigravity-skill installer"
echo "================================"
echo ""

# Check prerequisites
if ! command -v dcg >/dev/null 2>&1; then
  echo "ERROR: dcg (Destructive Command Guard) is not installed."
  echo ""
  echo "Install dcg first:"
  echo '  curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/main/install.sh" | bash -s -- --easy-mode'
  echo ""
  echo "Then re-run this installer."
  exit 1
fi

echo "✓ dcg found: $(command -v dcg)"
DCG_VERSION=$(dcg --version 2>/dev/null || echo "unknown")
echo "  Version: $DCG_VERSION"
echo ""

# Check if Antigravity is installed
if [ ! -d "$HOME/.gemini/antigravity" ]; then
  if command -v antigravity >/dev/null 2>&1; then
    echo "Creating Antigravity config directory..."
    mkdir -p "$HOME/.gemini/antigravity"
  else
    echo "WARNING: Antigravity IDE config directory not found (~/.gemini/antigravity/)"
    echo ""
    read -p "Install skill anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
fi

# Check if already installed
if [ -f "$SKILL_FILE" ] && grep -q 'dcg' "$SKILL_FILE" 2>/dev/null; then
  echo "✓ dcg-guard skill is already installed at:"
  echo "  $SKILL_FILE"
  echo ""
  read -p "Reinstall/update? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "No changes made."
    exit 0
  fi
fi

# Install the skill
mkdir -p "$SKILL_DIR"
cp "$SOURCE_SKILL" "$SKILL_FILE"

echo ""
echo "✓ Installed dcg-guard skill to:"
echo "  $SKILL_FILE"
echo ""
echo "The Antigravity agent will now check commands through dcg"
echo "before executing them."
echo ""
echo "To verify dcg is working (safe — never executes commands):"
echo '  dcg test "git reset --hard"    # should show BLOCKED'
echo '  dcg test "git status"          # should show ALLOWED'
echo ""
echo "To configure dcg for Antigravity, add to ~/.config/dcg/config.toml:"
echo '  [agents.antigravity]'
echo '  trust_level = "medium"'
