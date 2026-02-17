#!/usr/bin/env bash
set -euo pipefail

# Claude WP Installer
# Wraps everything in main() to prevent partial execution on network failure

main() {
    SKILL_DIR="${HOME}/.claude/skills/wordpress-dev"
    REPO_URL="https://github.com/xSeraphim/claude-wp"

    echo "════════════════════════════════════════"
    echo "║   Claude WP - Installer              ║"
    echo "║   WordPress Development Skill        ║"
    echo "════════════════════════════════════════"
    echo ""

    # Check prerequisites
    command -v git >/dev/null 2>&1 || { echo "✗ Git is required but not installed."; exit 1; }
    echo "✓ Git detected"

    # Optional: check for PHP/Composer/npm
    command -v php >/dev/null 2>&1 && echo "✓ PHP detected" || echo "⚠  PHP not found (optional — needed for PHPCS linting)"
    command -v composer >/dev/null 2>&1 && echo "✓ Composer detected" || echo "⚠  Composer not found (optional — needed for PHPCS linting)"
    command -v npm >/dev/null 2>&1 && echo "✓ npm detected" || echo "⚠  npm not found (optional — needed for ESLint/Stylelint)"
    echo ""

    # Create skill directory
    mkdir -p "${SKILL_DIR}"

    # Clone to temp directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf ${TEMP_DIR}" EXIT

    echo "↓ Downloading Claude WP..."
    git clone --depth 1 "${REPO_URL}" "${TEMP_DIR}/claude-wp" 2>/dev/null

    SRC="${TEMP_DIR}/claude-wp"

    # Copy core skill files
    echo "→ Installing skill files..."
    cp "${SRC}/SKILL.md" "${SKILL_DIR}/"
    cp "${SRC}/CLAUDE.md" "${SKILL_DIR}/"

    # Copy references
    if [ -d "${SRC}/references" ]; then
        mkdir -p "${SKILL_DIR}/references"
        cp -r "${SRC}/references/"* "${SKILL_DIR}/references/"
        echo "  ✓ References: standards, security, WooCommerce, recipes, performance, testing, FSE, MCP"
    fi

    # Copy templates
    if [ -d "${SRC}/templates" ]; then
        mkdir -p "${SKILL_DIR}/templates"
        cp -r "${SRC}/templates/"* "${SKILL_DIR}/templates/"
        # Also copy dotfiles/dirs that cp * might miss
        cp "${SRC}/templates/".* "${SKILL_DIR}/templates/" 2>/dev/null || true
        if [ -d "${SRC}/templates/.github" ]; then
            mkdir -p "${SKILL_DIR}/templates/.github"
            cp -r "${SRC}/templates/.github/"* "${SKILL_DIR}/templates/.github/"
        fi
        echo "  ✓ Templates: configs, tests bootstrap, and CI workflow"
    fi

    # Copy scripts
    if [ -d "${SRC}/scripts" ]; then
        mkdir -p "${SKILL_DIR}/scripts"
        cp -r "${SRC}/scripts/"* "${SKILL_DIR}/scripts/"
        chmod +x "${SKILL_DIR}/scripts/"*.sh 2>/dev/null || true
        echo "  ✓ Scripts: setup-environment, preflight-check, lint-all (Bash + PowerShell)"
    fi

    echo ""
    echo "✓ Claude WP installed successfully!"
    echo ""
    echo "Installed to: ${SKILL_DIR}"
    echo ""
    echo "Usage:"
    echo "  1. Start Claude Code:  claude"
    echo "  2. Ask for WP code:    \"Create a WordPress plugin that...\""
    echo "  3. Claude will automatically follow WordPress coding standards"
    echo ""
    echo "Optional — set up linting in a project:"
    echo "  bash ${SKILL_DIR}/scripts/setup-environment.sh /path/to/your/wp-project"
    echo ""
    echo "To uninstall:"
    echo "  curl -fsSL ${REPO_URL}/raw/main/uninstall.sh | bash"
}

main "$@"
