# WordPress Development Skill — Claude Code Integration

When working on any WordPress project (plugins, themes, WooCommerce extensions, blocks, REST APIs), follow the standards defined in this repository.

## How to use

Before writing any WordPress code, read the relevant reference files from this skill directory:

1. **Always read:** `SKILL.md` (entry point with decision matrix and critical rules)
2. **Always read:** `references/php-standards.md` (PHP formatting, naming, DocBlocks, PHPCS rules)
3. **Always read:** `references/security-checklist.md` (escaping, sanitization, nonces, SQL safety)
4. **If JS is involved:** `references/js-standards.md`
5. **If CSS is involved:** `references/css-standards.md`
6. **If WooCommerce:** `references/woocommerce.md`

## Config templates

When creating a new WordPress project, copy the relevant files from `templates/` into the project root and replace placeholder values (`CHANGE-ME`, `change_me`, `my-project`).

## Linting

Run linters using the platform-appropriate script from `scripts/`:

- **Bash (Linux/macOS/WSL):** `bash scripts/setup-environment.sh <project>` then `bash scripts/lint-all.sh <project> --fix`
- **PowerShell (Windows):** `scripts\setup-environment.ps1 -ProjectDir <project>` then `scripts\lint-all.ps1 -ProjectDir <project> -Fix`

## Critical rules (always follow)

1. Tabs for indentation (PHP, JS, CSS)
2. Spaces inside parentheses: `if ( $x )` not `if ($x)`
3. Yoda conditions: `if ( true === $value )`
4. Escape ALL output: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`
5. Sanitize ALL input: `sanitize_text_field( wp_unslash( $_POST['x'] ) )`
6. Nonce every form/AJAX: `wp_verify_nonce()` / `check_ajax_referer()`
7. Prepare all SQL: `$wpdb->prepare()`
8. Prefix everything: functions, classes, hooks, options
9. DocBlocks on everything with `@since`
10. Text domain must match plugin/theme slug
