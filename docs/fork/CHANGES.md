# Korean patch inventory

Patches are **in-tree** (no quilt series). When merging upstream, re-check these paths first.

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

## Intentionally left English

- Tool kinds: Bash / Read / Edit / Search (CLI/API names)
- Slash **command names** (`/compact`, not Hangul)
- Upstream docs under `docs/user-guide/`
- Internal telemetry keys / snake_case labels

## Verify after rebuild

```bash
make install
make smoke
# binary should embed Hangul strings:
python3 -c "from pathlib import Path; b=Path('/opt/homebrew/bin/grok-ko').read_bytes(); print('생각 중' in b.decode('utf-8','replace'))"
```
