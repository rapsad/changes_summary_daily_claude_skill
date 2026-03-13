#!/usr/bin/env bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
CONFIG_FILE="$HOME/.claude/daily-summary-config.json"
SKILL_FILE="daily-summary.md"
REPO_URL="https://raw.githubusercontent.com/rapsad/changes_summary_daily_claude_skill/main"

echo ""
echo "=== Daily Dev Summary — Claude Code Skill Installer ==="
echo ""

# --- Download or copy skill file ---

if [ -f "$SKILL_FILE" ]; then
  SKILL_SOURCE="$SKILL_FILE"
else
  echo "Downloading skill file..."
  TMP_FILE=$(mktemp)
  curl -fsSL "$REPO_URL/daily-summary.md" -o "$TMP_FILE"
  SKILL_SOURCE="$TMP_FILE"
fi

mkdir -p "$SKILLS_DIR"
cp "$SKILL_SOURCE" "$SKILLS_DIR/daily-summary.md"
echo "✓ Skill installed to $SKILLS_DIR/daily-summary.md"

# --- Config setup ---

if [ -f "$CONFIG_FILE" ]; then
  echo "✓ Config already exists at $CONFIG_FILE — skipping."
else
  echo ""
  echo "Let's set up your config."
  echo ""

  # Scan paths
  read -rp "Enter a directory to scan for git repos (e.g. ~/projects): " SCAN_PATH
  SCAN_PATH="${SCAN_PATH:-~/projects}"

  # Output directory
  read -rp "Where should summaries be saved? (default: ~/dev-summaries): " OUTPUT_DIR
  OUTPUT_DIR="${OUTPUT_DIR:-~/dev-summaries}"

  # Git author
  DETECTED_AUTHOR=$(git config --global user.name 2>/dev/null || echo "")
  DETECTED_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

  if [ -n "$DETECTED_AUTHOR" ]; then
    echo ""
    echo "Detected git author: $DETECTED_AUTHOR <$DETECTED_EMAIL>"
    read -rp "Use this as your author filter? (Y/n): " USE_DETECTED
    USE_DETECTED="${USE_DETECTED:-Y}"
    if [[ "$USE_DETECTED" =~ ^[Yy]$ ]]; then
      GIT_AUTHOR="$DETECTED_AUTHOR"
    else
      read -rp "Enter your git author name or email: " GIT_AUTHOR
    fi
  else
    read -rp "Enter your git author name or email: " GIT_AUTHOR
  fi

  cat > "$CONFIG_FILE" <<EOF
{
  "scan_paths": [
    "$SCAN_PATH"
  ],
  "output_dir": "$OUTPUT_DIR",
  "git_author": "$GIT_AUTHOR"
}
EOF

  echo ""
  echo "✓ Config saved to $CONFIG_FILE"
fi

# --- Done ---

echo ""
echo "=== Installation complete ==="
echo ""
echo "To use: open Claude Code in any directory and run:"
echo ""
echo "  /daily-summary"
echo ""
echo "To edit your config later:"
echo "  $CONFIG_FILE"
echo ""
