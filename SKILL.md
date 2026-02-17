---
name: wordpress-dev
description: >
  Use this skill when creating, editing, or reviewing WordPress code — plugins, themes,
  WooCommerce extensions, mu-plugins, custom blocks, REST endpoints, or any WordPress PHP/JS/CSS.
  Triggers: "WordPress", "WP plugin", "WP theme", "PHPCS", "WPCS", "WordPress coding standards",
  "WooCommerce", or requests to build/review/fix WordPress-related code.
  Produces WordPress code aligned with PHPCS (WordPress standard), ESLint (@wordpress/eslint-plugin),
  and Stylelint (@wordpress/stylelint-config) rules.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - Edit
---

# WordPress Development Skill

Generate production-quality WordPress code aligned with PHPCS, ESLint, and Stylelint WordPress standards.

**Skill directory:** `~/.claude/skills/wordpress-dev/`

---

## Quick Start

1. Identify the request type (plugin, theme, WooCommerce extension, block, REST API, etc.).
2. Read required references **before** writing code:
   - Always: `~/.claude/skills/wordpress-dev/references/php-standards.md`
   - Always: `~/.claude/skills/wordpress-dev/references/security-checklist.md`
   - If JS is involved: `~/.claude/skills/wordpress-dev/references/js-standards.md`
   - If CSS/SCSS is involved: `~/.claude/skills/wordpress-dev/references/css-standards.md`
   - If WooCommerce is involved: `~/.claude/skills/wordpress-dev/references/woocommerce.md`
   - If high-traffic/query-heavy: `~/.claude/skills/wordpress-dev/references/performance.md`
   - If block theme/FSE: `~/.claude/skills/wordpress-dev/references/fse.md`
   - If critical logic or endpoints: `~/.claude/skills/wordpress-dev/references/testing.md`
3. Generate code using the loaded standards.
4. If needed, copy templates from `~/.claude/skills/wordpress-dev/templates/`.
5. If tools are available, run a preflight check and linters in `~/.claude/skills/wordpress-dev/scripts/`.
6. For common request types, load `~/.claude/skills/wordpress-dev/references/task-recipes.md` and follow the matching recipe.
7. If WordPress MCP is available, load `~/.claude/skills/wordpress-dev/references/mcp-wordpress.md` and incorporate live context safely.

---

## Decision Matrix: Which References to Read

| Request Type | php-standards | js-standards | css-standards | security-checklist | woocommerce | performance | testing | fse |
|---|---|---|---|---|---|---|---|---|
| Plugin (PHP only) | YES | — | — | YES | — | (if heavy) | (if critical) | — |
| Plugin (full stack) | YES | YES | YES | YES | — | (if heavy) | (if critical) | — |
| Theme | YES | YES | YES | YES | — | (if heavy) | (if critical) | (if block theme) |
| Gutenberg Block | YES | YES | YES | — | — | (if heavy) | (if critical) | YES |
| WooCommerce Extension | YES | YES | YES | YES | YES | YES | (if critical) | — |
| REST API Endpoint | YES | — | — | YES | — | YES | YES | — |
| AJAX Handler | YES | YES | — | YES | — | (if heavy) | YES | — |
| Admin Settings Page | YES | YES | YES | YES | — | — | YES | — |
| Widget / Shortcode | YES | — | YES | YES | — | (if heavy) | (if critical) | — |
| Code Review / Fix | YES | (if JS) | (if CSS) | YES | (if WC) | (if perf issue) | (if critical) | (if block theme) |

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

Run a preflight check before linting to catch unresolved placeholders and missing config:

**Linux / macOS / WSL / Git Bash:**
```bash
bash ~/.claude/skills/wordpress-dev/scripts/preflight-check.sh /path/to/project
```

**Windows (PowerShell):**
```powershell
& $env:USERPROFILE\.claude\skills\wordpress-dev\scripts\preflight-check.ps1 -ProjectDir C:\path\to\project
```

If linting tools are unavailable, rely on the reference files and still follow all standards.

Treat warnings as acceptable unless the user asks for warning-free output. Errors are not acceptable.

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


## Output Quality Contract

For every non-trivial coding task, include in the response:
- file tree (or changed-file list),
- what was implemented per file,
- commands run (or exact commands the user should run),
- manual test checklist,
- assumptions and follow-up improvements.

This makes outputs easier to review, verify, and hand off.

---

## Feature Roadmap (Prioritized)

1. **Recipe-driven generation (HIGH impact)**
   - Use `references/task-recipes.md` for plugin/settings/REST/block/WooCommerce tasks.
2. **Stronger validation UX (HIGH impact)**
   - Keep preflight first, then linting, then manual QA checklist in output.
3. **Performance baseline (MEDIUM impact)**
   - Apply `references/performance.md` for caching, query limits, and asset loading strategy.
4. **Testing-first outputs (MEDIUM impact)**
   - Apply `references/testing.md` and include PHPUnit/Jest scaffolds for critical logic.
5. **Modern block-theme support (MEDIUM impact)**
   - Apply `references/fse.md` for `theme.json`, patterns, and editor data best practices.

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
