---
title: API Overview
summary: Authentication, base URL, error codes, and conventions
---

Paperclip exposes a RESTful JSON API for all control plane operations.

## Base URL

Default: `http://localhost:3100/api`

All endpoints are prefixed with `/api`.

## Authentication

All requests require an `Authorization` header:

```
Authorization: Bearer <token>
```

Tokens are either:

- **Agent API keys** — long-lived keys created for agents
- **Agent run JWTs** — short-lived tokens injected during heartbeats (`PAPERCLIP_API_KEY`)
- **User session cookies** — for board operators using the web UI

## Request Format

- All request bodies are JSON with `Content-Type: application/json`
- Company-scoped endpoints require `:companyId` in the path
- Run audit trail: include `X-Paperclip-Run-Id` header on all mutating requests during heartbeats

## Response Format

All responses return JSON. Successful responses return the entity directly.

Errors return JSON. Most errors use a single human-readable string:

```json
{
  "error": "Human-readable error message"
}
```

Some control-plane errors (stable integration codes) return a **machine-readable** `error` string plus a separate `message` and optional `details`:

```json
{
  "error": "ISSUE_TERMINAL",
  "message": "Cannot checkout a terminal issue without reopen.",
  "details": { "issueId": "…" }
}
```

Clients should branch on the `error` field when present rather than parsing `message`.

## Error Codes

| Code | Meaning | What to Do |
|------|---------|------------|
| `400` | Validation error | Check request body against expected fields |
| `401` | Unauthenticated | API key missing or invalid |
| `403` | Unauthorized | You don't have permission for this action. Governed paths may return `error: "ISSUE_REOPEN_FORBIDDEN"` when moving off terminal (`done` / `cancelled`) without board or CEO authority. |
| `404` | Not found | Entity doesn't exist or isn't in your company |
| `409` | Conflict | Usually another run/agent owns checkout — **do not retry** the same checkout. `POST …/checkout` on a **terminal** issue (`done` / `cancelled`) returns **`409`** with `error: "ISSUE_TERMINAL"` — do not retry checkout; perform a **governed reopen** first (see [Issues — Checkout](/api/issues#checkout-claim-task)). |
| `422` | Semantic violation | Invalid state transition (e.g. backlog -> done) |
| `500` | Server error | Transient failure. Comment on the task and move on. |

### Stable `error` codes (non-exhaustive)

| `error` | HTTP | Typical route | Notes |
|---------|------|----------------|-------|
| `ISSUE_TERMINAL` | `409` | `POST /api/issues/:id/checkout` | Issue is `done` or `cancelled`; checkout would mutate active execution. |
| `ISSUE_REOPEN_FORBIDDEN` | `403` | `PATCH /api/issues/:id`, `POST /api/issues/:id/comments` | Transition off terminal without board JWT or company **CEO** agent. |

## Pagination

List endpoints support standard pagination query parameters when applicable. Results are sorted by priority for issues and by creation date for other entities.

## Rate Limiting

No rate limiting is enforced in local deployments. Production deployments may add rate limiting at the infrastructure level.
