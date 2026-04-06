# Roadmap Overview

## Target

- Neovim **0.12.1+** only (no backwards compatibility with older versions)
- Bash 4.0+, tmux (any recent version), git

## Phases

| Phase | Name | Description |
|-------|------|-------------|
| 1 | [Core Infrastructure](./01-core-infrastructure.md) | Entry point, library scaffolding, sandbox, UI primitives |
| 2 | [Lesson Engine](./02-lesson-engine.md) | Engine state machine, progress tracking, verification framework |
| 3 | [Sandbox Config & Companion Plugin](./03-sandbox-config.md) | LazyVim sandbox config, companion plugin, first-run bootstrap |
| 4 | [Module 1 — Neovim Essentials](./04-module-1-neovim-essentials.md) | 5 lessons: modal editing, motions, text objects, buffers/windows, registers |
| 5 | [Module 2 — LazyVim Navigation](./05-module-2-lazyvim-navigation.md) | 5 lessons: overview, Neo-tree, Telescope, Flash.nvim, Which-Key |
| 6 | [Modules 3–5 & Polish](./06-modules-3-5-and-polish.md) | Editing power, customization, workflows, end-to-end testing, release |

```mermaid
gantt
    title lazynvim-learn Development Phases
    dateFormat YYYY-MM-DD
    axisFormat %b

    section Foundation
    Phase 1 – Core Infrastructure       :p1, 2026-04-07, 14d
    Phase 2 – Lesson Engine              :p2, after p1, 14d
    Phase 3 – Sandbox Config & Plugin    :p3, after p2, 10d

    section Content
    Phase 4 – Module 1 Neovim Essentials :p4, after p3, 14d
    Phase 5 – Module 2 LazyVim Nav       :p5, after p4, 14d
    Phase 6 – Modules 3-5 & Polish       :p6, after p5, 21d
```

## Dependency Graph

```mermaid
graph LR
    P1[Phase 1<br>Core Infra] --> P2[Phase 2<br>Lesson Engine]
    P2 --> P3[Phase 3<br>Sandbox Config]
    P3 --> P4[Phase 4<br>Module 1]
    P3 --> P5[Phase 5<br>Module 2]
    P4 --> P5
    P5 --> P6[Phase 6<br>Modules 3-5 & Polish]

    style P1 fill:#4a9eff,color:#fff
    style P2 fill:#4a9eff,color:#fff
    style P3 fill:#4a9eff,color:#fff
    style P4 fill:#f5a623,color:#fff
    style P5 fill:#f5a623,color:#fff
    style P6 fill:#7ed321,color:#fff
```
