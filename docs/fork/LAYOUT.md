# Fork layout

```text
grok-build-korean/
├── README.md                 # upstream README + fork banner
├── FORK.md                   # fork SSOT: what/why/how to build-install
├── Makefile                  # deps / build / install / smoke / upstream
├── scripts/
│   ├── install-grok-ko.sh    # install side-by-side binary
│   ├── smoke-grok-ko.sh      # headless Korean smoke
│   └── sync-upstream.sh      # fetch upstream (no auto-merge)
├── docs/fork/
│   ├── LAYOUT.md             # this file
│   └── CHANGES.md            # inventory of Korean patches by area
├── crates/                   # upstream Rust tree (patched in place)
└── target/release/grok-ko    # release artifact (gitignored)
```

## Identity

| Item | Value |
|------|--------|
| GitHub | https://github.com/dalsoop/grok-build-korean |
| Upstream | https://github.com/xai-org/grok-build |
| Binary | `grok-ko` (never overwrites `~/.grok/bin/grok`) |
| Config/auth | Shared `~/.grok/` with official Grok Build |
| Default branch | `main` (Korean patches on top of upstream sync) |

## Branch policy

| Branch | Role |
|--------|------|
| `main` | Default. Upstream baseline **plus** Korean patches. Ship from here. |
| `korean-i18n` | Historical feature branch (may lag `main`). Prefer `main`. |

## Runtime coexistence

```text
/opt/homebrew/bin/grok-ko     # this fork (optional)
~/.local/bin/grok-ko          # this fork (make install default)
~/.grok/bin/grok              # official install (untouched)
```

Same sessions directory, same OAuth, same `config.toml`.
