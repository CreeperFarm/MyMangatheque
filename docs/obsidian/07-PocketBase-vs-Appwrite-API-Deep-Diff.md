---
tags:
  - migration
  - pocketbase
  - appwrite
  - api
  - architecture
created: 2026-04-17
---

# PocketBase -> Appwrite + API: Full Deep-Diff Documentation

## Why this document exists
This file is the full reference of what changed between:
- **Initial runtime model**: Flutter app directly talking to **PocketBase**
- **Current runtime model**: Flutter app using **Appwrite + MyMangatheque API**

Goal:
- give you a precise migration map
- explain where regressions come from
- provide a practical debug checklist to fix issues faster

Scope:
- app architecture, auth/session, API keys, data fetching, relation expand, search, home feed, avatar/storage, reviews, admin, realtime, notifications

---

## 1) High-level architecture shift

## Before (PocketBase direct)
- App called PocketBase collections directly (`getOne`, `getList`, `getFullList`, `create`, `update`, `delete`).
- Auth token was managed by PocketBase `authStore` + local token persistence.
- Relations were expanded by PocketBase itself (`expand=...` server-side).
- Realtime used native PocketBase subscriptions.
- Admin used PocketBase `_superusers`.

## Now (Appwrite + API split)
- App uses two distinct backends:
  - **Appwrite**: identity/session, storage upload, reviews collection access, push target registration
  - **MyMangatheque API**: business/catalog endpoints (`/api/series`, `/api/volumes`, `/api/users/me/*`, recommendations, analytics)
- App no longer depends on PocketBase runtime services.
- A compatibility layer in `AppwriteConnector` emulates old `RecordModel` usage and rebuilds legacy-like `expand` structures.
- Realtime for collections is now a polling-compatible stream (15s timer), not native DB subscription.

---

## 2) Service-level mapping (old -> new)

| Old service | New service | Responsibility now |
|---|---|---|
| `PocketBaseConnector` | `AppwriteConnector` | Main facade used by UI; normalizes API payloads; compatibility methods |
| PocketBase SDK direct | `AppwriteClientService` | Appwrite account/session/storage/realtime wrappers |
| N/A | `MobileApiClient` | HTTP API wrapper, `x-api-key`, optional Bearer JWT, retries |
| N/A | `MobileApiKeyManager` | Stores/refreshes mobile API key (`key + expiresAt`) |
| `PocketBaseAdminConnector` | `AdminConnector` | Admin API-key flow against REST admin endpoints |
| `utils.dart` `listen()` extension | `CompatSubscription` + polling in `AppwriteConnector` | Legacy subscription compatibility |

Files:
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque/lib/src/back/services/appwrite.dart`
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque/lib/src/back/services/appwrite_client.dart`
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque/lib/src/back/services/api/mobile_api_client.dart`
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque/lib/src/back/services/api/mobile_api_key_manager.dart`
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque/lib/src/back/services/admin_service.dart`

---

## 3) Dependency-level migration

## Removed
- `pocketbase` package (runtime connector removed)

## Added
- `appwrite`
- `flutter_web_auth_2` (mobile OAuth callback flow)
- `flutter_secure_storage` (secure key persistence, with shared prefs fallback)

## Kept but role changed
- `shared_preferences`: now fallback storage + app preferences (language/adult-content/cache keys)
- `http`: now central for API transport

---

## 4) Auth and session model changes

## Before
- Auth entirely through PocketBase (`authWithPassword`, `authWithOAuth2`, `authRefresh`)
- PB auth token persisted through `AsyncAuthStore` and local token key
- OAuth integrated through PocketBase callback and custom tabs

## Now
- Auth authority is Appwrite (`Account`)
- Email/password uses Appwrite sessions
- Google OAuth mobile uses `FlutterWebAuth2` with custom callback scheme:
  - `appwrite-callback-<projectId>://oauth2success`
  - `appwrite-callback-<projectId>://oauth2failure`
- Guest/anonymous session is attempted at bootstrap
  - if disabled in project, app logs fallback behavior and continues

## Important behavior differences
- App can run in guest mode and still call public API endpoints.
- Some calls now require **authenticated user session**, not just “any token”.
- Error `user_session_already_exists` is handled differently than before:
  - new flow can reuse existing active session.

---

## 5) Authorization model: from single token to dual-key model

## Before (PocketBase)
- One auth model: PB token in authStore.
- Collection permissions/filtering applied in PB.

## Now (Appwrite + API)
- Two headers can be involved:
  - `x-api-key`: mobile API key from `/api/auth/keys/mobile`
  - `Authorization: Bearer <appwrite-jwt>`: required for `/api/users/me*` protected endpoints

## New key/JWT lifecycle
- `MobileApiClient.ensureApiKey()` ensures a valid key.
- Key refreshes automatically when close to expiration (`T-5min`) or after `401/403`.
- JWT is cached in memory and refreshed with protection against concurrent refresh storms.
- JWT rate limit (`429`) is explicitly handled with cooldown reuse.

## Practical consequence
- You can now see failures that did not exist before:
  - `Missing authenticated user session for Bearer request`
  - `general_rate_limit_exceeded` on JWT creation
  - API key refresh loops if auth/session state is unstable

---

## 6) Data source shift (collection calls -> REST endpoints)

## Before
- UI requested collections directly:
  - `getFullList`, `getList`, `getOne`, with filters/sort/expand native PB

## Now
- UI still calls connector methods, but connector uses REST:
  - `/api/series`
  - `/api/sub-series`
  - `/api/volumes`
  - `/api/authors`
  - `/api/editors`
  - `/api/genres`
  - `/api/users/me/owned`
  - `/api/users/me/followed`
  - `/api/recommendations/home`
  - `/api/recommendations/me`

Also present in API docs:
- `/api/volumes/home-feed` (available endpoint)
- analytics and auth-key admin endpoints

Source references:
- `/Users/creeperfarm/Documents/GitHub/MyMangatheque-API/logs/api-doc.json`

---

## 7) Data contract and naming changes (critical)

The API/Appwrite schema uses new canonical keys. UI historically expects legacy names.  
`AppwriteConnector` now performs normalization.

## Typical examples
- Series:
  - API: `titleFr`, `coverUrl`, `subSeries`
  - UI legacy compat: `title`, `image`, `sub_series`
- Sub-series:
  - API: `series`, `editors`, `coverUrl`, `volumes`
  - Compat: `serie` + `series`, `editor` + `editors`, `image`, `volumes`
- Volume:
  - API: `tomeNumber`, `publicationDate`, `bookLink`, `infoVolume`, `subSeries`
  - Compat: `tome_number`, `release`, `book_link`, `info`, `sub_series`
- Owned/followed user collections:
  - API: `ownedVolumes.volumeId`, `followedSubSeries.subSeriesId`
  - Compat: `owned.volume`, `followed.sub_serie`

If normalization misses a field, UI displays old fallback values (`null`, `0`, empty sections).

---

## 8) Expand behavior: server-side PB -> client-side reconstruction

## Before
- `expand` was delegated to PocketBase (`getOne(..., expand: 'authors,editor,...')`).

## Now
- `getOneExpand` uses `_appendExpand(...)` in app code:
  - fetches related entities via additional API requests
  - infers missing relations when schema linkage is partial
  - creates both key variants for compatibility (`series` and `serie`, `editor` and `editors`, `sub_serie` and `sub_series`)

This is one of the biggest behavior changes and a major source of:
- partial detail pages
- slow loads (many relation fetches)
- null relation blocks when IDs are missing/inconsistent

---

## 9) Pagination and list loading differences

## Before
- `getFullList()` often loaded everything in one PocketBase call.

## Now
- Catalog endpoints are paginated.
- Connector has:
  - `_fetchRecordPage(...)` for paged views
  - `fetchAllPages(...)` for full list rebuilds
- Search and home now lazy-load pages and merge unique IDs.

Consequences:
- wrong `totalPages` metadata can break infinite scroll logic
- if dedup removes all items in a page, you can hit false “end reached”
- loading can be slower if many “expand” operations run per list item

---

## 10) Home page algorithm shift

## Before
- Home sorted all volumes by release descending (`getCollectionFullListOrder('volumes', '-release')`).

## Now
- Home uses recommendation endpoints:
  - Authenticated: `/api/recommendations/me`
  - Guest fallback: `/api/recommendations/home`
- Parameter `untilDays=7` used to include near-future window and older descending feed from API side.

This means home ranking is no longer computed in Flutter from raw volumes list.

---

## 11) Search behavior shift

## Before
- Search mostly series-only with in-memory filter on full series list.
- Author/editor search was incomplete WIP.

## Now
- Explicit mode switch (`series`, `authors`, `editors`) with dropdown.
- Paged loading per selected mode via `getCollectionPage(...)`.
- Accent-insensitive normalization and deep token extraction for matching.

Current failure mode to watch:
- if backend pagination/metadata is inconsistent, query may not scan all pages.
- if normalization misses a title/name field, match text becomes incomplete.

---

## 12) Owned/followed logic changes

## Before
- Every check used direct PB filtered query:
  - `user='<id>'&&volume='<id>'`
  - `user='<id>'&&sub_serie='<id>'`

## Now
- Uses `/api/users/me/owned` and `/api/users/me/followed`.
- Connector builds in-memory indexes:
  - owned volume IDs
  - owned read-state map
  - followed sub-series IDs
- Cache TTL currently short (25s) and invalidated on mutations.

Result:
- less repeated network calls on tiles
- but stale-index windows can appear if invalidation is missed

---

## 13) Reviews path changed (important exception)

Business entities are API-driven, but reviews are currently handled directly in Appwrite DB:
- database `manga-db`
- collection `reviews`
- methods:
  - `getMyVolumeReview`
  - `getVolumeReviews`
  - `upsertVolumeReview`

Implication:
- review errors may not appear in API logs
- review permissions must be correct in Appwrite collection security

---

## 14) Avatar upload path changed

## Before
- Avatar uploaded to PB collection file field directly.

## Now
1. Upload file to Appwrite Storage bucket `user-bucket`.
2. Build Appwrite file view URL.
3. PATCH `/api/users/me` with `coverURL`.

Common breakpoints:
- bucket create/update permissions missing for authenticated users
- Appwrite SDK response parsing edge case (`Null` to `bool`) after upload
- authenticated session missing, causing 401

---

## 15) Realtime and notifications changed

## Before
- PocketBase native realtime subscriptions.

## Now
- Collection change listener in connector emits polling events every 15s.
- Notifications service:
  - can register push target via Appwrite account
  - includes fallback polling heartbeat (`/api/analytics/health`) every 5 minutes
  - creates in-app notification entries from fallback responses

This is not equivalent to real realtime data sync.

---

## 16) Admin model changed

## Before
- Admin login using PocketBase `_superusers` credentials.

## Now
- Admin login by API key (`AdminConnector`).
- Admin key stored in secure storage (fallback shared prefs).
- Admin actions call REST endpoints (`/api/authors`, `/api/genres`, `/api/volumes`, analytics).

---

## 17) Legacy compatibility layer (why some old code still works)

Compatibility helpers were intentionally kept:
- `typedef RecordModel = ApiRecordModel`
- `typedef RecordSubscriptionEvent = ApiRecordSubscriptionEvent`
- `connector().collection(...).subscribe(...)` via `AppwriteCompatClient`
- Filter parser accepts old-like clauses:
  - `field='value'`
  - `date?<="..."`
  - `date?>="..."`

But this compatibility is emulated on client side, not native DB behavior.

---

## 18) Known migration incidents already observed and root causes

## OAuth `redirect_uri_mismatch`
- Cause: Appwrite/proxy chain generated `http://...` redirect URI instead of `https://...`.
- Required fix points:
  - Appwrite domain/force-https settings
  - Forwarded headers (`Host`, `X-Forwarded-Proto`, `X-Forwarded-Port`)
  - Google OAuth authorized redirect URI exact match

## Appwrite 500 `general_unknown` during OAuth
- Seen with schema mismatch (`Unknown attribute: emailCanonical`).
- Root cause: incomplete Appwrite migration state; resolved by running migrations.

## Avatar upload unauthorized (401)
- Cause: bucket permissions do not allow current authenticated role to create/update file.

## JWT rate-limit 429 cascade
- Cause: too many rapid JWT generations (often due repeated per-tile checks).
- Mitigation in code:
  - JWT cache
  - in-flight dedupe
  - cooldown on 429

## Session already exists on Google sign-in
- Now detected and treated as reusable active session scenario.

## Null data / missing blocks on detail pages
- Usually relation normalization/expand inference mismatch, not only UI rendering.

---

## 19) Why some pages became slower than PocketBase

Main reasons:
- one old PB expand call can now become many API calls + local relation inference calls
- client-side expand fallback recursively fetches missing relations
- user-specific checks (owned/read/follow) can trigger extra protected requests
- when JWT/API key state is unstable, retries add latency

Optimization directions:
- batch relation expansion in API endpoints
- return richer expanded payloads server-side for detail pages
- reduce per-item ownership checks (already partially optimized with indexes)
- increase strategic cache TTL where safe

---

## 20) Debug playbook (screen-by-screen)

## A) If a detail page shows `null` fields
1. Log raw API payload for the entity endpoint (`/api/volumes/{id}`, `/api/series/{id}`, etc.).
2. Confirm normalized keys exist after `_normalize*` methods.
3. Confirm relation IDs are valid (not empty, `"null"`, `"undefined"`).
4. Confirm `_appendExpand` receives expected expand string.
5. Check whether inferred relation fallback was used.

## B) If loading is infinite
1. Check page future lifecycle in widget (`initState` vs `build` re-creation).
2. Validate pagination metadata returned by backend.
3. Ensure `_reachedEnd` logic also handles short page/empty page.
4. Add timeout on blocking fetches.

## C) If search misses known items
1. Ensure selected mode is correct (`series/authors/editors`).
2. Confirm API returns all pages for that mode.
3. Verify title/name fields are populated after normalization.
4. Check dedupe logic and `_reachedEnd` condition.

## D) If owned/followed status is wrong
1. Validate `/api/users/me/owned` and `/api/users/me/followed` responses.
2. Check Bearer JWT availability for protected endpoint.
3. Invalidate and rebuild indexes after mutation.
4. Verify cache freshness windows.

## E) If avatar upload fails
1. Confirm authenticated non-guest session exists.
2. Validate bucket `user-bucket` create/update permissions.
3. Confirm uploaded file URL format and `coverURL` patch to `/api/users/me`.

---

## 21) Endpoint mapping quick reference

| Legacy intent | New endpoint/path |
|---|---|
| list series | `GET /api/series` |
| one series | `GET /api/series/{id}` |
| list sub-series | `GET /api/sub-series` |
| one sub-series | `GET /api/sub-series/{id}` |
| list volumes | `GET /api/volumes` |
| one volume | `GET /api/volumes/{id}` |
| list authors | `GET /api/authors` |
| one author | `GET /api/authors/{id}` |
| list editors | `GET /api/editors` |
| one editor | `GET /api/editors/{id}` |
| list genres | `GET /api/genres` |
| user profile | `GET /api/users/me` (Bearer required) |
| patch user profile | `PATCH /api/users/me` (Bearer required) |
| owned list | `GET /api/users/me/owned` (Bearer required) |
| add owned | `POST /api/users/me/owned` (Bearer required) |
| patch owned read-state | `PATCH /api/users/me/owned/{volumeId}` (Bearer required) |
| remove owned | `DELETE /api/users/me/owned/{volumeId}` (Bearer required) |
| followed list | `GET /api/users/me/followed` (Bearer required) |
| add followed | `POST /api/users/me/followed` (Bearer required) |
| remove followed | `DELETE /api/users/me/followed/{subSeriesId}` (Bearer required) |
| recommendation feed guest | `GET /api/recommendations/home` |
| recommendation feed user | `GET /api/recommendations/me` (Bearer required) |
| mobile API key | `POST /api/auth/keys/mobile` |

---

## 22) Data/schema references used
- API contract snapshot:
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque-API/logs/api-doc.json`
- Appwrite schema snapshot:
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque-API/logs/appwrite-schema.json`
- App migration docs in app repo:
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque/docs/obsidian/00-Migration-Overview.md`
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque/docs/obsidian/02-Auth-ApiKey-2h.md`
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque/docs/obsidian/03-Data-Mapping.md`
  - `/Users/creeperfarm/Documents/GitHub/MyMangatheque/docs/obsidian/06-Appwrite-Proxy-OAuth-Fix.md`

---

## 23) Practical takeaway

The migration was not a simple backend swap. It introduced:
- a **new trust model** (Appwrite session + API key + optional JWT Bearer)
- a **new contract model** (REST payload normalization and aliasing)
- a **new relation model** (client-side expand reconstruction)
- and a **new performance profile** (more network orchestration client-side)

Most persistent bugs are not “UI-only”; they are often caused by one of:
- auth state mismatch
- protected endpoint access (missing Bearer session)
- incomplete normalization mapping
- relation inference gaps
- pagination metadata inconsistencies
- Appwrite permission/proxy configuration mismatch

