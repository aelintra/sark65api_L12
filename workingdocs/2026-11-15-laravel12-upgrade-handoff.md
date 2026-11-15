# Session handoff — 2026-11-15 (Laravel 12 upgrade)

Upgraded this repo (`sark65api_L12`) from Laravel **11.57.1** to **12.72.0** so the four remaining Dependabot framework advisories are cleared. No application code changes were required.

## Environment

| Role | Host / path | Notes |
|------|-------------|--------|
| Mac | `/Users/jeffstokoe/GiT/sark65api_L12` | Branch `main`; remote `aelintra/sark65api_L12`. |
| GitHub | `aelintra/sark65api_L12` | Cut from L11 API; Dependabot target for L12-only CVEs. |
| Runtime | Laravel **12.72.0** | PHP ≥ 8.2 (verified on 8.4.16); Sanctum **4.4.0**. |

## Done this session

1. **`composer.json` floors**
   - `laravel/framework`: `^11.56.1` → `^12.71.0` (covers all 4 open advisories; patched through **12.71.0**)
   - `laravel/sanctum`: `^4.4.0`
   - `laravel/tinker`: `^2.10.1`
2. **`composer update`** — resolved to:
   - `laravel/framework` **12.72.0**
   - `laravel/sanctum` **4.4.0**, `laravel/tinker` **2.11.1**
   - `laravel/sail` **1.70.0**, `laravel/pail` **1.3.0**, `laravel/pint` **1.32.3**
   - `symfony/yaml` **8.1.x** (transitive)
3. **Security** — `composer audit`: **No security vulnerability advisories found.**
4. **Smoke** — `php artisan --version` → 12.72.0; Pest **2 passed**.
5. **Docs** — `docs/index.md` Laravel version string → 12; this handoff + `workingdocs/README.md` index.

### Advisories closed by ≥12.71.0

| Prev # | Severity | Advisory | Patched in |
|--------|----------|----------|------------|
| 21 | high | GHSA-5vg9-5847-vvmq — CRLF in default email rule | 12.60.0 |
| 22 | medium | GHSA-crmm-hgp2-wgrp — temporary signed URL path confusion | 12.61.1 |
| 44 | low | GHSA-jh5r-qr3c-85q8 — debug page XSS | 12.69.0 |
| 50 | low | GHSA-63hm-g96r-2m2q — task output injection | 12.71.0 |

## L12 upgrade notes (app impact)

Official L11→L12 guide is mostly dependency bumps. Checked this app:

| Change | Impact here |
|--------|-------------|
| `HasUuids` → UUIDv7 | None — models do not use `HasUuids` |
| Carbon 3 required | Already on Carbon 3.x |
| Local disk root `storage/app/private` | Already configured in `config/filesystems.php` |
| Pest / PHPUnit | Already Pest **^3** / PHPUnit **11** |
| App / bootstrap / Sanctum aliases | Unchanged; package discovery OK |

## Key files

| Area | Path |
|------|------|
| Deps | `composer.json`, `composer.lock` |
| Bootstrap | `bootstrap/app.php`, `bootstrap/providers.php` |
| Handoffs | `workingdocs/README.md`, this file |
| Prior L11 close-out | `workingdocs/2026-11-15-dependabot-composer-handoff.md` |

## Open TODOs

1. Confirm GitHub Dependabot UI shows the 4 framework alerts resolved for `sark65api_L12`.
2. Optional: deploy updated vendor tree to lab `192.168.1.130` and smoke the API.

## Suggested next work

1. Lab smoke against Adler after deploy.
2. Keep Dependabot enabled; re-run `composer audit` after future framework minors.
