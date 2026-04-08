# Drills Feature Plan

## Overview

A new **Drills** section replacing the "Quick Refresher" main menu entry. Drills are focused, repeatable practice sessions on specific skill areas with progressive difficulty, multi-step exercises, and detailed performance tracking. Unlike lessons (which teach concepts), drills build muscle memory through real-world-style scenarios.

All drills assume the user has completed relevant lessons. Each drill includes a reference cheat sheet (in Normal mode) or runs without one (Hard mode).

---

## Menu Structure

The main menu's "Quick Refresher" entry becomes **"Drills"**, opening a submenu:

```
┌─────────────────────────────────────────┐
│          ★ Skill Drills ★               │
│                                         │
│  Mode: Normal  (toggle: m)              │
│                                         │
│   1. Quick Refresher     Best: 4m 12s   │
│   2. Navigation          Best: --:--    │
│   3. Visual Mode         Best: 3m 58s ★ │
│   4. Copy-Paste          Best: --:--    │
│   5. Operators           Best: 5m 01s   │
│   6. Search & Replace    Best: --:--    │
│   7. Multi-file          Best: --:--    │
│   8. LSP & Refactoring   Best: --:--    │
│   9. Marks & Jumps       Best: --:--    │
│  10. Macros              Best: --:--    │
│                                         │
│   b. Back                               │
└─────────────────────────────────────────┘
```

- `★` = clean run achieved (no hints, no skips, all first-try passes)
- `m` toggles Normal/Hard mode (persisted in settings)
- Best time only shown after first completion
- No unlock gating — all drills always available

### Mode Behavior

- **Normal mode:** Opens a floating/split reference window in the sandbox Neovim with relevant keybindings for that drill. User can close it when ready.
- **Hard mode:** No reference window. The user relies entirely on memory.

---

## Drill Structure

Each drill file follows this flow:

1. **Brief intro** (2-3 lines — what this drill covers)
2. **Cheat sheet** (Normal mode: opens reference split in Neovim; Hard mode: skipped)
3. **8-10 exercises**, progressive difficulty:
   - **Early:** Single-action ("delete this word")
   - **Middle:** Multi-step ("select the function body, yank it, paste it below the class")
   - **Late:** Real-world scenarios ("refactor this: rename the variable, fix the resulting diagnostic, format the file")
4. **Scorecard display**

---

## Scorecard & Performance Tracking

### End-of-Drill Display

```
┌─────────────────────────────────────────┐
│  Navigation Drill — Complete!           │
│                                         │
│  Mode:       Hard                       │
│  Time:       3m 42s                     │
│  Best time:  2m 58s (Normal)            │
│  Exercises:  8/8 passed                 │
│  First-try:  6/8                        │
│  Hints used: 1                          │
│  Skips:      0                          │
│  ★ Clean run: No                        │
│                                         │
│  Splits:                                │
│  1: 0:18  2: 0:24  3: 0:31  4: 0:28    │
│  5: 0:35  6: 0:22  7: 0:41  8: 0:23    │
└─────────────────────────────────────────┘
```

### Metrics Tracked

| Metric | Purpose |
|--------|---------|
| Total time | Raw speed |
| Best time | Track improvement over time |
| Attempts per exercise | Fewer retries = cleaner execution |
| Hints used | Independence measure |
| Skips used | Completion measure |
| Clean run flag | No hints, no skips, all first-try passes |
| Per-exercise splits | Identify weak spots |

### Storage

New file `~/.lazynvim-learn/drill-scores` with format:

```
drill:mode:timestamp:total_secs:first_try_count:hints:skips:clean:splits
```

One line per completed run. Best times derived by querying this file. Full history retained for potential future trend analysis.

---

## Drill Inventory

| # | Drill | Exercises | Key Skills |
|---|-------|-----------|------------|
| 1 | Quick Refresher | 8 (existing) | Sampler across all areas |
| 2 | Navigation | 10 | `hjkl`, `w/b/e`, `f/t/;`, `gg/G`, `:line`, `%`, `H/M/L` |
| 3 | Visual Mode | 8 | `v`, `V`, `Ctrl-v`, select+delete, select+yank, block insert, reselect `gv` |
| 4 | Copy-Paste & Registers | 8 | `y/p/P`, `"ay`, `"ap`, `"+y`, visual yank, yank text objects, paste from multiple registers |
| 5 | Operators & Text Objects | 10 | `d/c/>/< + motion`, `ci"`, `da(`, `gsa/gsd/gsr` (surround), `.` repeat, compound edits |
| 6 | Search & Replace | 8 | `/pattern`, `?`, `n/N`, `*/#`, `:s///`, `:%s///g`, `:s///gc`, regex patterns |
| 7 | Multi-file Workflow | 8 | Buffer switch, splits, `<leader>ff`, `<leader>fb`, tabs, window resize, close splits, `:wall` |
| 8 | LSP & Refactoring | 8 | `<leader>cr` rename, `gd`, `gr`, `]d/[d`, `<leader>ca`, format, organize imports, hover |
| 9 | Marks & Jumps | 8 | `ma`/`'a`, global marks, `Ctrl-o`/`Ctrl-i`, `g;`/`g,` changelist, `:marks`, jump between files |
| 10 | Macros | 8 | `qq`/`q`, `@q`, `@@`, `5@q`, recursive macros, visual macro apply, practical batch edits |

---

## Implementation Components

| Component | What Changes |
|-----------|-------------|
| `lessons/07-drills/*.sh` | 10 drill files |
| `lib/drill.sh` (new) | Timer, scorecard, score storage, hard mode toggle, reference pane management |
| `lib/engine.sh` | Minor additions: hooks for drill timer start/stop per exercise, expose attempt/hint counters |
| `configs/exercise-files/` | New practice files tailored to each drill |
| `configs/base/lua/lazynvim-learn/` | `reference.lua` — floating/split reference window management |
| `lazynvim-learn` (main) | Replace "Quick Refresher" menu entry with "Drills" submenu |
| `lib/progress.sh` or new `lib/scores.sh` | Drill score read/write/best-time functions |

---

## Build Order

1. **Scoring infrastructure** — `lib/drill.sh`, score storage, scorecard display
2. **Reference pane system** — companion plugin `reference.lua` + hard mode toggle
3. **Menu integration** — drills submenu in main script, mode toggle persistence
4. **Move Quick Refresher** — relocate to `07-drills/01-quick-refresher.sh`
5. **Drill files** — one at a time, starting with Navigation (most foundational), then in order through Macros

---

## Design Decisions

- **No unlock gating:** Drills are a practice tool, not part of the learning progression. Always accessible.
- **Progress clears on re-entry:** Each drill run is a fresh attempt, like the existing refresher.
- **No par times:** Insufficient user base for meaningful target times. Personal bests serve this purpose.
- **Multi-step exercises:** Drills emphasize compound actions and real-world scenarios, not single-key exercises.
- **Surround merged into Operators:** `gsa/gsd/gsr` are operator patterns and fit naturally there.
- **Dot repeat woven into Operators:** `.` is essential to efficient operator usage.
- **LSP uses Python/pyright:** Worth the startup cost — code editing is a primary Neovim skill.
