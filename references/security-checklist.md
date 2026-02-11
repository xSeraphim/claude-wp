# WordPress Security Checklist

Every security pattern PHPCS checks for, with correct implementations. Read this reference for ANY code that handles user input, database operations, output rendering, forms, AJAX, or REST endpoints.

---

## 1. Output Escaping

**Rule:** NEVER echo/print any variable without escaping. PHPCS sniff: `WordPress.Security.EscapeOutput`.

### Escaping Functions by Context

| Context | Function | Example |
|---|---|---|
| HTML body text | `esc_html()` | `<p><?php echo esc_html( $title ); ?></p>` |
| HTML attribute | `esc_attr()` | `<input value="<?php echo esc_attr( $val ); ?>">` |
| URL (href, src) | `esc_url()` | `<a href="<?php echo esc_url( $link ); ?>">` |
| JavaScript string | `esc_js()` | `onclick="alert('<?php echo esc_js( $msg ); ?>');"` |
| Textarea content | `esc_textarea()` | `<textarea><?php echo esc_textarea( $text ); ?></textarea>` |
| Rich HTML (posts) | `wp_kses_post()` | `echo wp_kses_post( $post_content );` |
| Custom allowed HTML | `wp_kses()` | `echo wp_kses( $html, $allowed );` |
| Translated + escaped | `esc_html__()`  | `echo esc_html__( 'Text', 'domain' );` |
| Translated + attr | `esc_attr__()` | `echo esc_attr__( 'Placeholder', 'domain' );` |

### Patterns

```php
// ✅ Correct — escaped output.
echo '<h2>' . esc_html( $title ) . '</h2>';
echo '<a href="' . esc_url( $url ) . '" class="' . esc_attr( $class ) . '">';
echo '<div>' . wp_kses_post( $content ) . '</div>';

// ✅ Correct — printf with escaping.
printf(
    '<a href="%1$s" title="%2$s">%3$s</a>',
    esc_url( $url ),
    esc_attr( $title ),
    esc_html( $text )
);

// ✅ Correct — translated and escaped.
printf(
    /* translators: %s: user name. */
    esc_html__( 'Welcome back, %s!', 'myplugin' ),
    esc_html( $user->display_name )
);

// ❌ Wrong — unescaped output. PHPCS will flag these.
echo $title;
echo '<a href="' . $url . '">';
echo $content;
printf( '<h1>%s</h1>', $title );
```

### wp_kses Allowed HTML

```php
// Define allowed HTML tags and attributes.
$allowed_html = array(
    'a'      => array(
        'href'   => array(),
        'title'  => array(),
        'class'  => array(),
        'target' => array(),
    ),
    'br'     => array(),
    'em'     => array(),
    'strong' => array(),
    'p'      => array(
        'class' => array(),
    ),
);

echo wp_kses( $user_html, $allowed_html );
```

---

## 2. Input Sanitization

**Rule:** NEVER use `$_GET`, `$_POST`, `$_REQUEST`, `$_SERVER`, `$_COOKIE` without sanitization. PHPCS sniff: `WordPress.Security.ValidatedSanitizedInput`.

### Sanitization Functions

| Data Type | Function |
|---|---|
| Plain text | `sanitize_text_field()` |
| Textarea (multiline) | `sanitize_textarea_field()` |
| Email | `sanitize_email()` |
| URL | `esc_url_raw()` |
| Filename | `sanitize_file_name()` |
| HTML class name | `sanitize_html_class()` |
| Slug | `sanitize_title()` |
| Integer | `absint()` or `intval()` |
| Key (lowercase alnum + dashes) | `sanitize_key()` |
| Rich HTML | `wp_kses_post()` |
| MIME type | `sanitize_mime_type()` |

### The Pattern: unslash → sanitize

WordPress adds slashes to superglobals. Always `wp_unslash()` first:

```php
// ✅ Correct pattern — unslash then sanitize.
$name  = sanitize_text_field( wp_unslash( $_POST['name'] ) );
$email = sanitize_email( wp_unslash( $_POST['email'] ) );
$url   = esc_url_raw( wp_unslash( $_POST['website'] ) );
$id    = absint( $_POST['item_id'] );  // absint doesn't need unslash (numeric).
$bio   = sanitize_textarea_field( wp_unslash( $_POST['bio'] ) );

// ✅ Check if key exists first.
$name = isset( $_POST['name'] )
    ? sanitize_text_field( wp_unslash( $_POST['name'] ) )
    : '';

// ❌ Wrong — no sanitization.
$name = $_POST['name'];
$name = wp_unslash( $_POST['name'] );  // Unslashed but not sanitized!
```

### Server Variables
```php
// ✅ Correct.
$request_uri = isset( $_SERVER['REQUEST_URI'] )
    ? esc_url_raw( wp_unslash( $_SERVER['REQUEST_URI'] ) )
    : '';

$ip_address = isset( $_SERVER['REMOTE_ADDR'] )
    ? sanitize_text_field( wp_unslash( $_SERVER['REMOTE_ADDR'] ) )
    : '';
```

---

## 3. Nonce Verification

**Rule:** Every form submission and AJAX request MUST have a nonce. PHPCS sniff: `WordPress.Security.NonceVerification`.

### Form Nonces

```php
// ✅ PHP — render the form with a nonce field.
function myplugin_render_settings_form() {
    ?>
    <form method="post" action="">
        <?php wp_nonce_field( 'myplugin_save_settings', 'myplugin_nonce' ); ?>
        <input type="text" name="myplugin_option" value="<?php echo esc_attr( get_option( 'myplugin_option', '' ) ); ?>">
        <?php submit_button( esc_html__( 'Save', 'myplugin' ) ); ?>
    </form>
    <?php
}

// ✅ PHP — verify nonce on submission.
function myplugin_handle_settings_save() {
    // Check nonce.
    if ( ! isset( $_POST['myplugin_nonce'] )
        || ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_POST['myplugin_nonce'] ) ), 'myplugin_save_settings' )
    ) {
        wp_die( esc_html__( 'Security check failed.', 'myplugin' ) );
    }

    // Check capabilities.
    if ( ! current_user_can( 'manage_options' ) ) {
        wp_die( esc_html__( 'Unauthorized.', 'myplugin' ) );
    }

    // Now safe to process.
    $option = sanitize_text_field( wp_unslash( $_POST['myplugin_option'] ) );
    update_option( 'myplugin_option', $option );
}
```

### AJAX Nonces

```php
// ✅ PHP — AJAX handler with nonce verification.
function myplugin_ajax_save() {
    check_ajax_referer( 'myplugin_admin_nonce' );

    if ( ! current_user_can( 'manage_options' ) ) {
        wp_send_json_error( array( 'message' => __( 'Unauthorized.', 'myplugin' ) ) );
    }

    $value = isset( $_POST['value'] )
        ? sanitize_text_field( wp_unslash( $_POST['value'] ) )
        : '';

    update_option( 'myplugin_setting', $value );

    wp_send_json_success( array( 'message' => __( 'Saved!', 'myplugin' ) ) );
}
add_action( 'wp_ajax_myplugin_save', 'myplugin_ajax_save' );
```

```js
// ✅ JS — send nonce with AJAX request.
jQuery.ajax( {
    url: mypluginData.ajaxUrl,
    type: 'POST',
    data: {
        action: 'myplugin_save',
        _ajax_nonce: mypluginData.nonce,
        value: newValue,
    },
} );
```

### Admin Page Nonces (Settings API)

```php
// For options pages using the Settings API, use check_admin_referer.
function myplugin_save_settings_page() {
    check_admin_referer( 'myplugin-settings-group-options' );
    // Process settings...
}
```

---

## 4. Capability Checks

**Rule:** Always verify the user has permission before performing privileged operations.

```php
// ✅ Before saving settings.
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( esc_html__( 'Unauthorized access.', 'myplugin' ) );
}

// ✅ Before editing a post.
if ( ! current_user_can( 'edit_post', $post_id ) ) {
    return;
}

// ✅ Before managing users.
if ( ! current_user_can( 'edit_users' ) ) {
    wp_send_json_error( array( 'message' => __( 'Permission denied.', 'myplugin' ) ) );
}

// ✅ In REST API permission callbacks.
'permission_callback' => function () {
    return current_user_can( 'manage_options' );
},
```

### Common Capabilities

| Capability | Who Has It | Use For |
|---|---|---|
| `manage_options` | Administrators | Plugin settings, site config |
| `edit_posts` | Authors+ | Creating/editing own posts |
| `edit_others_posts` | Editors+ | Editing any post |
| `publish_posts` | Authors+ | Publishing posts |
| `edit_post` (+ ID) | Post author/editor | Editing a specific post |
| `delete_posts` | Authors+ | Deleting own posts |
| `upload_files` | Authors+ | Media uploads |
| `edit_users` | Administrators | User management |
| `install_plugins` | Super Admins (MS) | Plugin management |

---

## 5. SQL Safety

**Rule:** NEVER concatenate variables into SQL. Always use `$wpdb->prepare()`. PHPCS sniff: `WordPress.DB.PreparedSQL`.

```php
global $wpdb;

// ✅ Correct — prepared statement.
$user = $wpdb->get_row(
    $wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}myplugin_users WHERE id = %d AND status = %s",
        $user_id,
        $status
    )
);

// ✅ Correct — LIKE queries need special handling.
$search = '%' . $wpdb->esc_like( $search_term ) . '%';
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM {$wpdb->posts} WHERE post_title LIKE %s AND post_status = %s",
        $search,
        'publish'
    )
);

// ✅ Correct — IN clause with multiple values.
$ids         = array( 1, 2, 3, 4, 5 );
$placeholders = implode( ', ', array_fill( 0, count( $ids ), '%d' ) );
$results     = $wpdb->get_results(
    $wpdb->prepare(
        // phpcs:ignore WordPress.DB.PreparedSQLPlaceholders.UnfinishedPrepare -- Dynamic placeholder count.
        "SELECT * FROM {$wpdb->posts} WHERE ID IN ($placeholders)",
        ...$ids
    )
);

// ❌ DANGEROUS — SQL injection.
$wpdb->query( "DELETE FROM {$wpdb->prefix}orders WHERE id = $id" );
$wpdb->get_results( "SELECT * FROM {$wpdb->prefix}users WHERE name = '" . $_GET['name'] . "'" );
```

### Placeholders

| Placeholder | Type | Example |
|---|---|---|
| `%d` | Integer | `WHERE id = %d` |
| `%s` | String | `WHERE name = %s` |
| `%f` | Float | `WHERE price = %f` |
| `%i` | Identifier (table/column) | `ORDER BY %i` (WP 6.2+) |

---

## 6. File Operations

```php
// ✅ Use WP_Filesystem API instead of direct file operations.
global $wp_filesystem;

if ( ! function_exists( 'WP_Filesystem' ) ) {
    require_once ABSPATH . 'wp-admin/includes/file.php';
}

WP_Filesystem();

$content = $wp_filesystem->get_contents( $file_path );
$wp_filesystem->put_contents( $file_path, $content, FS_CHMOD_FILE );

// ✅ File uploads — use wp_handle_upload().
if ( ! empty( $_FILES['myplugin_file'] ) ) {
    check_admin_referer( 'myplugin_upload', 'myplugin_nonce' );

    $upload = wp_handle_upload(
        $_FILES['myplugin_file'],
        array( 'test_form' => false )
    );

    if ( isset( $upload['error'] ) ) {
        // Handle error.
    }
}

// ❌ Never use direct PHP file functions in plugins.
file_get_contents( $path );    // PHPCS will warn.
file_put_contents( $path );    // PHPCS will warn.
fopen() / fwrite() / fclose(); // PHPCS will warn.
```

---

## 7. Redirects

```php
// ✅ Use wp_safe_redirect() — only allows local redirects.
wp_safe_redirect( admin_url( 'options-general.php?page=myplugin&saved=1' ) );
exit;

// ✅ Use wp_redirect() only when redirecting to external URLs (rare).
// phpcs:ignore WordPress.Security.SafeRedirect.wp_redirect_wp_redirect -- External redirect required.
wp_redirect( esc_url_raw( $external_url ) );
exit;

// Always call exit after redirect.
```

---

## 8. REST API Security

```php
// ✅ Always define permission_callback — NEVER use __return_true unless truly public.
register_rest_route(
    'myplugin/v1',
    '/settings',
    array(
        'methods'             => 'GET',
        'callback'            => 'myplugin_rest_get_settings',
        'permission_callback' => function () {
            return current_user_can( 'manage_options' );
        },
    )
);

register_rest_route(
    'myplugin/v1',
    '/settings',
    array(
        'methods'             => 'POST',
        'callback'            => 'myplugin_rest_save_settings',
        'permission_callback' => function () {
            return current_user_can( 'manage_options' );
        },
        'args'                => array(
            'option_value' => array(
                'required'          => true,
                'sanitize_callback' => 'sanitize_text_field',
                'validate_callback' => function ( $value ) {
                    return is_string( $value ) && strlen( $value ) <= 255;
                },
            ),
        ),
    )
);
```

---

## Security Checklist Summary

Before delivering any WordPress code, verify:

- [ ] All output uses appropriate `esc_*()` functions
- [ ] All `$_POST`/`$_GET`/`$_REQUEST`/`$_SERVER`/`$_COOKIE` are sanitized with `wp_unslash()` + sanitizer
- [ ] Every form has `wp_nonce_field()` and handler has `wp_verify_nonce()`
- [ ] Every AJAX handler uses `check_ajax_referer()`
- [ ] Every REST endpoint has a `permission_callback`
- [ ] Every REST endpoint uses `sanitize_callback` and `validate_callback` on args
- [ ] All DB queries use `$wpdb->prepare()`
- [ ] All privileged operations check `current_user_can()`
- [ ] Redirects use `wp_safe_redirect()` + `exit`
- [ ] File operations use `WP_Filesystem` API
- [ ] No `eval()`, `extract()`, `serialize()`/`unserialize()` (use `maybe_serialize()`/`maybe_unserialize()`)
