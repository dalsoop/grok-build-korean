# Simulation summary

Assumes default `outer_hpad_left/right = 2`.

| term_width | area | cluster | start_x | cwd_budget | overflows | overflow_cols |
| --- | --- | --- | --- | --- | --- | --- |
| 120 | 116 | 71 | 47 | 44 | False | 0 |
| 70 | 66 | 71 | 2 | 0 | True | 5 |
| 50 | 46 | 71 | 2 | 0 | True | 25 |

- **overflows=true** → right chips paint past the terminal edge (cut off).
- **cwd_budget→0** → left path disappears even if chips technically fit.
