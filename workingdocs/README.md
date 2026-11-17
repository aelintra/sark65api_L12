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
| **API lab install** | `192.168.1.135` (`ubu2204arm`) | SSH `tech@192.168.1.135` (Mac `id_rsa`). Ubuntu **24.04**, PHP **8.3.6**, SARK V65. Passwordless sudo for `tech`. App at `/opt/sark65api_L12`, HTTPS **:44300**. |
| **Deb builder** | `192.168.1.78` (`deb11-1`) | SSH `tech@192.168.1.78`. Repos under `~/Git/`. Mac has no `rsync` — sync with `tar`/`scp`. Cannot push to GitHub over HTTPS; push from Mac. |
| Lab / customer rebuild | `192.168.1.130` (`adler`) | SSH `tech@192.168.1.130`. **Passwordless sudo** (`sudo -n`). SARK V65 + API target. |
| Customer test VM | `192.168.9.4` (`adler-pbx-02`) | SSH `pbxadmin@192.168.9.4` (key). Sudo **requires password**. |
| Other test | `192.168.1.12` (`iitac2404`) | SSH `tech@192.168.1.12`. |

## Repo context

| Item | Notes |
|------|--------|
| Mac path | `/Users/jeffstokoe/GiT/sark65api_L12` |
| Remote | `https://github.com/aelintra/sark65api_L12.git` |
| Stack | Laravel **12.72**, PHP platform pin **8.3.6**, Sanctum; runs on SARK V65 |
| Public docs | https://aelintra.github.io/sark65api_L12/ (`docs/` + `mkdocs.yml` → `gh-pages`) |
| Install guide | `docs/installation.md` |

## Latest handoff

- [2026-11-16-installer-401-vxt-handoff.md](./2026-11-16-installer-401-vxt-handoff.md) — `sarkapi_installer.sh`; guest JSON 401; drop `extensions/vxt`; stay on lab **.135**.
- [2026-11-16-docs-install-lab135-handoff.md](./2026-11-16-docs-install-lab135-handoff.md) — Pages published; docs↔routes sync; install guide; lab install on **192.168.1.135**; API admin + endpoint smoke; tip `5f567e1`.
- [2026-11-15-laravel12-upgrade-handoff.md](./2026-11-15-laravel12-upgrade-handoff.md) — Laravel **11.57.1 → 12.72.0**; Sanctum **4.4.0**; `composer audit` clean.
- [2026-11-15-dependabot-composer-handoff.md](./2026-11-15-dependabot-composer-handoff.md) — prior L11 Dependabot/Composer close-out (superseded by L12).

## Open TODOs

- Confirm Dependabot UI clean for `sark65api_L12`.
- Later: deploy to Adler `192.168.1.130` via installer (deferred; staying on `.135`).
