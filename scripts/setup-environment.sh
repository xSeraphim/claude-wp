#!/usr/bin/env bash
# WordPress Development Environment Setup
# Installs PHPCS + WPCS, ESLint + WP config, Stylelint + WP config.
#
# Usage:
#   bash setup-environment.sh <project-directory>
#
# Works on: Linux, macOS, WSL, Git Bash (Windows)

set -e

if [ -z "$1" ]; then
    echo "Usage: bash setup-environment.sh <project-directory>"
    echo "Example: bash setup-environment.sh /home/user/my-wp-plugin"
    exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Creating project directory: $PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
fi

echo "=== WordPress Dev Environment Setup ==="
echo "Project directory: $PROJECT_DIR"
echo ""

cd "$PROJECT_DIR"

# --- PHP: PHPCS + WordPress Coding Standards ---

echo "--- PHP Linting Setup ---"

if ! command -v composer &> /dev/null; then
    echo "Composer not found. Attempting to install..."
    if command -v php &> /dev/null; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 2>/dev/null && \
        php composer-setup.php --install-dir="$PROJECT_DIR" --filename=composer 2>/dev/null && \
        rm -f composer-setup.php && \
        COMPOSER_CMD="$PROJECT_DIR/composer" && \
        echo "Composer installed locally." || \
        echo "WARNING: Could not install Composer. PHP linting will not be available."
    else
        echo "WARNING: PHP not found. Install PHP and Composer manually."
    fi
else
    COMPOSER_CMD="composer"
fi

if [ -n "$COMPOSER_CMD" ]; then
    # Initialize composer.json if not present.
    if [ ! -f "$PROJECT_DIR/composer.json" ]; then
        $COMPOSER_CMD init --no-interaction \
            --name="project/wordpress-dev" \
            --description="WordPress development project" \
            --stability="stable" 2>/dev/null || true
    fi

    # Install WPCS.
    $COMPOSER_CMD require --dev \
        wp-coding-standards/wpcs:"^3.0" \
        phpcompatibility/phpcompatibility-wp:"*" \
        dealerdirect/phpcodesniffer-composer-installer:"^1.0" \
        --no-interaction 2>&1 && \
    echo "PHPCS + WPCS installed." || \
    echo "WARNING: Failed to install PHPCS via Composer."

    # Verify.
    if [ -f "$PROJECT_DIR/vendor/bin/phpcs" ]; then
        echo "PHPCS version: $("$PROJECT_DIR/vendor/bin/phpcs" --version)"
        echo "Standards: $("$PROJECT_DIR/vendor/bin/phpcs" -i)"
    fi
else
    echo "SKIP: Composer unavailable. PHPCS not installed."
    echo "Rely on reference files for standards compliance."
fi

echo ""

# --- JavaScript: ESLint + WordPress Config ---

echo "--- JavaScript Linting Setup ---"

if command -v npm &> /dev/null; then
    # Initialize package.json if not present.
    if [ ! -f "$PROJECT_DIR/package.json" ]; then
        npm init -y 2>/dev/null || true
    fi

    npm install --save-dev \
        @wordpress/eslint-plugin \
        eslint 2>&1 && \
    echo "ESLint + @wordpress/eslint-plugin installed." || \
    echo "WARNING: Failed to install ESLint."

    # Create .eslintrc.json if not present.
    if [ ! -f "$PROJECT_DIR/.eslintrc.json" ]; then
        cat > "$PROJECT_DIR/.eslintrc.json" << 'ESLINTEOF'
{
    "extends": ["plugin:@wordpress/eslint-plugin/recommended"],
    "env": {
        "browser": true,
        "jquery": true
    },
    "globals": {
        "wp": "readonly",
        "ajaxurl": "readonly"
    }
}
ESLINTEOF
        echo ".eslintrc.json created."
    fi
else
    echo "SKIP: npm unavailable. ESLint not installed."
fi

echo ""

# --- CSS: Stylelint + WordPress Config ---

echo "--- CSS Linting Setup ---"

if command -v npm &> /dev/null; then
    npm install --save-dev \
        @wordpress/stylelint-config \
        stylelint 2>&1 && \
    echo "Stylelint + @wordpress/stylelint-config installed." || \
    echo "WARNING: Failed to install Stylelint."

    # Create .stylelintrc.json if not present.
    if [ ! -f "$PROJECT_DIR/.stylelintrc.json" ]; then
        cat > "$PROJECT_DIR/.stylelintrc.json" << 'STYLEEOF'
{
    "extends": "@wordpress/stylelint-config"
}
STYLEEOF
        echo ".stylelintrc.json created."
    fi
else
    echo "SKIP: npm unavailable. Stylelint not installed."
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Available commands:"
[ -f "$PROJECT_DIR/vendor/bin/phpcs" ] && echo "  vendor/bin/phpcs --standard=WordPress <file.php>"
[ -f "$PROJECT_DIR/vendor/bin/phpcbf" ] && echo "  vendor/bin/phpcbf --standard=WordPress <file.php>"
command -v npx &> /dev/null && [ -d "$PROJECT_DIR/node_modules/.bin" ] && echo "  npx eslint <file.js>"
command -v npx &> /dev/null && [ -d "$PROJECT_DIR/node_modules/.bin" ] && echo "  npx stylelint <file.css>"
