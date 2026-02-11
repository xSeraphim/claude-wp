# claude-wp

A Claude Code skill for WordPress development. Generates production-quality WordPress code that passes PHPCS, ESLint, and Stylelint with zero errors out of the box.

## What's included

| Path | Purpose |
|---|---|
| `SKILL.md` | Skill entry point — decision matrix, workflow, critical rules |
| `CLAUDE.md` | Claude Code integration file |
| `references/php-standards.md` | PHP coding standards (PHPCS WordPress ruleset) |
| `references/js-standards.md` | JavaScript standards (ESLint @wordpress/eslint-plugin) |
| `references/css-standards.md` | CSS standards (Stylelint @wordpress/stylelint-config) |
| `references/security-checklist.md` | Security patterns — escaping, sanitization, nonces, SQL |
| `references/woocommerce.md` | WooCommerce-specific hooks, HPOS, CRUD API |
| `templates/` | Ready-to-copy config files (phpcs.xml.dist, eslintrc, etc.) |
| `scripts/` | Cross-platform setup and linting scripts |

## Installation

### Option 1: Clone into your project (recommended)

```bash
# From your WordPress project root
git clone https://github.com/YOUR_USERNAME/claude-wp.git .claude-wp

# Add to your project's CLAUDE.md
echo "Read and follow all standards from .claude-wp/CLAUDE.md" >> CLAUDE.md
```

### Option 2: Global install for all WP projects

**Linux / macOS:**
```bash
git clone https://github.com/YOUR_USERNAME/claude-wp.git ~/.claude-skills/wordpress-dev
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/YOUR_USERNAME/claude-wp.git "$env:USERPROFILE\.claude-skills\wordpress-dev"
```

Then reference it in your project's `CLAUDE.md`:
```markdown
For WordPress development, read and follow the skill at ~/.claude-skills/wordpress-dev/CLAUDE.md
```

### Option 3: Use as Claude Code project instructions

Add to `~/.claude/CLAUDE.md` (global) or your project's `CLAUDE.md`:
```markdown
When working on WordPress code, read the skill files at <path-to-claude-wp>/SKILL.md and follow all referenced standards.
```

## Setting up linting

After cloning, set up the linting environment in your WP project:

**Linux / macOS / WSL / Git Bash:**
```bash
bash <path-to-claude-wp>/scripts/setup-environment.sh /path/to/your/wp-project
bash <path-to-claude-wp>/scripts/lint-all.sh /path/to/your/wp-project --fix
```

**Windows (PowerShell):**
```powershell
& <path-to-claude-wp>\scripts\setup-environment.ps1 -ProjectDir C:\path\to\your\wp-project
& <path-to-claude-wp>\scripts\lint-all.ps1 -ProjectDir C:\path\to\your\wp-project -Fix
```

## Config templates

Copy templates into your project root and customize:

```bash
cp templates/phpcs.xml.dist   your-project/phpcs.xml.dist
cp templates/.eslintrc.json   your-project/.eslintrc.json
cp templates/.stylelintrc.json your-project/.stylelintrc.json
cp templates/composer.json    your-project/composer.json
cp templates/package.json     your-project/package.json
```

Then replace placeholders:
- `CHANGE-ME` → your text domain (e.g., `my-plugin`)
- `change_me` → your function prefix (e.g., `my_plugin`)
- `my-project` → your project name

## What it covers

- **PHP**: Naming, formatting, Yoda conditions, DocBlocks, i18n, database queries, enqueuing
- **JavaScript**: jQuery patterns, modern ES6+/Gutenberg blocks, REST API, import ordering
- **CSS**: Selectors, property ordering, admin styling, RTL compatibility, SCSS
- **Security**: Output escaping, input sanitization, nonce verification, capability checks, SQL injection prevention, file operations, REST API permissions
- **WooCommerce**: HPOS compatibility, CRUD API, product/checkout/cart hooks, payment gateways, email hooks

## Requirements

For linting (optional — the reference files work standalone):
- PHP + Composer (for PHPCS)
- Node.js + npm (for ESLint + Stylelint)

## License

MIT
