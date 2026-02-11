---
name: wordpress-dev
description: >
  Use this skill when creating, editing, or reviewing WordPress code — plugins, themes,
  WooCommerce extensions, mu-plugins, custom blocks, REST endpoints, or any WordPress PHP/JS/CSS.
  Triggers: "WordPress", "WP plugin", "WP theme", "PHPCS", "WPCS", "WordPress coding standards",
  "WooCommerce", or requests to build/review/fix WordPress-related code.
  Ensures all generated code passes PHPCS (WordPress standard), ESLint (@wordpress/eslint-plugin),
  and Stylelint (@wordpress/stylelint-config) with zero errors.
---

# WordPress Development Skill

Generate production-quality WordPress code that passes PHPCS, ESLint, and Stylelint with WordPress coding standards — zero errors out of the box.

> **Install path note:** Throughout this file, `<SKILL_DIR>` refers to the root of this repository (where this `SKILL.md` lives). When this skill is installed into a project via `CLAUDE.md`, all paths resolve relative to the cloned location.

---

## Quick Start

1. **Read this file** (you're doing it now).
2. **Identify what the user needs** — plugin, theme, WooCommerce extension, block, REST API, etc.
3. **Read the relevant reference files** before writing any code:
   - Always read: `references/php-standards.md`
   - If JS is involved: `references/js-standards.md`
   - If CSS/SCSS is involved: `references/css-standards.md`
   - If security-sensitive (forms, payments, user data, DB queries, AJAX): `references/security-checklist.md`
   - If WooCommerce: `references/woocommerce.md`
4. **Copy config templates** from `templates/` into the project root, then customize placeholders.
5. **Generate code** following the standards from those references.
6. **Set up linting environment** using the appropriate setup script (see below).
7. **Run linters** and iterate until clean.
8. **Deliver** validated files to the project output directory.

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

## Environment Setup

### Detect Platform and Run Setup

**Linux / macOS / WSL / Git Bash:**
```bash
bash <SKILL_DIR>/scripts/setup-environment.sh /path/to/project
```

**Windows (PowerShell):**
```powershell
& <SKILL_DIR>\scripts\setup-environment.ps1 -ProjectDir C:\path\to\project
```

Both scripts install:
- **PHP**: `phpcs` + `phpcbf` with `WordPress` standard via Composer
- **JS**: `eslint` with `@wordpress/eslint-plugin` via npm
- **CSS**: `stylelint` with `@wordpress/stylelint-config` via npm

If Composer or npm are unavailable, the scripts will warn. In that case, **rely on the reference files to write standards-compliant code from the start** — the references are comprehensive enough that code generated following them closely should pass with minimal issues.

---

## Linting Workflow

### Run Linters

**Linux / macOS / WSL / Git Bash:**
```bash
bash <SKILL_DIR>/scripts/lint-all.sh /path/to/project [--fix] [--php-only] [--js-only] [--css-only]
```

**Windows (PowerShell):**
```powershell
& <SKILL_DIR>\scripts\lint-all.ps1 -ProjectDir C:\path\to\project [-Fix] [-PhpOnly] [-JsOnly] [-CssOnly]
```

The `--fix` / `-Fix` flag attempts auto-fixing before reporting. The workflow is:

```
1. PHPCBF auto-fix (if --fix)     →  fixes ~60-70% of PHP formatting issues
2. PHPCS scan                      →  reports remaining PHP issues
3. ESLint --fix (if --fix)         →  fixes JS issues
4. ESLint scan                     →  reports remaining JS issues
5. Stylelint --fix (if --fix)      →  fixes CSS issues
6. Stylelint scan                  →  reports remaining CSS issues
```

### Iteration Loop

If linters report errors:
1. Read the error messages carefully — they include the sniff/rule name.
2. Fix each issue in the source code.
3. Re-run the linter on the specific file: `vendor/bin/phpcs --standard=WordPress -s file.php`
4. Repeat until zero errors.

**Warnings are acceptable.** Errors are not. The goal is: `FOUND 0 ERRORS`.

---

## Project Configuration Templates

When creating a new WordPress project, copy templates from the `templates/` directory into the project root:

```
templates/
├── phpcs.xml.dist       → project-root/phpcs.xml.dist
├── .eslintrc.json       → project-root/.eslintrc.json
├── .stylelintrc.json    → project-root/.stylelintrc.json
├── composer.json        → project-root/composer.json
└── package.json         → project-root/package.json
```

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
