# CSS Coding Standards Reference

Rules for writing CSS that passes Stylelint with `@wordpress/stylelint-config`.

---

## Setup

The project must have:
- `.stylelintrc.json` extending `@wordpress/stylelint-config`
- `@wordpress/stylelint-config` and `stylelint` installed as dev dependencies

```json
{
    "extends": "@wordpress/stylelint-config"
}
```

---

## Core Rules

### Indentation
- **Tabs** for indentation (consistent with PHP and JS in WordPress).

```css
/* ✅ Correct */
.myplugin-wrapper {
→display: flex;
→align-items: center;
}

/* ❌ Wrong (spaces) */
.myplugin-wrapper {
  display: flex;
}
```

### Selectors

#### Naming Convention
- Use lowercase with hyphens (kebab-case).
- Prefix all selectors with the plugin/theme slug to avoid collisions.

```css
/* ✅ Correct — prefixed, hyphenated */
.myplugin-card {}
.myplugin-card__title {}
.myplugin-card--featured {}

/* ❌ Wrong */
.myPlugin-card {}   /* camelCase */
.my_plugin_card {}  /* underscores */
.card {}            /* no prefix — will collide */
```

#### Selector Specificity
- Avoid over-qualified selectors.
- Avoid `!important` — increase specificity instead.
- Avoid ID selectors for styling.

```css
/* ✅ Correct */
.myplugin-button {
    background: #0073aa;
}

/* ❌ Avoid */
div.myplugin-button {}       /* over-qualified */
#myplugin-button {}           /* ID selector */
.myplugin-button {
    background: #0073aa !important;  /* avoid !important */
}
```

### Properties

#### Declaration Order
WordPress Stylelint config enforces a logical property order. Group properties by:

1. **Positioning**: `position`, `top`, `right`, `bottom`, `left`, `z-index`
2. **Box model**: `display`, `flex`, `grid`, `float`, `width`, `height`, `margin`, `padding`, `border`
3. **Typography**: `font`, `line-height`, `text-align`, `color`
4. **Visual**: `background`, `box-shadow`, `opacity`
5. **Animation**: `transition`, `animation`

```css
/* ✅ Correct — logical grouping */
.myplugin-card {
    position: relative;
    display: flex;
    align-items: center;
    width: 100%;
    max-width: 600px;
    margin: 0 auto;
    padding: 16px;
    border: 1px solid #ddd;
    font-size: 14px;
    line-height: 1.5;
    color: #333;
    background-color: #fff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.2s ease;
}
```

#### Value Formatting
```css
/* ✅ Spaces after colons */
color: #333;

/* ✅ Semicolon after every declaration (including last) */
.myplugin-box {
    margin: 0;
    padding: 0;
}

/* ✅ Use shorthand when setting all sides */
margin: 10px 20px;

/* ✅ Lowercase hex, shorthand when possible */
color: #fff;
background: #0073aa;

/* ❌ Wrong */
color: #FFFFFF;     /* uppercase hex */
color: white;       /* named color — prefer hex */
margin: 0px;        /* unnecessary unit on zero */
```

#### Zero Values
```css
/* ✅ No unit on zero values */
margin: 0;
padding: 0;
border: 0;

/* ❌ Wrong */
margin: 0px;
padding: 0rem;
```

### At-Rules (Media Queries)

```css
/* ✅ Correct — space before brace, consistent formatting */
@media screen and (min-width: 768px) {
    .myplugin-card {
        flex-direction: row;
    }
}

/* ✅ Mobile-first approach (preferred in WP themes) */
.myplugin-grid {
    display: block;
}

@media screen and (min-width: 600px) {
    .myplugin-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
    }
}

@media screen and (min-width: 1024px) {
    .myplugin-grid {
        grid-template-columns: 1fr 1fr 1fr;
    }
}
```

---

## WordPress Admin Styling

When styling WordPress admin pages:

```css
/* ✅ Use WordPress admin color variables when available */
.myplugin-admin-notice {
    border-left-color: var(--wp-admin-theme-color, #2271b1);
}

/* ✅ Scope admin styles to your plugin wrapper */
.myplugin-settings-page .myplugin-field {
    margin-bottom: 16px;
}

/* ✅ Use WordPress standard spacing (multiples of 4px or 8px) */
.myplugin-admin-card {
    padding: 16px;
    margin: 8px 0;
}

/* ❌ Don't override core WordPress admin styles globally */
.notice {
    background: red;  /* This will break ALL admin notices */
}
```

### Matching WP Admin Aesthetics
```css
/* Standard WordPress admin look and feel */
.myplugin-settings-wrap {
    max-width: 800px;
    margin: 20px 0;
}

.myplugin-settings-wrap h2 {
    font-size: 1.3em;
    margin: 1em 0 0.5em;
    padding: 0;
}

.myplugin-field-row {
    display: flex;
    align-items: flex-start;
    margin-bottom: 16px;
    padding: 12px 0;
    border-bottom: 1px solid #f0f0f1;
}

.myplugin-field-row label {
    flex: 0 0 200px;
    font-weight: 600;
    padding-top: 4px;
}
```

---

## SCSS (If Used)

WordPress block development often uses SCSS:

```scss
// ✅ Variables prefixed.
$myplugin-primary: #0073aa;
$myplugin-spacing: 16px;

// ✅ Nesting limited to 3 levels max.
.myplugin-card {
    padding: $myplugin-spacing;

    &__title {
        font-size: 1.2em;
        font-weight: 600;
    }

    &__content {
        margin-top: $myplugin-spacing / 2;
    }

    &--featured {
        border-color: $myplugin-primary;
    }
}

// ❌ Avoid deep nesting.
.myplugin-card {
    .inner {
        .content {
            .text {
                p {
                    // Too deep — refactor!
                }
            }
        }
    }
}
```

---

## RTL Compatibility

WordPress supports RTL languages. Use logical properties or ensure RTL compat:

```css
/* ✅ Preferred — logical properties (modern browsers) */
.myplugin-sidebar {
    margin-inline-start: 20px;
    padding-inline-end: 16px;
    border-inline-start: 3px solid #0073aa;
}

/* ✅ Alternative — use both directions for older browser support */
.myplugin-sidebar {
    margin-left: 20px;
}

/* RTL override (in a separate rtl.css or via body.rtl) */
body.rtl .myplugin-sidebar {
    margin-left: 0;
    margin-right: 20px;
}
```

---

## Common Stylelint Errors → Fix Map

| Rule | Fix |
|---|---|
| `indentation` | Use tabs. |
| `selector-class-pattern` | Use lowercase hyphenated names. |
| `no-descending-specificity` | Reorder rules so higher specificity comes last. |
| `declaration-no-important` | Remove `!important`; increase selector specificity. |
| `color-no-invalid-hex` | Fix hex color typos. |
| `length-zero-no-unit` | Remove units from `0` values. |
| `shorthand-property-no-redundant-values` | `margin: 10px 10px` → `margin: 10px`. |
| `font-family-no-missing-generic-family-keyword` | Add `sans-serif` / `serif` fallback. |
| `property-no-vendor-prefix` | Remove vendor prefixes handled by autoprefixer. |
| `block-no-empty` | Remove empty rule blocks. |
| `no-duplicate-selectors` | Merge duplicate selectors. |
| `declaration-block-no-duplicate-properties` | Remove duplicate declarations. |
