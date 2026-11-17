# Session handoff — 2026-11-16 (installer, guest 401, drop vxt)

Follow-on to [2026-11-16-docs-install-lab135-handoff.md](./2026-11-16-docs-install-lab135-handoff.md). Added packaged installer, fixed unauthenticated `/api/*` JSON 401, permanently removed dead `extensions/vxt`. Lab target remains **192.168.1.135** (Adler `.130` deferred).

## Done

1. **`sarkapi_installer.sh`** at repo root — mirrors `docs/installation.md` (packages, Composer, production `.env` tweaks, DB symlink, www-data ownership, **root-owned** sudoers copy via `install`, Apache 44300, Shorewall rule). Must run as root from the app tree. First admin still manual (tinker).
2. **Guest JSON 401** in `bootstrap/app.php`: `redirectGuestsTo` returns null for `api/*`; `shouldRenderJsonWhen` for `api/*` so missing `Accept` no longer yields `Route [login] not defined`. Covered by `tests/Feature/UnauthenticatedApiTest.php` (2 Pest cases, passing).
3. **Removed** commented `POST extensions/vxt` from `routes/api.php` (never had a controller method).
4. **Docs:** `docs/installation.md` now points at the installer first.

## Lab smoke on 192.168.1.135 (same day, follow-on)

Synced uncommitted Mac tree files via `scp` (`.135` was still at `debb9e9`; local changes not pushed yet): `bootstrap/app.php`, `routes/api.php`, `sarkapi_installer.sh`, `docs/installation.md`. Cleared config/route/cache.

| Check | Result |
|-------|--------|
| `GET /up` | 200 |
| Guest `GET /api/auth/whoami` (no `Accept`) | **401** `{"message":"Unauthenticated."}` |
| Login `apitest@lab.local` | 200 + token |
| Read sweep (whoami, syscommands, pbxrunstate, tenants, destinations, extensions, queues, trunks, inboundroutes, ivrs, routes, sysglobals, CoreStatus, daytimers, cosrules) | all **200** |
| `POST /extensions/unprovisioned` pkey **1999** cluster `default` | **201** |
| `GET /extensions/1999` + list | 200; list count 1 |
| `GET /syscommands/commit` | 200 System Commit issued |
| `DELETE /extensions/1999` + commit again | **204** / 200; list empty; `pbxrunstate` still true |

Note: lab admin password was reset for this session via tinker — reset again if needed; do not store it here.

## Not done / deferred

- Deploy / smoke on Adler `192.168.1.130` — user chose stay on `.135` for now.
- Dependabot UI confirm still open.

## Key files

| Area | Path |
|------|------|
| Installer | `sarkapi_installer.sh` |
| Auth guest fix | `bootstrap/app.php` |
| Routes | `routes/api.php` |
| Install docs | `docs/installation.md` |
| Tests | `tests/Feature/UnauthenticatedApiTest.php` |

## Suggested next work

1. Push / deploy these changes to `.135` (`git pull` + reload) and re-smoke `/up` + guest 401 without `Accept`.
2. Optional: broader API smoke on `.135`.
3. Later: Adler `.130` with `./sarkapi_installer.sh` if desired.
