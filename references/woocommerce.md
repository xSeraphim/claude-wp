# WooCommerce Development Standards Reference

Patterns and standards specific to WooCommerce plugin/extension development. All general WordPress standards (php-standards.md, security-checklist.md) still apply. This reference covers WooCommerce-specific hooks, APIs, and conventions.

---

## Extension Header

WooCommerce extensions should declare compatibility in the main plugin file:

```php
/**
 * Plugin Name:       My WooCommerce Extension
 * Plugin URI:        https://example.com/my-wc-extension
 * Description:       Extends WooCommerce with custom functionality.
 * Version:           1.0.0
 * Requires at least: 6.0
 * Requires PHP:      7.4
 * Author:            Developer Name
 * Text Domain:       my-wc-extension
 * Domain Path:       /languages
 * License:           GPL v2 or later
 * WC requires at least: 8.0
 * WC tested up to:      9.5
 * Requires Plugins:  woocommerce
 */
```

---

## WooCommerce Dependency Check

Always verify WooCommerce is active before running extension code:

```php
/**
 * Check if WooCommerce is active.
 *
 * @since 1.0.0
 *
 * @return bool True if WooCommerce is active.
 */
function mywcext_is_woocommerce_active() {
    return class_exists( 'WooCommerce' );
}

/**
 * Initialize the extension after WooCommerce loads.
 *
 * @since 1.0.0
 *
 * @return void
 */
function mywcext_init() {
    if ( ! mywcext_is_woocommerce_active() ) {
        add_action( 'admin_notices', 'mywcext_woocommerce_missing_notice' );
        return;
    }

    // Load extension files.
    require_once plugin_dir_path( __FILE__ ) . 'includes/class-my-wc-extension.php';
}
add_action( 'plugins_loaded', 'mywcext_init' );

/**
 * Admin notice when WooCommerce is not active.
 *
 * @since 1.0.0
 *
 * @return void
 */
function mywcext_woocommerce_missing_notice() {
    ?>
    <div class="notice notice-error">
        <p>
            <?php
            printf(
                /* translators: %s: WooCommerce plugin name. */
                esc_html__( 'My WC Extension requires %s to be installed and active.', 'my-wc-extension' ),
                '<strong>WooCommerce</strong>'
            );
            ?>
        </p>
    </div>
    <?php
}
```

---

## HPOS (High-Performance Order Storage) Compatibility

WooCommerce has migrated from post-based to custom table order storage. Declare compatibility:

```php
/**
 * Declare HPOS compatibility.
 *
 * @since 1.0.0
 *
 * @return void
 */
function mywcext_declare_hpos_compatibility() {
    if ( class_exists( '\Automattic\WooCommerce\Utilities\FeaturesUtil' ) ) {
        \Automattic\WooCommerce\Utilities\FeaturesUtil::declare_compatibility(
            'custom_order_tables',
            __FILE__,
            true
        );
    }
}
add_action( 'before_woocommerce_init', 'mywcext_declare_hpos_compatibility' );
```

### Accessing Orders (HPOS-Compatible)

```php
// ✅ Correct — use WC API, works with both storage backends.
$order = wc_get_order( $order_id );

if ( $order ) {
    $status     = $order->get_status();
    $total      = $order->get_total();
    $email      = $order->get_billing_email();
    $items      = $order->get_items();
    $meta_value = $order->get_meta( '_mywcext_custom_field' );

    // Update order meta.
    $order->update_meta_data( '_mywcext_processed', 'yes' );
    $order->save();
}

// ✅ Querying orders — use wc_get_orders().
$orders = wc_get_orders(
    array(
        'status'     => array( 'wc-processing', 'wc-completed' ),
        'limit'      => 20,
        'orderby'    => 'date',
        'order'      => 'DESC',
        'meta_key'   => '_mywcext_custom_field',
        'meta_value' => 'yes',
    )
);

// ❌ Wrong — direct post queries break with HPOS.
$orders = get_posts( array( 'post_type' => 'shop_order' ) );
get_post_meta( $order_id, '_billing_email', true );
update_post_meta( $order_id, '_custom_field', $value );
```

---

## Common WooCommerce Hooks

### Product Hooks

```php
// Add custom field to product edit page.
add_action( 'woocommerce_product_options_general_product_data', 'mywcext_add_product_field' );

/**
 * Add custom field to product general tab.
 *
 * @since 1.0.0
 *
 * @return void
 */
function mywcext_add_product_field() {
    woocommerce_wp_text_input(
        array(
            'id'          => '_mywcext_custom_sku',
            'label'       => esc_html__( 'Custom SKU', 'my-wc-extension' ),
            'desc_tip'    => true,
            'description' => esc_html__( 'Enter a custom SKU for this product.', 'my-wc-extension' ),
        )
    );
}

// Save custom field.
add_action( 'woocommerce_process_product_meta', 'mywcext_save_product_field' );

/**
 * Save custom product field.
 *
 * @since 1.0.0
 *
 * @param int $post_id The product post ID.
 * @return void
 */
function mywcext_save_product_field( $post_id ) {
    // Nonce is already verified by WooCommerce at this point.
    $custom_sku = isset( $_POST['_mywcext_custom_sku'] )
        ? sanitize_text_field( wp_unslash( $_POST['_mywcext_custom_sku'] ) )
        : '';

    update_post_meta( $post_id, '_mywcext_custom_sku', $custom_sku );
}
```

### Checkout Hooks

```php
// Add field to checkout.
add_action( 'woocommerce_after_order_notes', 'mywcext_checkout_field' );

/**
 * Add custom checkout field.
 *
 * @since 1.0.0
 *
 * @param WC_Checkout $checkout The checkout object.
 * @return void
 */
function mywcext_checkout_field( $checkout ) {
    woocommerce_form_field(
        'mywcext_delivery_notes',
        array(
            'type'        => 'textarea',
            'class'       => array( 'form-row-wide' ),
            'label'       => esc_html__( 'Delivery Notes', 'my-wc-extension' ),
            'placeholder' => esc_attr__( 'Special delivery instructions…', 'my-wc-extension' ),
            'required'    => false,
        ),
        $checkout->get_value( 'mywcext_delivery_notes' )
    );
}

// Save checkout field to order.
add_action( 'woocommerce_checkout_update_order_meta', 'mywcext_save_checkout_field' );

/**
 * Save custom checkout field to order meta.
 *
 * @since 1.0.0
 *
 * @param int $order_id The order ID.
 * @return void
 */
function mywcext_save_checkout_field( $order_id ) {
    if ( ! empty( $_POST['mywcext_delivery_notes'] ) ) {
        $order = wc_get_order( $order_id );
        $notes = sanitize_textarea_field( wp_unslash( $_POST['mywcext_delivery_notes'] ) );
        $order->update_meta_data( '_mywcext_delivery_notes', $notes );
        $order->save();
    }
}
```

### Cart and Pricing Hooks

```php
// Add a custom fee to cart.
add_action( 'woocommerce_cart_calculate_fees', 'mywcext_add_custom_fee' );

/**
 * Add a custom handling fee to the cart.
 *
 * @since 1.0.0
 *
 * @param WC_Cart $cart The cart object.
 * @return void
 */
function mywcext_add_custom_fee( $cart ) {
    if ( is_admin() && ! defined( 'DOING_AJAX' ) ) {
        return;
    }

    $fee_amount = 5.00;

    /**
     * Filters the custom handling fee amount.
     *
     * @since 1.0.0
     *
     * @param float   $fee_amount The fee amount.
     * @param WC_Cart $cart       The cart object.
     */
    $fee_amount = apply_filters( 'mywcext_handling_fee', $fee_amount, $cart );

    if ( $fee_amount > 0 ) {
        $cart->add_fee( __( 'Handling Fee', 'my-wc-extension' ), $fee_amount );
    }
}
```

### Email Hooks

```php
// Add content to order confirmation email.
add_action( 'woocommerce_email_after_order_table', 'mywcext_email_delivery_notes', 10, 4 );

/**
 * Display delivery notes in order emails.
 *
 * @since 1.0.0
 *
 * @param WC_Order $order         The order object.
 * @param bool     $sent_to_admin Whether email is sent to admin.
 * @param bool     $plain_text    Whether email is plain text.
 * @param WC_Email $email         The email object.
 * @return void
 */
function mywcext_email_delivery_notes( $order, $sent_to_admin, $plain_text, $email ) {
    $notes = $order->get_meta( '_mywcext_delivery_notes' );

    if ( empty( $notes ) ) {
        return;
    }

    if ( $plain_text ) {
        echo "\n" . esc_html__( 'Delivery Notes:', 'my-wc-extension' ) . "\n";
        echo esc_html( $notes ) . "\n";
    } else {
        echo '<h2>' . esc_html__( 'Delivery Notes', 'my-wc-extension' ) . '</h2>';
        echo '<p>' . esc_html( $notes ) . '</p>';
    }
}
```

---

## Payment Gateway Template

```php
/**
 * Custom Payment Gateway.
 *
 * @since   1.0.0
 * @package My_WC_Extension
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Custom payment gateway class.
 *
 * @since 1.0.0
 */
class WC_Gateway_Mywcext extends WC_Payment_Gateway {

    /**
     * Constructor.
     *
     * @since 1.0.0
     */
    public function __construct() {
        $this->id                 = 'mywcext_gateway';
        $this->icon               = '';
        $this->has_fields         = false;
        $this->method_title       = esc_html__( 'My Custom Gateway', 'my-wc-extension' );
        $this->method_description = esc_html__( 'Accept payments via My Custom Gateway.', 'my-wc-extension' );

        $this->init_form_fields();
        $this->init_settings();

        $this->title       = $this->get_option( 'title' );
        $this->description = $this->get_option( 'description' );
        $this->enabled     = $this->get_option( 'enabled' );

        add_action( 'woocommerce_update_options_payment_gateways_' . $this->id, array( $this, 'process_admin_options' ) );
    }

    /**
     * Initialize gateway settings form fields.
     *
     * @since 1.0.0
     *
     * @return void
     */
    public function init_form_fields() {
        $this->form_fields = array(
            'enabled'     => array(
                'title'   => esc_html__( 'Enable/Disable', 'my-wc-extension' ),
                'type'    => 'checkbox',
                'label'   => esc_html__( 'Enable this gateway', 'my-wc-extension' ),
                'default' => 'no',
            ),
            'title'       => array(
                'title'       => esc_html__( 'Title', 'my-wc-extension' ),
                'type'        => 'text',
                'description' => esc_html__( 'Payment method title shown at checkout.', 'my-wc-extension' ),
                'default'     => esc_html__( 'Custom Payment', 'my-wc-extension' ),
                'desc_tip'    => true,
            ),
            'description' => array(
                'title'       => esc_html__( 'Description', 'my-wc-extension' ),
                'type'        => 'textarea',
                'description' => esc_html__( 'Payment method description shown at checkout.', 'my-wc-extension' ),
                'default'     => esc_html__( 'Pay using our custom gateway.', 'my-wc-extension' ),
            ),
        );
    }

    /**
     * Process the payment.
     *
     * @since 1.0.0
     *
     * @param int $order_id The order ID.
     * @return array Result array with redirect URL.
     */
    public function process_payment( $order_id ) {
        $order = wc_get_order( $order_id );

        if ( ! $order ) {
            wc_add_notice( esc_html__( 'Order not found.', 'my-wc-extension' ), 'error' );
            return array( 'result' => 'fail' );
        }

        // Process payment logic here.
        // On success:
        $order->payment_complete();
        $order->add_order_note( esc_html__( 'Payment completed via Custom Gateway.', 'my-wc-extension' ) );

        WC()->cart->empty_cart();

        return array(
            'result'   => 'success',
            'redirect' => $this->get_return_url( $order ),
        );
    }
}
```

---

## WooCommerce REST API Extensions

```php
/**
 * Register custom WooCommerce REST API endpoint.
 *
 * @since 1.0.0
 *
 * @return void
 */
function mywcext_register_rest_routes() {
    register_rest_route(
        'mywcext/v1',
        '/stats',
        array(
            'methods'             => 'GET',
            'callback'            => 'mywcext_rest_get_stats',
            'permission_callback' => function () {
                return current_user_can( 'view_woocommerce_reports' );
            },
        )
    );
}
add_action( 'rest_api_init', 'mywcext_register_rest_routes' );

/**
 * Get sales statistics.
 *
 * @since 1.0.0
 *
 * @param WP_REST_Request $request The REST request object.
 * @return WP_REST_Response The response.
 */
function mywcext_rest_get_stats( $request ) {
    $orders = wc_get_orders(
        array(
            'status' => array( 'wc-completed' ),
            'limit'  => 100,
        )
    );

    $total = 0;
    foreach ( $orders as $order ) {
        $total += (float) $order->get_total();
    }

    return rest_ensure_response(
        array(
            'total_sales'  => $total,
            'order_count'  => count( $orders ),
            'average_order' => count( $orders ) > 0 ? $total / count( $orders ) : 0,
        )
    );
}
```

---

## WooCommerce-Specific PHPCS Notes

- WooCommerce hooks often pass `$_POST` data to callbacks where nonces are already verified by WC core (e.g., `woocommerce_process_product_meta`). PHPCS may still flag these — in such cases, use:
  ```php
  // phpcs:ignore WordPress.Security.NonceVerification.Missing -- Nonce verified by WooCommerce.
  ```
- Always use `wc_get_order()` over `get_post()` for orders.
- Always use WC CRUD methods (`$order->get_meta()`, `$product->get_price()`) over `get_post_meta()`.
- Prefix all custom meta keys with your extension slug: `_mywcext_*`.
- Use WooCommerce notice functions: `wc_add_notice()`, `wc_print_notices()`.
- Use WooCommerce logging: `wc_get_logger()->info( 'Message', array( 'source' => 'my-wc-extension' ) )`.
