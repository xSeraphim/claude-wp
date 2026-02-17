# WordPress MCP Integration (Optional, Recommended)

Use this guide when a WordPress MCP server is available for live context.

## Why use MCP with this skill

This skill is strong on standards and static code quality. MCP adds live runtime context:
- active plugins/themes,
- option values,
- post/comment/user counts,
- database shape and operational constraints.

With MCP, the agent can reason from real site state instead of assumptions.

## Recommended workflow

1. Use MCP to inspect environment/site state.
2. Form implementation plan using live constraints.
3. Generate code per skill standards.
4. Run preflight + lint checks.
5. Validate outcome via MCP/WP-CLI queries.

## Safe MCP usage principles

- Prefer read-only inspection before proposing writes.
- Summarize findings and assumptions in the final response.
- For destructive operations, require explicit user intent.
