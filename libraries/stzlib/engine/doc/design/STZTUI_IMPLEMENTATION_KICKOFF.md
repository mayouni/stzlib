# StzTUI — Implementation Kickoff Prompt

*Paste this into a Claude Desktop session that has filesystem/Claude Code access to
the StzEngine and StzLib repositories. Attach `STZTUI_SPEC_v0_1.md` to the same
session — it is the source of truth for everything below.*

---

## Context — who I am and what we're building

I'm Mansour Ayouni (Softanza Labs). I build a vertically integrated stack: **StzEngine**,
a Zig-backed runtime, exposed to other languages through a C ABI (`libstz` / `libzin`)
under the governing contract **"observe and execute, never author"** — host languages
declare intent and consume results; the engine owns execution. On top of this sit the
Zin language and **StzLib**, my Ring library. The canonical grounding scenario is
regulated enterprise software for BCEAO/WAEMU banking (fr_XOF locale, francophone
West Africa), with Sonibank Niger as pilot. Design philosophy: domain before code,
declarative-first always, West African context as primary expression.

We are adding a new StzEngine subsystem: **StzTUI**, a general-purpose, adaptive,
beautiful terminal-UI engine, written in Zig, drivable from any host language through
the C ABI. Its design is reverse-engineered from 37signals' ONCE console UI
(`basecamp/once`, `internal/ui`) and specified in the attached **`STZTUI_SPEC_v0_1.md`**.
**Read that document fully before doing anything else.** It defines the layered
architecture (L0–L7), the OKLCH palette algorithms, the braille canvas, the
immediate-mode C ABI, the widget catalogue, and the ONCE→StzTUI mapping.

Two deliverables:

1. **Zig side** — the StzTUI module inside StzEngine, exporting the `stz_tui_*` C ABI.
2. **Ring side** — a `stztui` wrapper in StzLib that binds that ABI ergonomically.

## Document conventions (apply to anything you write)

- All specs, notes, and reference docs are **Markdown (`.md`) only** — never Word.
- Never use the word "substrate" anywhere. Use "runtime," "engine," "system,"
  "graph model," or a context-appropriate alternative.
- Maintain a `STZTUI_DECISIONS.md` (a CLAUDE.md-style discipline file) recording
  every locked decision and hard constraint, updated as we go, so it survives across
  sessions.

---

## Locked decisions (do not relitigate without flagging me)

1. **The engine authors every byte.** Hosts never emit escape codes, compute
   coordinates, or pick colors. This is the StzEngine contract; StzTUI obeys it.
2. **StzTUI owns the renderer.** Unlike ONCE (which delegates to Bubble Tea/Lipgloss),
   we implement L3 ourselves: double-buffered cell grid, minimal-diff ANSI flush,
   grapheme + wide-char width handling, alt-screen/raw-mode lifecycle with guaranteed
   restore on panic or error.
3. **Click zones are structural, not marker-injected.** Because we own layout, the
   engine records each interactive widget's rectangle at composite time. No
   marker-and-re-lex dance (the ONCE `mouse/` approach is explicitly *not* ported).
4. **The primary C ABI is immediate-mode** (Dear ImGui-style): host owns the loop,
   pumps events, issues plain builder calls between `begin_frame`/`end_frame`, keyed
   by host-chosen `u32` ids echoed back as `STZ_EV_ZONE`. This is the model that binds
   cleanly from Ring and C without marshalling a tree.
5. **The terminal is the theme.** OSC detection + OKLCH synthesis, ported faithfully
   from the spec §7. Output must look identical to ONCE given the same terminal.
6. **One sub-cell primitive.** Charts, gauges, progress, sparklines, starfield all
   derive from the single braille canvas (spec §8).
7. **Allocator-explicit, GC-free.** Retained state on a passed-in allocator; a frame
   arena reset (retain-capacity) at `end_frame` so steady-state rendering does no
   long-lived allocation.

## Resolve this BEFORE writing module code

The immediate-mode ABI assumes **the host owns the run loop and its model state**.
I need you to confirm this fits the existing FFI surface:

- Inspect how current `libstz` / `libzin` consumers are structured. Does the existing
  ABI already hand the run loop to the host (host calls in repeatedly), or does the
  engine own a loop and call back into host code?
- If host-owns-loop is consistent with the rest of the surface → confirm and proceed
  with spec §5 as written.
- If the engine is expected to own the loop elsewhere → propose how to reconcile
  (e.g. an optional `stz_tui_run(callback)` convenience over the same primitives),
  and record the decision in `STZTUI_DECISIONS.md`. Do not silently pick one.

Surface your finding and recommendation to me before starting Milestone 0.

---

## Repository discovery (do this first, don't assume)

Before coding, map the actual ground truth and report back a short summary:

- StzEngine: Zig version (`build.zig.zon` / toolchain), module layout, where C ABI
  exports live, the existing `stz_*` / `libzin` symbol and naming conventions, error
  and allocator conventions, the test harness, and how headers are generated/shipped.
- StzLib: how existing Ring wrappers call into the C ABI (Ring's FFI mechanism,
  `loadlib`/`callgcc` patterns, marshalling conventions, naming, file layout).
- Confirm where StzTUI source should live in each repo and what the build wiring is.

Ask me only the questions you genuinely cannot answer by reading the repos.

## Engineering standards (Zig)

- Idiomatic modern Zig: tagged unions for events/messages/widget nodes, error unions
  for fallible ops, `defer`/`errdefer` for terminal-state restoration, comptime for
  the braille tables, wcwidth ranges, SGR templates, OKLCH matrices, and widget vtables.
- No hidden I/O: all terminal writes funnel through one buffered writer flushed once
  per frame.
- Every public type/function documented at the level the spec implies.
- The C ABI is a thin, panic-free boundary: no Zig types crossing by value, no
  closures across FFI in v0.1; translate errors to status codes, never let a Zig
  panic escape into the host.

## Validation gates (run before every delivery — non-negotiable)

- `zig fmt` clean.
- `zig build` succeeds.
- `zig build test` green, including:
  - **Golden-buffer tests** — render a frame to a `Buffer`, serialise to a
    text + style-mask snapshot, assert against a checked-in golden (spec §11).
  - **Palette tests** — synthetic `DetectedColors` in, assert synthesised RGB and
    semantic aliases; cover light-background and incomplete-detection paths.
  - **Diff correctness** — render A→B, apply emitted ANSI to a model terminal,
    assert equality with a from-scratch render of B.
  - **Zone resolution** — `resolve(x,y)` returns the right id across layouts/resizes.
- For the Ring binding: a Ring harness that drives the ABI and produces a golden
  buffer **identical** to the equivalent C/Zig harness (ABI parity, spec §11).

Treat a red gate the way I treat `node --check` failures in my prototype work: nothing
ships until it's green.

---

## Milestones (gated; deliver and validate each before moving on)

Follow the spec's roadmap (§13). At each milestone, update `STZTUI_DECISIONS.md` and
give me a short written status + how to run the demo.

- **M0 — Floor.** L0 (raw/alt-screen/input decode/OSC detection with timeout and
  guaranteed restore) + L3 (cell buffer, diff, width handling) + L2 (palette + theme).
  *Demo:* detect colors, paint a harmonised bordered box that survives resize and
  restores the terminal cleanly on exit.
- **M1 — Canvas + viz.** L1 braille canvas; chart, gauge, progress, sparkline,
  starfield, logo. *Demo:* reproduce the ONCE dashboard from sample data.
- **M2 — Interaction.** L4 layout + structural zones + focus ring; menu, form,
  button, text field, checkbox, help bar, size guard. *Demo:* reproduce the ONCE
  install flow.
- **M3 — ABI + Ring.** L7 `libstztui` immediate-mode surface + event pump; the StzLib
  `stztui` Ring wrapper; ABI golden-buffer parity tests. *Demo:* the install flow
  driven entirely from Ring, with zero escape codes / coordinates / color choices in
  the Ring code (target the §5.4 sketch as the acceptance test).
- **M4 — General widgets.** table, tabs, tree, modal, toast, select, scroll viewport,
  log tailer.

Keep the BCEAO/WAEMU back-office use case in mind for M4 widget ergonomics (tables,
status lines, confirm dialogs), and remember locale/RTL/XOF formatting belongs at
L3/L4, not in host strings (spec §12) — but do not implement it until v0.1 is stable.

## Working agreements

- Work in small, reviewable steps. Show me a plan for the current milestone before
  large edits; checkpoint at each validation gate.
- When the spec and the existing repo conventions conflict, the repo's stable ABI
  conventions win for the boundary, the spec wins for behaviour — flag the conflict
  and record the resolution.
- Don't gold-plate. v0.1 scope is M0–M3 for both sides plus M4 widgets; the v0.2
  candidates in the spec (image protocols, retained scene graph, Zui terminal backend)
  are out of scope unless I say otherwise.

## Your first task

1. Read `STZTUI_SPEC_v0_1.md` end to end.
2. Do the repository discovery above for StzEngine and StzLib.
3. Resolve the loop-ownership question and give me your recommendation.
4. Propose the M0 file layout and build wiring for both repos, and create
   `STZTUI_DECISIONS.md` seeded with the locked decisions above.

Then stop and check in with me before writing M0 implementation code.
