# grok-build-korean — Korean fork of Grok Build

Public fork of [xai-org/grok-build](https://github.com/xai-org/grok-build) (Apache-2.0).

Upstream does not accept external contributions. This fork ships a **side-by-side** binary `grok-ko` so the official `grok` install stays untouched.

## What changed (phase 1+2)

| Area | Change |
|------|--------|
| Session title | Korean title prompt; empty fallback `새 세션` |
| Idle `/recap` | Korean one-line recap instruction; UI label `요약` |
| Compaction | Summary body required Korean; carrier preamble Korean; heading `요약:` |
| TUI chrome | Activity titles: `생각 중` / `응답 중` / `압축 중` / wait labels |

Code, paths, CLI flags, and proper nouns stay in original form.

## Build

Requirements: Rust (via `rust-toolchain.toml`), [DotSlash](https://dotslash-cli.com), `protoc`.

```bash
brew install dotslash protobuf   # macOS
cargo build -p xai-grok-pager-bin --release
# artifact:
#   target/release/grok-ko
```

## Install side-by-side

```bash
install -m 755 target/release/grok-ko "$HOME/.local/bin/grok-ko"
# or
install -m 755 target/release/grok-ko /opt/homebrew/bin/grok-ko
```

Official `grok` (~/.grok/bin/grok) is unchanged. Prefer:

```bash
grok-ko   # Korean-tuned fork
grok      # upstream binary
```

Both share `~/.grok/` config, auth, and sessions.

## Branch

- `main` — upstream mirror
- `korean-i18n` — this fork’s Korean patches

## Sync upstream

```bash
git remote add upstream https://github.com/xai-org/grok-build.git  # once
git fetch upstream
git merge upstream/main   # resolve conflicts in prompt/UI strings carefully
```
