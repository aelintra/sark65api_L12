# Session handoff — 2026-11-15

Created `workingdocs/`, enabled Dependabot, bumped Composer deps within **Laravel 11**, committed and pushed. Tip: `525bb25` on `main`.

## Environment

| Role | Host / path | Notes |
|------|-------------|--------|
| Mac | `/Users/jeffstokoe/GiT/sark6api_L11` | Branch `main` = `origin/main` @ `525bb25`. |
| GitHub | `aelintra/sark6api_L11` | Vulnerability alerts + Dependabot security updates **enabled**. |
| Runtime | Laravel **11.57.1** | PHP ≥ 8.2; Sanctum API. |

## Done this session

1. **`workingdocs/`** — same format as sail-6 (`README` index + dated handoffs).
2. **Dependabot** — alerts were disabled; enabled vulnerability alerts + automated security fixes.
3. **Composer security bumps** (L11-compatible):
   - `laravel/framework` **11.36.1 → 11.57.1** (critical TokenGuard ≥11.56.1)
   - `guzzlehttp/guzzle` **7.16.1**, `guzzlehttp/psr7` **2.13.3**
   - `league/commonmark` **2.10.7**, `league/flysystem` **3.36.0**
   - `nesbot/carbon` **3.15.1**, `psy/psysh` **0.12.24**, `phpunit/phpunit` **11.5.56**
   - Symfony **7.4.x** (`http-foundation`, `mime`, `mailer`, `routing`, `yaml`, …)
   - Floored `composer.json`: `laravel/framework: ^11.56.1`
4. **Commit/push** — `525bb25` *Bump Composer deps for Dependabot CVEs and add workingdocs.*
5. **Rescan** — **46** alerts fixed; **4** remain (Laravel 12 only).

## Dependabot status (post-push)

| State | Count |
|-------|------:|
| Fixed | 46 |
| Open | 4 (all `laravel/framework`) |

### Still open (need Laravel ≥12)

| # | Severity | Advisory | Patched in |
|---|----------|----------|------------|
| 21 | high | GHSA-5vg9-5847-vvmq — CRLF in default email rule | 12.60.0 |
| 22 | medium | GHSA-crmm-hgp2-wgrp — temporary signed URL path confusion | 12.61.1 |
| 44 | low | GHSA-jh5r-qr3c-85q8 — debug page XSS | 12.69.0 |
| 50 | low | GHSA-63hm-g96r-2m2q — task output injection | 12.71.0 |

No Laravel 11 backports for these.

## Key files

| Area | Path |
|------|------|
| Deps | `composer.json`, `composer.lock` |
| Handoffs | `workingdocs/README.md`, this file |
| Security UI | https://github.com/aelintra/sark6api_L11/security/dependabot |

## Open TODOs

1. Decide **Laravel 12 upgrade** to clear the 4 remaining framework alerts (repo is intentionally `sark6api_L11`).
2. After any L12 bump, re-run Dependabot / `composer audit` and update this handoff.

## Suggested next work

1. If security posture requires it: plan/execute Laravel 11 → 12 upgrade (app code + Sanctum + Pest).
2. Otherwise leave L11 and accept the 4 open advisories until an L12 project is cut.
3. Optional: smoke API against lab `192.168.1.130` after deploy of updated vendor tree.
