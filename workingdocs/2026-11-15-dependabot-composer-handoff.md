# Session handoff — 2026-11-15

Dependabot alerts enabled on GitHub; Composer deps bumped within **Laravel 11**.

## Done

- Enabled repo vulnerability alerts + Dependabot security updates.
- Updated `composer.lock` to patched floors (key bumps):
  - `laravel/framework` **11.36.1 → 11.57.1** (includes critical TokenGuard fix ≥11.56.1)
  - `guzzlehttp/guzzle` **7.16.1**, `guzzlehttp/psr7` **2.13.3**
  - `league/commonmark` **2.10.7**, `league/flysystem` **3.36.0**
  - `nesbot/carbon` **3.15.1**, `psy/psysh` **0.12.24**, `phpunit/phpunit` **11.5.56**
  - Symfony 7.4.x components (`http-foundation`, `mime`, `mailer`, `routing`, `yaml`, …)
- Floored `composer.json` require: `laravel/framework: ^11.56.1`.

## Remaining open (need Laravel 12)

No Laravel 11 backport; Dependabot will stay open until `^12`:

| Severity | Advisory | Notes |
|----------|----------|-------|
| high | GHSA-5vg9-5847-vvmq / CVE-2026-48019 | CRLF in default email rule |
| medium | GHSA-crmm-hgp2-wgrp | Temporary signed URL path confusion |
| low | GHSA-jh5r-qr3c-85q8 | Debug page XSS |
| low | GHSA-63hm-g96r-2m2q | Task output injection |

## Suggested next work

1. Commit/push `composer.json` + `composer.lock` so GitHub re-scans and closes fixed alerts.
2. Decide whether to upgrade this API to **Laravel 12** to clear the remaining framework advisories.
