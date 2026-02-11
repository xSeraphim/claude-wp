#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/wordpress-dev"

echo "════════════════════════════════════════"
echo "║   Claude WP - Uninstaller            ║"
echo "════════════════════════════════════════"
echo ""

if [ -d "${SKILL_DIR}" ]; then
    rm -rf "${SKILL_DIR}"
    echo "✓ Removed ${SKILL_DIR}"
else
    echo "⚠  Skill directory not found at ${SKILL_DIR}"
    echo "  Nothing to uninstall."
fi

echo ""
echo "✓ Claude WP uninstalled."
