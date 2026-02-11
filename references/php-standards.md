# PHP Coding Standards Reference

Complete rules for writing PHP code that passes `phpcs --standard=WordPress` with zero errors.

---

## Naming Conventions

### Functions
- Lowercase with underscores, prefixed with project slug.
- Verb-first when possible.

```php
// ✅ Correct
function myplugin_get_user_settings( $user_id ) {}
function myplugin_register_post_types() {}
function myplugin_handle_form_submission() {}

// ❌ Wrong
function getSettings( $user_id ) {}        // camelCase, no prefix
function my_plugin_settings( $user_id ) {}  // ambiguous verb
```

### Classes
- Capitalized words separated by underscores.
- Acronyms fully uppercased.
- File named `class-{class-name-lowered}.php`.

```php
// ✅ Correct
class My_Plugin_Admin {}         // → class-my-plugin-admin.php
class My_Plugin_REST_Controller {} // → class-my-plugin-rest-controller.php
class WP_HTTP {}                  // → class-wp-http.php

// ❌ Wrong
class MyPluginAdmin {}            // camelCase
class my_plugin_admin {}          // lowercase
```

### Interfaces, Traits, Enums
```php
interface Mailer_Interface {}
trait Forbid_Dynamic_Properties {}
enum Post_Status {}
```

### Constants
```php
define( 'MY_PLUGIN_VERSION', '1.0.0' );
define( 'MY_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
```

### Hook Names
```php
// Actions and filters: prefixed, lowercase, underscored.
do_action( 'myplugin_after_save', $post_id );
apply_filters( 'myplugin_allowed_types', array( 'post', 'page' ) );
```

### Options and Transients
```php
// Always prefixed to avoid collisions.
get_option( 'myplugin_settings' );
set_transient( 'myplugin_cache_data', $data, HOUR_IN_SECONDS );
```

---

## Formatting Rules

### Indentation
- **Tabs only.** Never spaces for indentation.
- Nested code gets one additional tab per level.

```php
// ✅ Correct (tabs shown as →)
→if ( $condition ) {
→→do_something();
→→if ( $nested ) {
→→→do_more();
→→}
→}
```

### Spaces Inside Parentheses
```php
// ✅ Correct
if ( $condition ) {
foreach ( $items as $item ) {
function_call( $arg1, $arg2 );
array( 'key' => 'value' );

// ❌ Wrong
if ($condition) {
foreach ($items as $item) {
function_call($arg1, $arg2);
```

### Spaces Around Operators
```php
// ✅ Correct
$a    = $b + $c;
$name = 'value';
$x   === $y;

// ❌ Wrong
$a=$b+$c;
```

### Braces
```php
// ✅ Opening brace on same line.
if ( $condition ) {
    // code.
} elseif ( $other ) {
    // code.
} else {
    // code.
}

// ✅ Functions and classes too.
function my_function() {
    // code.
}

class My_Class {
    // code.
}

// ❌ Wrong: elseif as two words.
} else if ( $other ) {
```

### Yoda Conditions
- Literal/constant on the LEFT side of comparisons.

```php
// ✅ Correct
if ( true === $value ) {
if ( 'publish' === $post->post_status ) {
if ( null !== $result ) {
if ( 0 === strpos( $string, 'prefix' ) ) {

// ❌ Wrong
if ( $value === true ) {
if ( $post->post_status === 'publish' ) {
```

### Array Syntax
- WPCS default requires long `array()` syntax.
- Short `[]` is allowed ONLY if the project's `phpcs.xml.dist` explicitly enables it.

```php
// ✅ Default (always safe)
$items = array( 'one', 'two', 'three' );
$map   = array(
    'key1' => 'value1',
    'key2' => 'value2',
);

// ✅ Only if project config allows short syntax
$items = [ 'one', 'two', 'three' ];
```

### Multi-line Arrays and Function Calls
- Closing parenthesis/bracket on its own line.
- Trailing comma after last element.

```php
// ✅ Correct
$args = array(
    'post_type'      => 'product',
    'posts_per_page' => 10,
    'orderby'        => 'date',
);

register_post_type(
    'myplugin_product',
    array(
        'labels'  => $labels,
        'public'  => true,
        'show_ui' => true,
    )
);
```

### String Concatenation
```php
// ✅ Spaces around the dot.
$greeting = 'Hello, ' . $name . '!';

// ✅ Multi-line concatenation: dot at start of line, indented.
$html = '<div class="wrapper">'
    . '<h1>' . esc_html( $title ) . '</h1>'
    . '<p>' . esc_html( $content ) . '</p>'
    . '</div>';
```

### Ternary Operator
```php
// ✅ Short ternaries are OK.
$value = $condition ? 'yes' : 'no';

// ✅ Multi-line for complex expressions.
$output = ( true === $is_admin )
    ? esc_html__( 'Admin view', 'myplugin' )
    : esc_html__( 'Public view', 'myplugin' );
```

---

## Documentation (DocBlocks)

### File Header
Every PHP file must have a file-level DocBlock:

```php
<?php
/**
 * Admin settings page functionality.
 *
 * @package    My_Plugin
 * @subpackage My_Plugin/admin
 * @since      1.0.0
 */
```

### Functions
```php
/**
 * Retrieve plugin settings for a given user.
 *
 * @since 1.0.0
 *
 * @param int    $user_id The user ID.
 * @param string $context Optional. The context. Default 'view'.
 * @return array The user settings array.
 */
function myplugin_get_user_settings( $user_id, $context = 'view' ) {
```

### Classes
```php
/**
 * Handles admin-specific functionality.
 *
 * @since 1.0.0
 */
class My_Plugin_Admin {

    /**
     * The plugin version.
     *
     * @since  1.0.0
     * @access private
     * @var    string $version The current plugin version.
     */
    private $version;

    /**
     * Initialize the class.
     *
     * @since 1.0.0
     *
     * @param string $version The plugin version.
     */
    public function __construct( $version ) {
        $this->version = $version;
    }
}
```

### Hooks (Actions and Filters)
```php
/**
 * Fires after a product is saved.
 *
 * @since 1.0.0
 *
 * @param int   $product_id The product post ID.
 * @param array $data       The submitted form data.
 */
do_action( 'myplugin_product_saved', $product_id, $data );

/**
 * Filters the allowed product types.
 *
 * @since 1.0.0
 *
 * @param array $types Default product types.
 * @return array Modified product types.
 */
$types = apply_filters( 'myplugin_product_types', array( 'simple', 'variable' ) );
```

---

## Internationalization (i18n)

```php
// Simple string.
$label = __( 'Settings', 'myplugin' );

// Echo directly.
_e( 'Save Changes', 'myplugin' );

// Escaped + translated (preferred for output).
echo esc_html__( 'Settings', 'myplugin' );
esc_html_e( 'Save Changes', 'myplugin' );
esc_attr_e( 'Click here', 'myplugin' );

// With placeholders.
printf(
    /* translators: %s: user display name. */
    esc_html__( 'Hello, %s!', 'myplugin' ),
    esc_html( $user->display_name )
);

// Plurals.
printf(
    /* translators: %d: number of items. */
    esc_html( _n( '%d item', '%d items', $count, 'myplugin' ) ),
    $count
);

// Context disambiguation.
_x( 'Post', 'noun — a blog post', 'myplugin' );
_x( 'Post', 'verb — to publish', 'myplugin' );
```

Rules:
- Text domain MUST match the plugin/theme slug exactly.
- Every user-facing string must be wrapped.
- Always add `/* translators: */` comments when using placeholders.
- Never concatenate translatable strings: `__('Hello') . __('World')` — use `sprintf` instead.

---

## Enqueuing Assets

```php
/**
 * Enqueue admin scripts and styles.
 *
 * @since 1.0.0
 *
 * @param string $hook_suffix The current admin page hook suffix.
 * @return void
 */
function myplugin_admin_enqueue( $hook_suffix ) {
    // Only load on our settings page.
    if ( 'settings_page_myplugin' !== $hook_suffix ) {
        return;
    }

    wp_enqueue_style(
        'myplugin-admin',
        plugin_dir_url( __FILE__ ) . 'css/admin.css',
        array(),
        MY_PLUGIN_VERSION
    );

    wp_enqueue_script(
        'myplugin-admin',
        plugin_dir_url( __FILE__ ) . 'js/admin.js',
        array( 'jquery', 'wp-util' ),
        MY_PLUGIN_VERSION,
        true // In footer.
    );

    wp_localize_script(
        'myplugin-admin',
        'mypluginAdmin',
        array(
            'ajaxUrl' => admin_url( 'admin-ajax.php' ),
            'nonce'   => wp_create_nonce( 'myplugin_admin_nonce' ),
            'i18n'    => array(
                'confirm' => esc_html__( 'Are you sure?', 'myplugin' ),
            ),
        )
    );
}
add_action( 'admin_enqueue_scripts', 'myplugin_admin_enqueue' );
```

---

## Database Queries

```php
// ✅ Always use $wpdb->prepare() with placeholders.
global $wpdb;
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}myplugin_orders WHERE user_id = %d AND status = %s",
        $user_id,
        $status
    )
);

// ✅ Insert.
$wpdb->insert(
    $wpdb->prefix . 'myplugin_orders',
    array(
        'user_id'    => $user_id,
        'status'     => 'pending',
        'created_at' => current_time( 'mysql' ),
    ),
    array( '%d', '%s', '%s' )
);

// ✅ Update.
$wpdb->update(
    $wpdb->prefix . 'myplugin_orders',
    array( 'status' => 'completed' ),
    array( 'id' => $order_id ),
    array( '%s' ),
    array( '%d' )
);

// ❌ NEVER do this — SQL injection risk + PHPCS error.
$wpdb->get_results( "SELECT * FROM {$wpdb->prefix}orders WHERE id = $id" );
$wpdb->query( "DELETE FROM {$wpdb->prefix}orders WHERE id = " . $_GET['id'] );
```

When using direct DB queries, PHPCS will warn about:
- `WordPress.DB.DirectDatabaseQuery.DirectQuery` — prefer WP APIs when possible.
- `WordPress.DB.DirectDatabaseQuery.NoCaching` — add caching with `wp_cache_get()`/`wp_cache_set()`.

```php
// Pattern for caching direct queries.
$cache_key = 'myplugin_orders_' . $user_id;
$results   = wp_cache_get( $cache_key, 'myplugin' );

if ( false === $results ) {
    $results = $wpdb->get_results(
        $wpdb->prepare(
            "SELECT * FROM {$wpdb->prefix}myplugin_orders WHERE user_id = %d",
            $user_id
        )
    );
    wp_cache_set( $cache_key, $results, 'myplugin', HOUR_IN_SECONDS );
}
```

---

## Common PHPCS Error → Fix Map

| Sniff / Error Message | Fix |
|---|---|
| `WordPress.WhiteSpace.PrecisionAlignment` | Use tabs, not spaces. |
| `Generic.WhiteSpace.DisallowSpaceIndent` | Tabs for indentation. |
| `WordPress.Arrays.ArrayDeclarationSpacing` | Space after `array(`, trailing comma, closing on own line. |
| `WordPress.PHP.YodaConditions` | Flip: `'value' === $var`. |
| `WordPress.Security.EscapeOutput` | Wrap output in `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`. |
| `WordPress.Security.NonceVerification` | Add `wp_verify_nonce()` / `check_admin_referer()` before `$_POST`/`$_GET`. |
| `WordPress.Security.ValidatedSanitizedInput` | `sanitize_text_field( wp_unslash( $_POST['x'] ) )`. |
| `WordPress.DB.PreparedSQL` | Use `$wpdb->prepare()`. |
| `WordPress.DB.DirectDatabaseQuery.DirectQuery` | Use WP APIs or add `// phpcs:ignore` with explanation. |
| `WordPress.DB.DirectDatabaseQuery.NoCaching` | Add `wp_cache_get()`/`wp_cache_set()`. |
| `WordPress.WP.I18n.MissingTranslatorsComment` | Add `/* translators: %s: description */` above `sprintf`/`printf`. |
| `WordPress.WP.I18n.NonSingularStringLiteralDomain` | Text domain must be a plain string literal, not a variable. |
| `WordPress.NamingConventions.PrefixAllGlobals` | Prefix all global functions, classes, hooks, options. |
| `WordPress.Files.FileName.InvalidClassFileName` | Rename to `class-{name}.php`. |
| `WordPress.PHP.DisallowShortTernary` | Use full ternary `$x ? $y : $z` not `$x ?: $z`. |
| `Squiz.Commenting.FunctionComment.Missing` | Add DocBlock with `@param`, `@return`, `@since`. |
| `Squiz.Commenting.FileComment.Missing` | Add file-level DocBlock. |
| `Squiz.Commenting.InlineComment.InvalidEndChar` | Inline comments must end with a period. |
