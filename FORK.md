# grok-build-korean

한국어 기본으로 다듬은 [xai-org/grok-build](https://github.com/xai-org/grok-build) 공개 포크 (Apache-2.0).

업스트림은 외부 PR을 받지 않음. 이 포크는 공식 `grok` 옆에 **`grok-ko`** 를 사이드바이사이드로 설치함.

## Quick start

```bash
# deps (macOS)
brew install dotslash protobuf

# build + install (~/.local/bin and brew bin if writable)
make install

# smoke (headless Korean title)
make smoke

# use
grok-ko          # this fork
grok             # official (unchanged)
```

Both share `~/.grok/` (auth, sessions, `config.toml`).

## What is Koreanized

| Bundle | Scope |
|--------|--------|
| **A** | Session titles, idle recap (`요약`), compact summaries, turn/status chrome |
| **B** | Slash descriptions, New session, permission mode, resume reminders, turn toasts |

Full path inventory: [`docs/fork/CHANGES.md`](docs/fork/CHANGES.md)  
Repo layout: [`docs/fork/LAYOUT.md`](docs/fork/LAYOUT.md)

## Layout

```text
Makefile                 build / install / smoke / upstream
scripts/install-grok-ko.sh
scripts/smoke-grok-ko.sh
scripts/sync-upstream.sh
docs/fork/LAYOUT.md
docs/fork/CHANGES.md
crates/…                 patched upstream sources
```

## Branches

| Branch | Role |
|--------|------|
| **`main`** | Default ship branch (upstream + Korean patches) |
| `korean-i18n` | Historical; prefer `main` |

## Upstream sync

```bash
make upstream-fetch
# or
./scripts/sync-upstream.sh

# then carefully:
git merge upstream/main
# re-check docs/fork/CHANGES.md paths after conflicts
make install && make smoke
```

## Coexistence

| Binary | Path example | Source |
|--------|--------------|--------|
| `grok-ko` | `~/.local/bin/grok-ko`, `/opt/homebrew/bin/grok-ko` | this repo |
| `grok` | `~/.grok/bin/grok` | official install script |

Do **not** replace official `grok` with this fork unless you mean to.

## Status check

```bash
make version
```
