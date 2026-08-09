# Admin and promotion API contract

This document reflects the production OpenAPI contract deployed on 2026-08-09.
The Flutter administrator interface sends an administrator key in
the `x-api-key` header. Every route must also enforce its own permission
server-side. Responses may wrap their payload in a `data` object.

## Commercial management

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/api/admin/sponsorship?days=30` | Totals and `campaigns` list |
| `POST` | `/api/admin/sponsorship/campaigns` | Create a sponsored campaign |
| `PATCH` | `/api/admin/sponsorship/campaigns/:id` | Activate, pause or complete a campaign |
| `GET` | `/api/admin/editorial-recommendations` | Totals and `recommendations` list |
| `POST` | `/api/admin/editorial-recommendations` | Create a manual editorial placement |
| `DELETE` | `/api/admin/editorial-recommendations/:id` | Remove an editorial placement |
| `GET` | `/api/admin/revenue?days=30` | Revenue totals, `invoices` and `payments` |
| `PATCH` | `/api/admin/revenue/invoices/:id` | Update payment status and reference |

Campaign creation accepts `name`, `mangaId`, `budget`, `currency`, `startsAt`,
`endsAt`, `placement`, `targeting`, and `frequencyCap`:

- `budget` is an integer expressed in the currency's minor unit (for example,
  `1250` means EUR 12.50);
- `placement` is `home`, `search`, `catalog`, or `details`;
- `targeting` contains the arrays `platforms`, `countries`, and `languages`;
- `frequencyCap` is between 1 and 10,000.

Campaign records should include impressions, clicks, conversions, spend, CPM,
CPC, and CPA. Editorial creation uses the same placement values, a `priority`
between 0 and 100, and the optional `justification` field.

## Catalogue, moderation and operations

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/api/admin/catalog-quality` | Quality totals and `issues` |
| `POST` | `/api/admin/catalog-quality/scan` | Scan missing data, duplicates, EANs, covers and relations |
| `POST` | `/api/admin/catalog-quality/issues/:id/resolve` | Resolve an issue |
| `GET` | `/api/admin/moderation` | `reports`, `suspensions`, and `privacyRequests` |
| `PATCH` | `/api/admin/users/:id/role` | Change user role |
| `PATCH` | `/api/admin/users/:id/suspension` | Suspend or reactivate a user |
| `POST` | `/api/admin/moderation/cases/:id/resolve` | Resolve a report or privacy request |
| `GET` | `/api/admin/operations` | Deployments, jobs, caches, errors, quotas and feature flags |
| `POST` | `/api/admin/operations/jobs/:id/retry` | Retry a failed job |
| `POST` | `/api/admin/operations/cache/invalidate` | Invalidate one cache namespace |
| `PATCH` | `/api/admin/operations/feature-flags/:id` | Toggle a feature flag |

Volume-specific quality correction uses these additional deployed routes:

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/api/admin/volume-quality/issues` | List volume issues with filters and pagination |
| `POST` | `/api/admin/volume-quality/scan` | Scan volumes and create quality issues |
| `PATCH` | `/api/admin/volume-quality/issues/:id/resolve` | Resolve an issue with optional `resolutionNote` |
| `PATCH` | `/api/admin/volume-quality/issues/:id/reopen` | Reopen an issue |
| `PATCH` | `/api/admin/volumes/:id` | Correct the tome number and/or sub-series relation |

## Audit and exports

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/api/admin/audit?page=1&limit=50` | Audit `events`, `exports`, and `permissionChanges` |
| `POST` | `/api/admin/exports` | Request an asynchronous CSV or JSON export |

Every mutation and export must append an immutable audit event containing the
actor ID, permission used, action, target type and ID, timestamp, request ID,
result, and a redacted change summary. Secrets, tokens and raw personal data
must never be stored in audit metadata.

Recommended permissions follow `admin.<module>.read` and
`admin.<module>.write`, with separate elevated permissions for role changes,
suspensions, privacy requests, cache invalidation, feature flags, exports and
financial payment updates.

## Promotion delivery and tracking

The client can already identify the following optional metadata on a hydrated
volume, display a visible label, and record impressions, clicks and conversions:

```json
{
  "source": "sponsored",
  "sponsorshipMeta": {
    "campaignId": "campaign-id",
    "placement": "home"
  }
}
```

Editorial items use `source: "editorial"` and an `editorialMeta` object with at
least the placement and recommendation ID. Organic items use
`source: "organic"` or omit promotion metadata.

Sponsored events use the deployed route below. The client creates a stable,
privacy-safe anonymous identifier, deduplicates impressions within the current
session, and retains click attribution for seven days.

| Method | Route | Body |
| --- | --- | --- |
| `POST` | `/api/admin/sponsorship/campaigns/:id/events` | `eventId`, `eventName`, `occurredAt`, `anonymousUserId` |

`eventName` is `impression`, `click`, or `conversion`. Event IDs are unique so
the API can process retries idempotently.

### Production delivery contract

The application requests active placements through the deployed
`/api/recommendations/home` and `/api/recommendations/me` endpoints with
`includePlacements=true`. These endpoints return hydrated volume items with the
metadata above. Campaign `mangaId` values are resolved to a representative
hydrated volume because the application renders volumes rather than bare
sub-series identifiers.

## Collection import contract

The application performs CSV, JSON, EAN/ISBN and free-text parsing locally. It
matches the resulting rows against the existing catalogue routes and commits
only confirmed volume identifiers through the existing idempotent
`/api/users/me/owned` route. No server-side import route is needed for these
formats.

Mangacollec account retrieval is performed server-side because Web clients
must not bypass CORS, scrape with user cookies or receive Mangacollec passwords.
The application calls:

| Method | Route | Permission |
| --- | --- | --- |
| `POST` | `/api/users/me/collection-imports/mangacollec/preview` | Authenticated user JWT and mobile API key |

Request:

```json
{
  "profile": "Mangacollec username or HTTPS profile URL"
}
```

The API may use an official Mangacollec API or a legally accessible public
profile. It must never request or store the user's Mangacollec password or
session cookie. It must protect against SSRF with a strict Mangacollec hostname
allow-list, use bounded timeouts and response sizes, rate-limit requests and
return normalized raw rows under `data.volumes` or `data.items`. Each row may
contain `title`, `volumeNumber`, `ean`, `subSeries` and `read`. The Flutter client
performs catalogue matching, duplicate detection, preview, correction, commit,
progress, cancellation and local undo history.

This contract intentionally provides no periodic or post-import synchronization.

## Personalized recommendation contract

The personalized ranking returned by `GET /api/recommendations/me` should use
owned and read volumes, wishlist, followed series and similarities between
genres, authors and publishers. Organic scoring must remain independent from
sponsored placement selection.

Each organic result should include a privacy-safe explanation:

```json
{
  "recommendationMeta": {
    "primarySignal": "genre",
    "explanation": "Matches genres you enjoy"
  }
}
```

Supported signals include `genre`, `author`, `publisher`, `wishlist`,
`followed`, `popular` and `cold_start`. Explanations may instead use a `reasons`
array. They must not reveal another user's activity.

The application uses these authenticated routes:

| Method | Route | Purpose |
| --- | --- | --- |
| `PATCH` | `/api/users/me/recommendation-preferences` | Store genres, recent-release preference, diversity and popular fallback |
| `POST` | `/api/recommendations/feedback` | Record `hide`/`hidden` or `irrelevant` feedback for one `volumeId` |

Feedback must immediately exclude the volume from later personalized pages,
remain idempotent and not alter sponsored billing events. Preferences and
feedback require both the mobile API key and the authenticated user's Bearer
JWT. Cold-start recommendations use explicit preferences when available, then
privacy-safe popular choices. Diversity must reserve some discovery capacity
instead of trapping a user in a single genre.

## Analytics comparisons and exports

The analytics summary, product, notification, sponsorship and revenue GET routes
accept `comparePrevious=true`. When requested, they should return the same metric
shape for the immediately preceding period under `data.previous`,
`data.previousPeriod` or `data.comparison.previous`.

`POST /api/admin/exports` accepts the additional resources
`analytics-summary`, `analytics-product`, `analytics-notifications` and
`editorial`, in addition to the existing administration modules. Generated
exports must be audited, permission-checked, redacted and downloadable only from
an expiring HTTPS URL on `api.mymangatheque.com`.
