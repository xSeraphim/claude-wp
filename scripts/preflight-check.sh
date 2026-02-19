#!/usr/bin/env bash
# WordPress Skill Preflight Check
# Validates a project is ready for linting and free of template placeholders.
#
# Usage:
#   bash preflight-check.sh <project-directory>

set -u -o pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: bash preflight-check.sh <project-directory>"
    exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project directory does not exist: $PROJECT_DIR"
    exit 1
fi

WARNINGS=0
ERRORS=0

check_file() {
    local file="$1"
    if [ ! -f "$PROJECT_DIR/$file" ]; then
        echo "WARN: Missing recommended file: $file"
        WARNINGS=$((WARNINGS + 1))
    fi
}

check_placeholders() {
    local file="$1"
    if [ -f "$PROJECT_DIR/$file" ]; then
        if rg -n "CHANGE-ME|change_me|my-project" "$PROJECT_DIR/$file" >/dev/null 2>&1; then
            echo "ERROR: Placeholder value found in $file"
            rg -n "CHANGE-ME|change_me|my-project" "$PROJECT_DIR/$file" || true
            ERRORS=$((ERRORS + 1))
        fi
    fi
}

echo "=========================================="
echo " WordPress Skill Preflight Check"
echo "=========================================="
echo "Project: $PROJECT_DIR"
echo ""

echo "--- Recommended Config Files ---"
check_file "phpcs.xml.dist"
check_file ".eslintrc.json"
check_file ".stylelintrc.json"
check_file "composer.json"
check_file "package.json"
echo ""

echo "--- Placeholder Scan ---"
check_placeholders "phpcs.xml.dist"
check_placeholders "composer.json"
check_placeholders "package.json"
check_placeholders ".eslintrc.json"
check_placeholders ".stylelintrc.json"
echo ""

echo "--- Plugin Header Check ---"
if rg -n --glob '*.php' 'Plugin Name:' "$PROJECT_DIR" >/dev/null 2>&1; then
    echo "PASS: Found at least one plugin header (Plugin Name:)"
else
    echo "WARN: No plugin header found. If this is a plugin, add a main file header."
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=========================================="
if [ "$ERRORS" -gt 0 ]; then
    echo " RESULT: FAILED ($ERRORS error(s), $WARNINGS warning(s))"
    echo "=========================================="
    exit 1
fi

echo " RESULT: PASS ($WARNINGS warning(s))"
echo "=========================================="
exit 0
