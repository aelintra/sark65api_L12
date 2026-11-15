# workingdocs

Agent/session handoff notes for **sark6api_L11** (SARK V65 / Laravel 11 API) work. Keep entries dated and factual so the next agent can continue without re-discovering context.

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
| Mac path | `/Users/jeffstokoe/GiT/sark6api_L11` |
| Remote | `https://github.com/aelintra/sark6api_L11.git` |
| Stack | Laravel 11, PHP ≥ 8.2, Sanctum; runs on SARK V65 |
| Public docs | `docs/` + `mkdocs.yml` → GitHub Pages (`site/`) |

## Latest handoff

- [2026-11-15-dependabot-composer-handoff.md](./2026-11-15-dependabot-composer-handoff.md) — session end: `workingdocs` + Dependabot enable; Composer bumps to Laravel **11.57.1**; pushed `525bb25`; **46** fixed / **4** open (L12-only).

## Open TODOs

- Decide Laravel 12 upgrade to clear remaining 4 framework Dependabot alerts (high CRLF email rule, signed URL, debug XSS, task output injection).
