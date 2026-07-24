# Korean patch inventory

Patches are **in-tree** (no quilt series). When merging upstream, re-check these paths first.

Docs / ops SSOT for how to build and ship: [`FORK.md`](../../FORK.md).

## A — Summaries & chrome (high impact)

| Area | Paths |
|------|--------|
| Session title | `crates/codegen/xai-grok-shell/src/session/helpers/session_summary.rs` |
| Idle recap | `.../session_recap.rs` |
| Compact SSOT | `crates/common/xai-grok-compaction/src/code_compaction/{prompt.rs,summary.rs,templates/full_replace_summary_prompt.txt}` |
| Shell compact routes to SSOT | `crates/codegen/xai-grok-shell/src/session/helpers/session_compact.rs` |
| Chat-state preamble | `crates/codegen/xai-chat-state/src/compaction_utils.rs` |
| Binary name | `crates/codegen/xai-grok-pager-bin/Cargo.toml` → `grok-ko` |
| Activity title bar | `crates/codegen/xai-grok-pager/src/notifications/title.rs` |
| Wait labels | `.../acp/tracker.rs`, `.../views/turn_status.rs` |
| Session events | `.../scrollback/blocks/session_event.rs` |
| Notifications | `.../notifications/{config,hooks,mod}.rs` |
| Dashboard peek | `.../views/dashboard/peek.rs` |
| Tool usage labels | `.../tool_usage.rs` |

## B — Slash / settings / resume

| Area | Paths |
|------|--------|
| Slash descriptions | `crates/codegen/xai-grok-pager/src/slash/commands/{compact,resume,rename,new,usage,docs,doctor,announcements,session_info}.rs` |
| New session label | `.../views/dashboard/row.rs` (`NEW_SESSION_LABEL`) |
| Permission mode | `.../settings/defs.rs` |
| Turn complete toast | `.../app/dispatch/prompt.rs` |
| Action palette | `.../actions/defaults.rs` |
| Resume reminders | `crates/codegen/xai-grok-shell/src/session/acp_session_impl/reminders.rs` |
| BG task resume | `crates/codegen/xai-grok-shell/src/terminal/background_task.rs` |
| ACP slash catalog | `crates/codegen/xai-grok-pager/src/acp/mod.rs` |

## Ops / ship (not UI copy)

| Area | Paths / notes |
|------|----------------|
| Makefile ship features | `Makefile` — `CARGO_FEATURES=--no-default-features --features sandbox-enforce`; arm64 jemalloc link workaround |
| Install / smoke / upstream scripts | `scripts/{install-grok-ko,smoke-grok-ko,sync-upstream,check-korean-ssot}.sh` |
| Structural SSOT gate | `scripts/check-korean-ssot.sh` — source needles + release binary Hangul; refuses version hash `0ce7dd5` |
| Smoke hardening | `scripts/smoke-grok-ko.sh` — refuse stale `0ce7dd5`; Hangul reply/title checks |

### SSOT needles (must stay present)

Maintained by `scripts/check-korean-ssot.sh`:

| Location | Needle |
|----------|--------|
| `session_summary.rs` | `새 세션` |
| `session_recap.rs` | `요약 —` |
| compact template | `Write the entire summary body in Korean` |
| slash `compact.rs` | `대화 기록 압축` |
| dashboard `row.rs` | `NEW_SESSION_LABEL: &str = "새 세션"` |
| release binary (if built) | `생각 중` (UTF-8 bytes) |
| `--version` | must **not** be stale hash `0ce7dd5` |

## Intentionally left English

- Tool kinds: Bash / Read / Edit / Search (CLI/API names)
- Slash **command names** (`/compact`, not Hangul)
- Upstream docs under `crates/codegen/xai-grok-pager/docs/user-guide/` (and tutorial)
- Internal telemetry keys / snake_case labels

## Verify after rebuild

```bash
make install
./scripts/check-korean-ssot.sh
make smoke
# dual smoke when shipping a release binary
make smoke

# optional: binary embeds Hangul wait label
python3 -c "from pathlib import Path; b=Path('target/release/grok-ko').read_bytes(); print('생각 중' in b.decode('utf-8','replace'))"
```
