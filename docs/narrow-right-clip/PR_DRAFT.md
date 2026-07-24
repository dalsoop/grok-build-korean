# fix(pager): clip AgentStatusBar to area width on narrow terminals

## Summary

On **narrow terminal widths**, the top agent status row paints its right-aligned
chip cluster starting at the left of the status area and walks past the right
edge. The right-hand chips (context %, todo badge, queue, goal, …) appear
**cut off**, and the left cwd path is also starved because its budget is derived
from the leftmost chip x-position.

This is a **layout clamp bug**, not a missing compact-mode feature. Height-based
auto-compact (`AUTO_COMPACT_MAX_ROWS = 20`) does not address horizontal overflow.

## Environment

- Grok Build: `0.2.111 (94172f2aa4e5) [stable]`
- OS: macOS
- Terminal: (fill: iTerm2 / Terminal.app / Warp / Ghostty / …)
- Multiplexer: (fill: none / tmux / zellij)
- Columns where it reproduces: **≤ ~80** (worse ≤ 60); see evidence

## Screenshots / evidence

Attach from `evidence/`:

| File | What it shows |
| --- | --- |
| `evidence/wide-120.png` | Control: full status row visible |
| `evidence/narrow-60.png` | Right chips / path clipped |
| `evidence/narrow-40.png` | Severe clip (dashboard threshold territory) |
| `evidence/sim-wide.txt` | Synthetic layout dump (wide) |
| `evidence/sim-narrow.txt` | Synthetic layout dump (overflow) |

Generated text dumps (no TUI required):

```bash
python3 scripts/simulate_overflow.py
```

## Repro steps

1. Open a terminal at **120×40** → `grok` → agent view with some status chips
   (cwd + branch + context bar + todo badge is enough).
2. Resize to **60×40** (width only).
3. Observe the top status row: right-side chips truncated or missing; cwd may
   collapse to almost nothing.
4. Optional: also try **40×40** (dashboard `MIN_DASHBOARD_WIDTH`).

Detailed checklist: `REPRO.md`.

## Root cause

`AgentStatusBar::render` in
`crates/codegen/xai-grok-pager/src/views/agent_status.rs`:

```rust
let start_x = area
    .x
    .saturating_add(area.width.saturating_sub(self.right_pad + total_width));
// when total_width > area.width → start_x == area.x
// then paints every item without clamping to area.right()
```

Call site pushes many chips before render
(`app/agent_view/render.rs`): link, bg_tasks, plan, goal, mcp, context, queue,
badge — easy to exceed a 50–70 column status area after outer horizontal padding.

Related: left cwd uses

```rust
let max_cwd_width = areas.values().map(|r| r.x).min()...
```

so when the right cluster starts at `area.x` (overflow case), cwd budget → 0.

## Proposed fix

Minimal defensive change in `AgentStatusBar::render`:

1. Compute available = `area.width - right_pad`.
2. While the visible slice’s total width > available **and** more than one item
   remains, **drop leading items** (left of the right-aligned cluster). Keeps
   the trailing chips (usually context / queue / badge) on-screen.
3. When painting, never write past `area.x + available` (clamp span width).

Patch file in this kit: `patch/0001-agent-status-bar-clip-to-area.patch`.

Optional follow-ups (not in the minimal patch):

- Priority-based drop instead of left-first
- `+N` overflow chip when items were dropped
- Fix legacy `views/status_bar.rs` which still uses byte `.len()` for widths

## Test plan

- [ ] Unit: `status_bar_drops_leading_items_when_narrow` (cluster wider than area
      → only trailing items visible, no paint past `area.right()`)
- [ ] Unit: existing separator tests still pass at width 40
- [ ] Manual: 120 → 60 → 40 resize of live agent view; right chips stay inside
      the frame; cwd retains some path prefix when chips are fewer
- [ ] Manual: `/compact-mode` on/off does not reintroduce overflow

## Notes for maintainers

- Upstream CONTRIBUTING currently rejects external PRs. This report is filed
  for transparency / internal triage. Happy to close if you already track this
  under an internal ID — please leave a pointer if public.

## Checklist

- [x] Repro steps
- [x] Screenshots / text evidence
- [x] File:line root cause
- [x] Minimal patch sketch
- [ ] Confirmed on latest nightly / `grok update` tip (fill after retest)
