#!/usr/bin/env bash
# WordPress Full-Stack Linter
# Runs PHPCS, ESLint, and Stylelint against a project directory.
#
# Usage:
#   bash lint-all.sh <project-directory> [--fix] [--php-only] [--js-only] [--css-only]
#
# Works on: Linux, macOS, WSL, Git Bash (Windows)

set -u -o pipefail

if [ -z "$1" ]; then
    echo "Usage: bash lint-all.sh <project-directory> [--fix] [--php-only] [--js-only] [--css-only]"
    exit 1
fi

PROJECT_DIR="$1"
shift

FIX=false
RUN_PHP=true
RUN_JS=true
RUN_CSS=true

for arg in "$@"; do
    case $arg in
        --fix)      FIX=true ;;
        --php-only) RUN_JS=false; RUN_CSS=false ;;
        --js-only)  RUN_PHP=false; RUN_CSS=false ;;
        --css-only) RUN_PHP=false; RUN_JS=false ;;
    esac
done

# Resolve tool paths (handle both Unix and Windows-style vendor/bin).
PHPCS="$PROJECT_DIR/vendor/bin/phpcs"
PHPCBF="$PROJECT_DIR/vendor/bin/phpcbf"
ESLINT="$PROJECT_DIR/node_modules/.bin/eslint"
STYLELINT="$PROJECT_DIR/node_modules/.bin/stylelint"

TOTAL_ERRORS=0

echo "=========================================="
echo " WordPress Full-Stack Linter"
echo "=========================================="
echo "Project:  $PROJECT_DIR"
echo "Auto-fix: $FIX"
echo ""

# --- PHP ---
if [ "$RUN_PHP" = true ]; then
    echo "--- PHP (PHPCS) ---"
    if [ -f "$PHPCS" ] || [ -f "$PHPCS.bat" ]; then
        STANDARD="WordPress"
        for candidate in phpcs.xml.dist phpcs.xml .phpcs.xml.dist .phpcs.xml; do
            if [ -f "$PROJECT_DIR/$candidate" ]; then
                STANDARD="$PROJECT_DIR/$candidate"
                echo "Config: $candidate"
                break
            fi
        done

        if [ "$FIX" = true ] && { [ -f "$PHPCBF" ] || [ -f "$PHPCBF.bat" ]; }; then
            echo "[PHPCBF] Auto-fixing..."
            "$PHPCBF" --standard="$STANDARD" --extensions=php \
                --ignore="*/vendor/*,*/node_modules/*,*/build/*" \
                "$PROJECT_DIR" 2>&1 || true
        fi

        "$PHPCS" --standard="$STANDARD" --extensions=php --colors -s \
            --ignore="*/vendor/*,*/node_modules/*,*/build/*" \
            --report-full --report-summary \
            "$PROJECT_DIR" 2>&1
        result=$?

        if [ $result -eq 0 ]; then
            echo "PHP: PASSED"
        elif [ $result -eq 2 ]; then
            echo "PHP: WARNINGS ONLY (acceptable)"
        else
            echo "PHP: ERRORS FOUND"
            TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
        fi
    else
        echo "PHPCS not installed. Skipping."
    fi
    echo ""
fi

# --- JavaScript ---
if [ "$RUN_JS" = true ]; then
    echo "--- JavaScript (ESLint) ---"
    if [ -f "$ESLINT" ] || [ -f "$ESLINT.cmd" ]; then
        if find "$PROJECT_DIR" \( -name "*.js" -o -name "*.jsx" \) \
            -not -path "*/node_modules/*" \
            -not -path "*/vendor/*" \
            -not -path "*/build/*" \
            -not -path "*/.git/*" \
            -print -quit 2>/dev/null | grep -q .; then
            FIX_FLAG=""
            if [ "$FIX" = true ]; then
                FIX_FLAG="--fix"
            fi

            find "$PROJECT_DIR" \( -name "*.js" -o -name "*.jsx" \) \
                -not -path "*/node_modules/*" \
                -not -path "*/vendor/*" \
                -not -path "*/build/*" \
                -not -path "*/.git/*" \
                -print0 2>/dev/null | xargs -0 "$ESLINT" $FIX_FLAG --no-error-on-unmatched-pattern 2>&1
            result=$?

            if [ $result -eq 0 ]; then
                echo "JS: PASSED"
            else
                echo "JS: ERRORS FOUND"
                TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
            fi
        else
            echo "No JS files found. Skipping."
        fi
    else
        echo "ESLint not installed. Skipping."
    fi
    echo ""
fi

# --- CSS ---
if [ "$RUN_CSS" = true ]; then
    echo "--- CSS (Stylelint) ---"
    if [ -f "$STYLELINT" ] || [ -f "$STYLELINT.cmd" ]; then
        if find "$PROJECT_DIR" \( -name "*.css" -o -name "*.scss" \) \
            -not -path "*/node_modules/*" \
            -not -path "*/vendor/*" \
            -not -path "*/build/*" \
            -not -path "*/.git/*" \
            -print -quit 2>/dev/null | grep -q .; then
            FIX_FLAG=""
            if [ "$FIX" = true ]; then
                FIX_FLAG="--fix"
            fi

            find "$PROJECT_DIR" \( -name "*.css" -o -name "*.scss" \) \
                -not -path "*/node_modules/*" \
                -not -path "*/vendor/*" \
                -not -path "*/build/*" \
                -not -path "*/.git/*" \
                -print0 2>/dev/null | xargs -0 "$STYLELINT" $FIX_FLAG 2>&1
            result=$?

            if [ $result -eq 0 ]; then
                echo "CSS: PASSED"
            else
                echo "CSS: ERRORS FOUND"
                TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
            fi
        else
            echo "No CSS/SCSS files found. Skipping."
        fi
    else
        echo "Stylelint not installed. Skipping."
    fi
    echo ""
fi

# --- Summary ---
echo "=========================================="
if [ $TOTAL_ERRORS -eq 0 ]; then
    echo " RESULT: ALL CHECKS PASSED"
    echo "=========================================="
    exit 0
else
    echo " RESULT: $TOTAL_ERRORS LINTER(S) REPORTED ERRORS"
    echo "=========================================="
    echo ""
    echo "Fix the errors and re-run:"
    echo "  bash lint-all.sh $PROJECT_DIR --fix"
    exit 1
fi
