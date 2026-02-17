# Full Site Editing (FSE) and Block Theme Guidance

Use this reference for block themes, `theme.json`, site editor features, and modern block-first workflows.

## 1) `theme.json` First

1. Prefer `theme.json` for global styles/settings over ad-hoc CSS where possible.
2. Keep palette, spacing, typography, and layout constraints centralized.
3. Avoid duplicating style definitions across CSS and `theme.json` unless necessary.

## 2) Block Patterns Over Hardcoded Layouts

1. Register reusable block patterns for common layouts.
2. Avoid hardcoding large layout fragments in PHP templates when a pattern fits.
3. Provide meaningful pattern titles/descriptions and categories.

## 3) Dynamic vs Static Blocks

1. Use static blocks for stable content markup.
2. Use dynamic blocks when output depends on runtime data.
3. Sanitize attributes server-side for dynamic rendering.

## 4) Data Layer Practices (`@wordpress/data`)

1. Keep selectors and actions focused and composable.
2. Avoid unnecessary global state coupling.
3. Memoize expensive selector derivations where possible.

## 5) FSE Acceptance Checklist

- `theme.json` considered before custom CSS.
- Pattern registration evaluated for reusable layouts.
- Block rendering mode (static/dynamic) justified.
- Editor data interactions are predictable and testable.
