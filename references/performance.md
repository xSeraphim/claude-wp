# WordPress Performance Best Practices

Use this reference for any query-heavy, high-traffic, API-integrated, or dashboard-wide feature.

## 1) Database & Query Discipline

1. **No unbounded queries**
   - Every `WP_Query` / `get_posts()` must define limits (`posts_per_page`) and include `no_found_rows => true` unless true pagination is required.
2. **Avoid expensive meta query patterns on hot paths**
   - Complex nested `meta_query` conditions should not run per request on high-traffic endpoints.
   - If metadata filtering becomes core workload, propose custom tables and indexed columns.
3. **Select only what you need**
   - Prefer `'fields' => 'ids'` for list pipelines where full objects are unnecessary.
4. **Batch, don’t loop queries**
   - Avoid N+1 loops (query inside `foreach`); fetch IDs/objects in one pass.

## 2) Caching Strategy

1. **Object cache first for expensive computations**
   - Pattern: `wp_cache_get()` -> compute on miss -> `wp_cache_set()`.
   - Use stable key format: `plugin_prefix:type:id`.
   - Use named groups: `plugin_prefix_group`.
2. **Use transients for remote API responses**
   - Cache third-party HTTP responses with explicit expirations.
   - Invalidate transients on relevant data updates.
3. **Invalidate intentionally**
   - Define cache invalidation hooks up front (save/update/delete events).

## 3) Options & Autoloading

1. **Do not autoload large option payloads**
   - With `add_option()`, set autoload to `false` unless needed on nearly every request.
2. **Keep options small and purpose-specific**
   - Avoid storing report blobs or bulky arrays in autoloaded options.

## 4) Assets

1. **Enqueue selectively**
   - Load assets only on screens/routes that need them.
2. **Prefer footer loading**
   - Use in-footer scripts by default unless head execution is required.
3. **Defer non-critical JS**
   - Add `defer`/`async` where compatible via `script_loader_tag` filtering.
4. **Version assets for cache busting**
   - Use filemtime in development and release version constants in production.

## 5) Performance Acceptance Checklist

- Query count and shape reviewed for N+1 patterns.
- Expensive paths have object/transient cache strategy.
- Cache invalidation points defined.
- No large autoloaded options introduced.
- Asset loading scoped to relevant contexts.
