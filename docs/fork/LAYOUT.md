# Fork layout

```text
grok-build-korean/
├── README.md                 # upstream README + fork banner / this-fork section
├── FORK.md                   # fork SSOT: what/why/how to build-install-verify
├── Makefile                  # deps / build / install / smoke / version / upstream
├── scripts/
│   ├── install-grok-ko.sh    # install side-by-side binary
│   ├── smoke-grok-ko.sh      # headless Korean smoke (reply + title)
│   ├── check-korean-ssot.sh  # structural Hangul/SSOT needles (+ refuse stale 0ce7dd5)
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
| Docs SSOT | [`FORK.md`](../../FORK.md) |

## Makefile targets

| Target | Action |
|--------|--------|
| `make deps` | brew: `dotslash`, `protobuf` |
| `make build` | release `grok-ko` with ship features (see below) |
| `make install` | build + install to `~/.local/bin` (+ brew bin if writable) |
| `make smoke` | `./scripts/smoke-grok-ko.sh` (requires PATH `grok-ko` + auth) |
| `make version` | git / artifact / PATH `grok-ko` / official `grok` |
| `make upstream-fetch` | add/fetch `upstream` remote |
| `make clean` | `cargo clean` |

Structural gate (not a Makefile target yet):

```bash
./scripts/check-korean-ssot.sh
```

## Ship build features

Default `CARGO_FEATURES` in Makefile:

```text
--no-default-features --features sandbox-enforce
```

- **Why:** jemalloc-enabled default features can fail large arm64 release links (`ld: fixup error (kind=arm64_adrp_lo12)`).
- **Also set:** `MACOSX_DEPLOYMENT_TARGET` to host major (e.g. `26.0`) during build.
- Artifact path: `target/release/grok-ko` (bin name set in `crates/codegen/xai-grok-pager-bin/Cargo.toml`).

## Branch policy

| Branch | Role |
|--------|------|
| `main` | Default. Upstream baseline **plus** Korean patches. Ship from here. |
| `korean-i18n` | Historical feature branch (may lag `main`). Prefer `main`. |

## Runtime coexistence

```text
/opt/homebrew/bin/grok-ko     # this fork (optional copy when brew bin writable)
~/.local/bin/grok-ko          # this fork (make install default)
~/.local/bin/grok → ~/.grok/bin/grok   # official (example)
~/.grok/bin/grok              # official install (untouched)
```

Same sessions directory, same OAuth, same `config.toml`.

## Verify after edit / rebuild

```bash
make install
./scripts/check-korean-ssot.sh
make smoke
make smoke   # dual run when shipping
```

See [`CHANGES.md`](./CHANGES.md) for patch inventory and Hangul needles the SSOT script checks.
