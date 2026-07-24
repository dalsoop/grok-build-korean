# grok-build-korean

한국어 기본으로 다듬은 [xai-org/grok-build](https://github.com/xai-org/grok-build) 공개 포크 (Apache-2.0).

업스트림은 외부 PR을 받지 않음. 이 포크는 공식 `grok` 옆에 **`grok-ko`** 를 사이드바이사이드로 설치함.

| | |
|---|---|
| GitHub | https://github.com/dalsoop/grok-build-korean |
| Default branch | `main` |
| Binary | `grok-ko` (공식 `~/.grok/bin/grok` 을 덮어쓰지 않음) |
| Auth / sessions | 공식과 동일 `~/.grok/` |
| Ship baseline | A·B 한글 번들 + release build/install/smoke + structural SSOT gate |

## Quick start

```bash
# deps (macOS)
make deps
# or: brew install dotslash protobuf

# release build + install
#   ~/.local/bin/grok-ko
#   + /opt/homebrew/bin/grok-ko (writable 일 때)
make install

# structural gate (source + release binary Hangul needles)
./scripts/check-korean-ssot.sh

# headless smoke (Korean reply + title when generated)
make smoke

# use
grok-ko          # this fork
grok             # official (unchanged)
```

```bash
make version     # git HEAD / built artifact / PATH grok-ko / official grok
```

Both share `~/.grok/` (auth, sessions, `config.toml`).

## What is Koreanized

| Bundle | Scope |
|--------|--------|
| **A** | Session titles, idle recap (`요약`), compact summaries, turn/status chrome |
| **B** | Slash descriptions, New session, permission mode, resume reminders, turn toasts |

Full path inventory: [`docs/fork/CHANGES.md`](docs/fork/CHANGES.md)  
Repo layout: [`docs/fork/LAYOUT.md`](docs/fork/LAYOUT.md)

**의도적으로 영어 유지:** slash **command names** (`/compact` 등), tool kinds(Bash/Read/Edit…), 업스트림 `user-guide` 본문, telemetry 키.

## Build notes (macOS arm64)

Ship path은 Makefile 기본값을 따른다.

| Item | Value |
|------|--------|
| Package | `xai-grok-pager-bin` |
| Artifact | `target/release/grok-ko` |
| Features | `--no-default-features --features sandbox-enforce` |
| Why | jemalloc 포함 기본 피처는 큰 release link 시 arm64 `ld: fixup error (kind=arm64_adrp_lo12)` 를 유발할 수 있음 |
| Deployment target | `MACOSX_DEPLOYMENT_TARGET` = host major (예: `26.0`) |

직접 cargo 를 쓸 때도 Makefile 과 같은 feature 세트를 쓰는 것을 권장:

```bash
export MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion | awk -F. '{print $1".0"}')"
cargo build -p xai-grok-pager-bin --release \
  --no-default-features --features sandbox-enforce
# → target/release/grok-ko
```

## Verify / ship gates

| Gate | Command | Expect |
|------|---------|--------|
| Build | `make build` | exit 0, `target/release/grok-ko --version` |
| Install | `make install` | PATH `grok-ko` == artifact; official `grok` path distinct |
| SSOT | `./scripts/check-korean-ssot.sh` | source needles + (artifact 있으면) binary Hangul; **refuse stale hash `0ce7dd5`** |
| Smoke | `make smoke` (권장 2회) | non-empty Hangul reply; title 있으면 Hangul (`title_korean: YES`) |

Smoke는 기존 `~/.grok/` 로그인·네트워크가 필요하다. stale 바이너리(옛 rename 커밋 `0ce7dd5` 등)는 스크립트가 거부한다.

## Layout

```text
Makefile                      deps / build / install / smoke / version / upstream
scripts/install-grok-ko.sh    side-by-side install (no overwrite of grok)
scripts/smoke-grok-ko.sh      headless Korean reply + title
scripts/check-korean-ssot.sh  structural Hangul/SSOT gate
scripts/sync-upstream.sh      fetch upstream (no auto-merge)
docs/fork/LAYOUT.md
docs/fork/CHANGES.md
crates/…                      upstream tree + Korean patches in place
target/release/grok-ko        release artifact (gitignored)
```

## Branches

| Branch | Role |
|--------|------|
| **`main`** | Default ship branch (upstream baseline + Korean patches) |
| `korean-i18n` | Historical; prefer `main` |

## Upstream sync

```bash
make upstream-fetch
# or
./scripts/sync-upstream.sh

# then carefully:
git merge upstream/main
# re-check docs/fork/CHANGES.md paths after conflicts
make install
./scripts/check-korean-ssot.sh
make smoke
```

## Coexistence

| Binary | Path example | Source |
|--------|--------------|--------|
| `grok-ko` | `~/.local/bin/grok-ko`, `/opt/homebrew/bin/grok-ko` | this repo |
| `grok` | `~/.grok/bin/grok` (often via `~/.local/bin/grok` symlink) | official install |

Do **not** replace official `grok` with this fork unless you mean to.

공식 설치 스크립트(`curl … x.ai/cli/install.sh`)는 **`grok`** 를 설치한다. 이 포크 바이너리를 쓰려면 이 레포에서 `make install` 한다.
