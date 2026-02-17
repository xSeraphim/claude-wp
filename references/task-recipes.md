# WordPress Task Recipes

Use these recipes when the user asks for common WordPress deliverables. Each recipe defines: discovery questions, minimum files, security checks, and done criteria.

---

## 1) New Plugin (PHP-first)

### Ask first
- Plugin slug / text domain?
- Minimum supported WordPress version?
- Admin-only, frontend-only, or both?

### Minimum deliverables
- Main plugin file with proper header and activation guard (`defined( 'ABSPATH' )`).
- `uninstall.php` if options/custom tables/transients are created.
- Namespaced or prefixed functions/classes.
- i18n-ready user-visible strings.

### Security checks
- Escape all output contextually.
- Sanitize all input from superglobals.
- Verify nonces for write actions.
- Check capabilities for privileged actions.

### Done criteria
- File tree included in final answer.
- Lint command suggestions included.
- Manual QA steps included.

---

## 2) Admin Settings Page

### Ask first
- Which options should be stored?
- Who can edit (capability)?
- Should this use Settings API?

### Minimum deliverables
- Menu/page registration.
- Render callback with escaped output.
- Save handler with nonce + capability checks.
- Sanitization callback(s) per option type.

### Security checks
- `wp_nonce_field()` + `check_admin_referer()` or `wp_verify_nonce()`.
- `current_user_can()` before update.
- `sanitize_*` on all incoming values.

### Done criteria
- Invalid input handling behavior described.
- Success/failure admin notices escaped.

---

## 3) REST API Endpoint

### Ask first
- Public vs authenticated endpoint?
- Read-only or write?
- Expected schema/validation?

### Minimum deliverables
- `register_rest_route()` with explicit namespace/version.
- `permission_callback` (never `__return_true` unless explicitly public).
- Argument validation/sanitization callbacks.
- Structured `WP_REST_Response` or `WP_Error` outputs.

### Security checks
- Capability checks in permission callback.
- Sanitize request params.
- Escape content at render/output time where applicable.

### Done criteria
- Example request/response payloads provided.
- Error cases documented.

---

## 4) WooCommerce Extension Task

### Ask first
- HPOS requirement?
- Checkout/cart/product/admin scope?
- Compatibility range (WC + WP versions)?

### Minimum deliverables
- Use WooCommerce CRUD/data APIs where possible.
- HPOS-safe patterns for order access.
- Hook selection justification.

### Security checks
- Same baseline checks as WordPress + payment/checkout hardening.

### Done criteria
- Compatibility notes included.
- Hook execution context explained.

---

## 5) Gutenberg Block Task

### Ask first
- Dynamic vs static block?
- Server render needed?
- Editor-only controls and saved markup?

### Minimum deliverables
- Block registration and metadata.
- Proper escaping/sanitization across edit/save/render boundaries.
- Script/style enqueue strategy.

### Security checks
- Treat serialized attributes as untrusted input.
- Sanitize server-rendered attributes.

### Done criteria
- Editor interaction summary.
- Frontend render behavior summary.

---

## Final Response Contract (for all recipes)

Always include:
1. What changed (concise bullets).
2. File-by-file summary.
3. Commands run (or exact commands to run if tools unavailable).
4. Manual test steps.
5. Known assumptions and follow-ups.
