---
name: wordpress-dev
description: >
  Use this skill when creating, editing, or reviewing WordPress code — plugins, themes,
  WooCommerce extensions, mu-plugins, custom blocks, REST endpoints, or any WordPress PHP/JS/CSS.
  Triggers: "WordPress", "WP plugin", "WP theme", "PHPCS", "WPCS", "WordPress coding standards",
  "WooCommerce", or requests to build/review/fix WordPress-related code.
  Ensures all generated code passes PHPCS (WordPress standard), ESLint (@wordpress/eslint-plugin),
  and Stylelint (@wordpress/stylelint-config) with zero errors.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - Edit
---

# WordPress Development Skill

Generate production-quality WordPress code that passes PHPCS, ESLint, and Stylelint with WordPress coding standards — zero errors out of the box.

**Skill directory:** `~/.claude/skills/wordpress-dev/`

---

## Quick Start

1. **Read this file** (you're doing it now).
2. **Identify what the user needs** — plugin, theme, WooCommerce extension, block, REST API, etc.
3. **Read the relevant reference files** before writing any code. Use the Read tool with these absolute paths:
   - Always read: `~/.claude/skills/wordpress-dev/references/php-standards.md`
   - Always read: `~/.claude/skills/wordpress-dev/references/security-checklist.md`
   - If JS is involved: `~/.claude/skills/wordpress-dev/references/js-standards.md`
   - If CSS/SCSS is involved: `~/.claude/skills/wordpress-dev/references/css-standards.md`
   - If WooCommerce: `~/.claude/skills/wordpress-dev/references/woocommerce.md`
4. **Generate code** following the standards from those references.
5. Optionally **copy config templates** from `~/.claude/skills/wordpress-dev/templates/` into the project root.
6. Optionally **run linters** using scripts in `~/.claude/skills/wordpress-dev/scripts/`.

---

## Decision Matrix: Which References to Read

| Request Type | php-standards | js-standards | css-standards | security-checklist | woocommerce |
|---|---|---|---|---|---|
| Plugin (PHP only) | YES | — | — | YES | — |
| Plugin (full stack) | YES | YES | YES | YES | — |
| Theme | YES | YES | YES | YES | — |
| Gutenberg Block | YES | YES | YES | — | — |
| WooCommerce Extension | YES | YES | YES | YES | YES |
| REST API Endpoint | YES | — | — | YES | — |
| AJAX Handler | YES | YES | — | YES | — |
| Admin Settings Page | YES | YES | YES | YES | — |
| Widget / Shortcode | YES | — | YES | YES | — |
| Code Review / Fix | YES | (if JS) | (if CSS) | YES | (if WC) |

When in doubt, read `php-standards.md` and `security-checklist.md` — they apply to virtually everything.

---

## Linting (Optional)

If PHP, Composer, npm are available, run linters against the project:

**Linux / macOS / WSL / Git Bash:**
```bash
# First-time setup
bash ~/.claude/skills/wordpress-dev/scripts/setup-environment.sh /path/to/project

# Run linters
bash ~/.claude/skills/wordpress-dev/scripts/lint-all.sh /path/to/project [--fix]
```

**Windows (PowerShell):**
```powershell
# First-time setup
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\setup-environment.ps1 -ProjectDir C:\path\to\project

# Run linters
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\lint-all.ps1 -ProjectDir C:\path\to\project [-Fix]
```

If linting tools are unavailable, **rely on the reference files** — they are comprehensive enough to produce clean code.

**Warnings are acceptable.** Errors are not. The goal is: `FOUND 0 ERRORS`.

---

## Project Configuration Templates

When creating a new WordPress project, copy templates from `~/.claude/skills/wordpress-dev/templates/` into the project root:

- `phpcs.xml.dist` — PHPCS config
- `.eslintrc.json` — ESLint config
- `.stylelintrc.json` — Stylelint config
- `composer.json` — PHP dev dependencies
- `package.json` — JS dev dependencies

After copying, **always** replace placeholder values:
- `CHANGE-ME` → actual text domain (e.g., `my-plugin`)
- `change_me` → actual function/class prefix (e.g., `my_plugin`)
- `my-project` → actual project name in package.json

---

## Critical Rules Summary

These are the rules that cause the most PHPCS failures. Internalize them:

1. **Tabs, not spaces** — for indentation in PHP, always use tabs.
2. **Spaces inside parentheses** — `if ( $x )` not `if ($x)`.
3. **Yoda conditions** — `if ( true === $value )` not `if ( $value === true )`.
4. **Escape ALL output** — `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`.
5. **Sanitize ALL input** — `sanitize_text_field( wp_unslash( $_POST['x'] ) )`.
6. **Nonce everything** — `wp_verify_nonce()` before processing any form/AJAX data.
7. **`$wpdb->prepare()`** — never concatenate variables into SQL queries.
8. **Prefix everything** — functions, classes, hooks, options, transients.
9. **DocBlocks on everything** — files, classes, methods, functions, with `@since`.
10. **Text domain matches slug** — `__( 'Text', 'my-plugin' )` where `my-plugin` is the slug.

---

## Inline Suppression (Last Resort)

When a PHPCS rule must be suppressed for a legitimate reason:

```php
// phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped -- Already escaped by wp_kses_post() above.
echo $safe_content;
```

Rules:
- Always include the full sniff name.
- Always add a `--` comment explaining WHY.
- Never suppress security sniffs without a genuine reason.
- Prefer fixing the code over suppressing the rule.

---

## File Structure Convention

When delivering a multi-file WordPress project, use this structure:

```
my-plugin/
├── my-plugin.php          # Main plugin file
├── uninstall.php          # Cleanup on uninstall
├── includes/              # PHP classes and functions
│   ├── class-my-plugin.php
│   └── class-my-plugin-admin.php
├── admin/                 # Admin-specific assets
│   ├── css/
│   ├── js/
│   └── views/
├── public/                # Front-end assets
│   ├── css/
│   ├── js/
│   └── views/
├── languages/             # Translation files
├── phpcs.xml.dist
├── .eslintrc.json
├── .stylelintrc.json
├── composer.json
└── package.json
```
