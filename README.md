# claude-wp

A Claude Code skill for WordPress development. Generates production-quality WordPress code aligned with PHPCS, ESLint, and Stylelint standards.

## Quick Install

**Linux / macOS / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/xSeraphim/claude-wp/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/xSeraphim/claude-wp/main/install.ps1 | iex
```

**Manual install:**
```bash
git clone https://github.com/xSeraphim/claude-wp.git
cd claude-wp
./install.sh        # or .\install.ps1 on Windows
```

Installs to `~/.claude/skills/wordpress-dev/`.

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
| `references/task-recipes.md` | Recipe playbooks for common tasks (plugin/settings/REST/block/WC) |
| `references/performance.md` | Performance guidance (query limits, caching, assets) |
| `references/testing.md` | Testing guidance (WP_UnitTestCase/Jest strategy) |
| `references/fse.md` | Full Site Editing and block theme guidance |
| `references/mcp-wordpress.md` | Optional live-context workflow with WordPress MCP |
| `templates/` | Ready-to-copy config, tests, and CI workflow templates |
| `scripts/` | Cross-platform setup, preflight checks, and linting scripts |

## What it covers

- **PHP**: Naming, formatting, Yoda conditions, DocBlocks, i18n, database queries, enqueuing
- **JavaScript**: jQuery patterns, modern ES6+/Gutenberg blocks, REST API, import ordering
- **CSS**: Selectors, property ordering, admin styling, RTL compatibility, SCSS
- **Security**: Output escaping, input sanitization, nonce verification, capability checks, SQL injection prevention, file operations, REST API permissions
- **WooCommerce**: HPOS compatibility, CRUD API, product/checkout/cart hooks, payment gateways, email hooks
- **Preflight checks**: Detect unresolved template placeholders and missing recommended lint config files before running linters
- **Performance**: Query discipline, object/transient caching, and asset strategy guardrails
- **Testing**: Guidance and templates for PHPUnit/Jest-oriented validation
- **Modern themes**: FSE support with `theme.json` and block pattern recommendations
- **Live context**: Optional MCP workflow for inspecting active site state before coding

## Setting up linting (optional)

The reference files work standalone — Claude reads them and follows the standards. For best results, use task recipes + preflight + linting:

**Linux / macOS / WSL / Git Bash:**
```bash
bash ~/.claude/skills/wordpress-dev/scripts/setup-environment.sh /path/to/your/wp-project
bash ~/.claude/skills/wordpress-dev/scripts/preflight-check.sh /path/to/your/wp-project
bash ~/.claude/skills/wordpress-dev/scripts/lint-all.sh /path/to/your/wp-project --fix
```

**Windows (PowerShell):**
```powershell
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\setup-environment.ps1 -ProjectDir C:\path\to\your\wp-project
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\preflight-check.ps1 -ProjectDir C:\path\to\your\wp-project
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\lint-all.ps1 -ProjectDir C:\path\to\your\wp-project -Fix
```

Requires: PHP + Composer (for PHPCS) and Node.js + npm (for ESLint + Stylelint).

## Config templates

Copy templates into your project root and customize:

```bash
SKILL=~/.claude/skills/wordpress-dev
cp $SKILL/templates/phpcs.xml.dist    your-project/phpcs.xml.dist
cp $SKILL/templates/.eslintrc.json    your-project/.eslintrc.json
cp $SKILL/templates/.stylelintrc.json your-project/.stylelintrc.json
cp $SKILL/templates/composer.json     your-project/composer.json
cp $SKILL/templates/package.json      your-project/package.json
mkdir -p your-project/tests
cp $SKILL/templates/tests/phpunit-bootstrap.php your-project/tests/bootstrap.php
cp $SKILL/templates/tests/test-sample.php       your-project/tests/test-sample.php
mkdir -p your-project/.github/workflows
cp $SKILL/templates/.github/workflows/wp-standards.yml your-project/.github/workflows/wp-standards.yml
```

Then replace placeholders:
- `CHANGE-ME` → your text domain (e.g., `my-plugin`)
- `change_me` → your function prefix (e.g., `my_plugin`)
- `my-project` → your project name

## Uninstall

**Linux / macOS / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/xSeraphim/claude-wp/main/uninstall.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/xSeraphim/claude-wp/main/uninstall.ps1 | iex
```

## License

MIT
