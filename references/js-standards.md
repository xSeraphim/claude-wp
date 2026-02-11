# JavaScript Coding Standards Reference

Rules for writing JS that passes ESLint with `@wordpress/eslint-plugin/recommended`.

---

## Setup

The project must have:
- `.eslintrc.json` extending `plugin:@wordpress/eslint-plugin/recommended`
- `@wordpress/eslint-plugin` installed as a dev dependency

```json
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
```

---

## Core Rules

### Indentation
- **Tabs** for indentation (matching PHP convention in WordPress).
- The WP ESLint config enforces this.

```js
// ✅ Correct (tabs)
function init() {
→if ( condition ) {
→→doSomething();
→}
}
```

### Semicolons
- **Required** at end of statements.

```js
// ✅ Correct
const name = 'value';
doSomething();

// ❌ Wrong
const name = 'value'
doSomething()
```

### Quotes
- **Single quotes** for strings (unless the string contains a single quote).

```js
// ✅ Correct
const label = 'Hello World';
const html = "It's a test";

// ❌ Wrong
const label = "Hello World";
```

### Spacing
```js
// ✅ Spaces inside parentheses for control structures (WP style).
if ( condition ) {
for ( let i = 0; i < length; i++ ) {

// ✅ No spaces inside parentheses for function calls (standard).
doSomething( arg1, arg2 );

// ✅ Spaces around operators.
const result = a + b;
const isValid = count > 0;
```

### Variable Declarations
```js
// ✅ Use const by default.
const settings = {};

// ✅ Use let when reassignment is needed.
let counter = 0;
counter += 1;

// ❌ Never use var.
var oldStyle = true;
```

### Strict Equality
```js
// ✅ Always use === and !==.
if ( value === 'test' ) {
if ( result !== undefined ) {

// ❌ Never use == or !=.
if ( value == 'test' ) {
```

---

## jQuery (Legacy WordPress JS)

Many WordPress admin scripts still use jQuery. Follow these patterns:

```js
// ✅ Use the jQuery wrapper to avoid conflicts.
( function( $ ) {
    'use strict';

    $( document ).ready( function() {
        $( '.myplugin-button' ).on( 'click', function( e ) {
            e.preventDefault();
            // Handle click.
        } );
    } );
} )( jQuery );
```

### AJAX with jQuery
```js
( function( $ ) {
    'use strict';

    $( '.myplugin-save' ).on( 'click', function( e ) {
        e.preventDefault();

        const $button = $( this );
        $button.prop( 'disabled', true );

        $.ajax( {
            url: mypluginAdmin.ajaxUrl,
            type: 'POST',
            data: {
                action: 'myplugin_save_settings',
                _ajax_nonce: mypluginAdmin.nonce,
                setting_value: $( '#myplugin-setting' ).val(),
            },
            success: function( response ) {
                if ( response.success ) {
                    // Handle success — use localized strings.
                    alert( mypluginAdmin.i18n.saved );
                } else {
                    alert( response.data.message || mypluginAdmin.i18n.error );
                }
            },
            error: function() {
                alert( mypluginAdmin.i18n.error );
            },
            complete: function() {
                $button.prop( 'disabled', false );
            },
        } );
    } );
} )( jQuery );
```

---

## Modern JS (ES6+ / Block Editor)

For Gutenberg blocks and modern WordPress JS:

```js
/**
 * WordPress dependencies.
 */
import { __ } from '@wordpress/i18n';
import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps, RichText } from '@wordpress/block-editor';
import { useState } from '@wordpress/element';

/**
 * Internal dependencies.
 */
import './style.scss';
import './editor.scss';

registerBlockType( 'myplugin/custom-block', {
    edit: ( { attributes, setAttributes } ) => {
        const blockProps = useBlockProps();
        const { content } = attributes;

        return (
            <div { ...blockProps }>
                <RichText
                    tagName="p"
                    value={ content }
                    onChange={ ( newContent ) =>
                        setAttributes( { content: newContent } )
                    }
                    placeholder={ __( 'Enter text…', 'myplugin' ) }
                />
            </div>
        );
    },
    save: ( { attributes } ) => {
        const blockProps = useBlockProps.save();
        return (
            <div { ...blockProps }>
                <RichText.Content tagName="p" value={ attributes.content } />
            </div>
        );
    },
} );
```

### Import Order
The WP ESLint plugin enforces import ordering:

```js
// 1. Node built-ins (rare in WP context).
// 2. External packages.
import classnames from 'classnames';

// 3. WordPress packages (prefixed @wordpress/).
import { __ } from '@wordpress/i18n';
import { Button } from '@wordpress/components';

// 4. Internal / relative imports.
import { MyComponent } from './components';
import './style.scss';
```

---

## wp_localize_script Bridge

To pass data from PHP to JS:

**PHP side:**
```php
wp_localize_script(
    'myplugin-admin',
    'mypluginData',
    array(
        'ajaxUrl'  => admin_url( 'admin-ajax.php' ),
        'restUrl'  => rest_url( 'myplugin/v1/' ),
        'restNonce' => wp_create_nonce( 'wp_rest' ),
        'nonce'    => wp_create_nonce( 'myplugin_nonce' ),
        'settings' => myplugin_get_settings(),
        'i18n'     => array(
            'save'    => esc_html__( 'Save', 'myplugin' ),
            'saved'   => esc_html__( 'Saved!', 'myplugin' ),
            'error'   => esc_html__( 'An error occurred.', 'myplugin' ),
            'confirm' => esc_html__( 'Are you sure?', 'myplugin' ),
        ),
    )
);
```

**JS side:**
```js
// Access via the global object name (second arg of wp_localize_script).
const { ajaxUrl, nonce, i18n } = window.mypluginData;
```

---

## REST API (Fetch / apiFetch)

```js
import apiFetch from '@wordpress/api-fetch';

// GET request.
apiFetch( { path: '/myplugin/v1/items' } ).then( ( items ) => {
    console.log( items );
} );

// POST request.
apiFetch( {
    path: '/myplugin/v1/items',
    method: 'POST',
    data: { title: 'New Item' },
} ).then( ( response ) => {
    console.log( response );
} );
```

`apiFetch` automatically handles the REST nonce. For raw `fetch()`:

```js
fetch( mypluginData.restUrl + 'items', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-WP-Nonce': mypluginData.restNonce,
    },
    body: JSON.stringify( { title: 'New Item' } ),
} );
```

---

## Common ESLint Errors → Fix Map

| Rule | Fix |
|---|---|
| `no-var` | Use `const` or `let`. |
| `eqeqeq` | Use `===` / `!==`. |
| `no-unused-vars` | Remove unused variables or prefix with `_`. |
| `@wordpress/no-unused-vars-before-return` | Move variable declarations closer to usage. |
| `@wordpress/i18n-text-domain` | Use correct text domain string. |
| `@wordpress/i18n-no-variables` | Don't pass variables to `__()` — use `sprintf`. |
| `jsdoc/require-param` | Add `@param` tags to JSDoc. |
| `indent` | Use tabs. |
| `quotes` | Use single quotes. |
| `semi` | Add semicolons. |
| `no-alert` | Replace `alert()` with proper UI (notices, modals). |
| `no-console` | Remove or gate behind `process.env.NODE_ENV`. |
