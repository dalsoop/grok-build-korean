# Repro checklist

## A. Interactive PNG screenshots (best for PR)

See `scripts/take-screenshots.md`. Goal: three PNGs in `evidence/`.

| Shot | Size | Name |
| --- | --- | --- |
| Control | 120×40 | `evidence/wide-120.png` |
| Narrow | 60×40 | `evidence/narrow-60.png` |
| Very narrow | 40×40 | `evidence/narrow-40.png` |

**Must-have on screen for a fair comparison**

- Agent view (not welcome-only), top status row visible
- Left: git branch + cwd path
- Right: at least context bar (`████ 42%` or token counts) and ideally todo badge

Tip: open a real repo with a dirty worktree and a non-empty todo so chips fill.

## B. Automated text capture (tmux)

```bash
./scripts/capture-narrow.sh
```

Writes `evidence/capture-*.txt` with `tmux capture-pane` for several column
widths. Good as secondary evidence when PNG windows are awkward.

## C. Synthetic layout dump (always works)

```bash
python3 scripts/simulate_overflow.py
```

Writes:

- `evidence/sim-wide.txt`
- `evidence/sim-narrow.txt`
- `evidence/sim-summary.md`

This implements the **same math** as `AgentStatusBar::render` today and shows
the overflow past the right edge.

## D. After capture

1. Open PNGs, crop to the **top status row** if the PR body would be huge.
2. Link filenames in `PR_DRAFT.md` table (already listed).
3. Optionally annotate with red box on the clipped right edge.
