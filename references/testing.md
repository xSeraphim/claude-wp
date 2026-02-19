# WordPress Testing Reference

Use this reference when generating business logic, form handling, REST endpoints, or WooCommerce flows.

## 1) Default Testing Rule

For critical logic, generate both:
1. implementation code, and
2. corresponding test case(s).

## 2) PHPUnit (WordPress)

- Base class: `WP_UnitTestCase`.
- Cover happy path + validation failure + capability/security failure where relevant.
- Prefer deterministic fixtures over broad integration assumptions.

### Minimum test set for critical logic

- **Input validation**: invalid and edge-case payloads.
- **Authorization**: unauthorized user cannot perform write action.
- **State change**: expected DB/option/post-meta mutation occurs.
- **Output contract**: expected return shape / error codes.

## 3) REST/AJAX Test Focus

- Permission callback behavior by role/capability.
- Nonce/csrf validation for write endpoints.
- Sanitization and schema validation behavior.
- Error response consistency (`WP_Error` / status codes).

## 4) JavaScript / Block Tests

- For complex editor logic, provide Jest-ready test skeletons.
- Validate selectors, reducers, and key transforms.

## 5) Done Criteria (Testing)

- Tests are included or scaffolded for critical logic.
- Test commands are provided in the final response.
- Any untested area is explicitly called out with rationale.
