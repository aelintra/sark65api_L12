# workingdocs

Agent/session handoff notes for **sark65api_L12** (SARK V65 / Laravel 12 API) work. Keep entries dated and factual so the next agent can continue without re-discovering context.

Do **not** store secrets (API tokens, DB passwords, sudo passwords, customer credentials) here.

## Naming

| Kind | Filename pattern | Purpose |
|------|------------------|---------|
| Handoff | `YYYY-MM-DD[-DD]-short-slug-handoff.md` | What was done, env, key files, open TODOs, suggested next work |
| TODO | `YYYY-MM-DD-todo-short-slug.md` | Standalone decision or follow-up tracked across sessions |

Update this README’s **Latest handoff** / **Open TODOs** lists when you add or close notes.

## Lab hosts

| Role | Host | Access |
|------|------|--------|
| **Deb builder** | `192.168.1.78` (`deb11-1`) | SSH `tech@192.168.1.78`. Repos under `~/Git/`. Mac has no `rsync` — sync with `tar`/`scp`. Cannot push to GitHub over HTTPS; push from Mac. |
| Lab / customer rebuild | `192.168.1.130` (`adler`) | SSH `tech@192.168.1.130`. **Passwordless sudo** (`sudo -n`). SARK V65 + API target. |
| Customer test VM | `192.168.9.4` (`adler-pbx-02`) | SSH `pbxadmin@192.168.9.4` (key). Sudo **requires password**. |
| Other test | `192.168.1.12` (`iitac2404`) | SSH `tech@192.168.1.12`. |

## Repo context

| Item | Notes |
|------|--------|
| Mac path | `/Users/jeffstokoe/GiT/sark65api_L12` |
| Remote | `https://github.com/aelintra/sark65api_L12.git` |
| Stack | Laravel 12, PHP ≥ 8.2, Sanctum; runs on SARK V65 |
| Public docs | `docs/` + `mkdocs.yml` → GitHub Pages (`site/`) |

## Latest handoff

- [2026-11-15-laravel12-upgrade-handoff.md](./2026-11-15-laravel12-upgrade-handoff.md) — Laravel **11.57.1 → 12.72.0**; Sanctum **4.4.0**; `composer audit` clean; Pest 2/2 pass.
- [2026-11-15-dependabot-composer-handoff.md](./2026-11-15-dependabot-composer-handoff.md) — prior L11 session: Dependabot enable + Composer bumps to **11.57.1**; **46** fixed / **4** open (now addressed by L12).

## Open TODOs

- Confirm Dependabot UI clears the 4 framework alerts after this push.
- Optional lab smoke on `192.168.1.130` after deploy.
