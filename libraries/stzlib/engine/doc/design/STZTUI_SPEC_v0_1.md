# StzTUI — A General-Purpose Console UI System for StzEngine

**Specification v0.1**
**Status:** Draft for review · **Owner:** Softanza Labs · **Target runtime:** StzEngine (Zig)

---

## 0. Purpose

StzTUI is a native Zig terminal-UI system, implemented inside StzEngine, that any
language built on top of StzEngine (Zin, Ring, and others reachable through the
`libstz` C ABI) can drive to produce a beautiful, ergonomic, adaptive console
interface — without writing a single escape byte itself.

It follows the StzEngine contract: **the host observes and executes; the engine
authors.** The host language describes *what* the interface contains and reacts to
events; StzTUI owns every byte that touches the terminal — palette detection,
layout, the cell buffer, the diff, input decoding, the render loop.

This document first analyses how 37signals built the ONCE console UI
(`basecamp/once`, `internal/ui`, Go + the Charm stack), distils the principles
worth keeping, then specifies a Zig system that earns the same result while fixing
the parts that only existed because ONCE delegated rendering to an external library.

---

## 1. What ONCE got right (analysis)

The ONCE `internal/ui` package is a single-binary, single-screen-at-a-time TUI
written in Go against Bubble Tea (event loop), Lipgloss (styling/layout), and
`go-colorful` (color math). The screens shown to the operator — the starfield
install flow, the hostname form, the app picker, the live resource dashboard with
braille sparklines — are all built from a small set of reusable components. The
lessons below are what StzTUI inherits.

### 1.1 The Elm Architecture, narrowed

Every component implements a deliberately narrow interface:

```go
type Component interface {
    Init() tea.Cmd
    Update(tea.Msg) (Component, tea.Cmd)
    View() string
}
```

Only the root `App` satisfies the full framework model; every sub-component returns
a plain string from `View()` and a *new copy of itself* from `Update`. Three
properties fall out of this and all three are worth preserving:

1. **Views are pure string functions of state.** No component mutates the screen;
   it returns text. This is what makes the whole package testable with plain string
   assertions (every file has a `_test.go`).
2. **State transitions are values, not mutations.** `Update` returns a new
   component plus a *command* — a description of a side effect to run later. Side
   effects (scraping Docker, ticking a clock, downloading an image) never happen
   inside `Update`; they are returned as `tea.Cmd` thunks the runtime executes.
3. **Navigation is a message.** The root holds one `currentScreen Component` and
   swaps it when it receives a typed `NavigateToDashboardMsg`, `NavigateToInstallMsg`,
   etc. Screens never reach into each other.

### 1.2 An adaptive palette synthesised from the real terminal

This is the single most impressive piece of the codebase and the one most worth
porting faithfully.

- On startup ONCE queries the *actual* terminal for its foreground, background,
  and all sixteen ANSI colors using OSC escape sequences
  (`ESC]10;?`, `ESC]11;?`, `ESC]4;N;?`), appends a DA1 request as a sentinel,
  reads `/dev/tty` in raw mode, and parses the `rgb:RRRR/GGGG/BBBB` replies — with a
  timeout so it degrades gracefully on terminals that don't answer
  (`palette_detect.go`).
- The 16 ANSI slots are kept as *basic* color indices when rendering, so the user's
  own terminal theme is honoured. Only a handful of colors are synthesised as true
  RGB, and they are derived from the detected ones using **OKLCH** color math
  (`palette.go`):
  - **Focus orange** = the OKLCH complement of the terminal's blue (hue rotated
    180°, clamped to a 35°–75° warm band, chroma and lightness floored). It always
    looks "right" against whatever blue the user has.
  - **Background tint** = background nudged ~0.015 darker in OKLCH lightness, for
    panel fills.
  - **Light text** = background blended 35% toward foreground in lightness with a
    whisper of blue chroma — a subdued secondary-text/border color.
  - **Gradient(t)** = green→orange interpolation in OKLCH, used to color charts
    vertically.
  - **pickPrimary** chooses Blue vs BrightBlue by whichever has more lightness
    contrast against the detected background.
- Semantic aliases (`Border`, `Muted`, `Focused`, `Primary`, `Error`, `Success`,
  `Warning`) sit on top, so components never name a raw color.

The payoff: ONCE looks coherent and "designed" on a Solarized terminal, a Tokyo
Night terminal, a stock xterm, and a light-background terminal — with no theme
files, because the theme *is* the user's terminal, harmonised.

### 1.3 Braille as a sub-pixel canvas

ONCE treats the Unicode braille block (U+2800–U+28FF) as a 2×4 sub-pixel grid per
character cell and reuses that single idea four times:

- **Charts** (`chart.go`): two data points per character column, four vertical dots
  per row, with the green→orange OKLCH gradient applied per row.
- **Gauges** (`renderBar` in `dashboard_panel.go`): a filled bar with *rounded
  braille end-caps* (`⢾ … ⡷`) and a distinct peak marker.
- **Starfield** (`starfield.go`): a 3D perspective projection of 100 stars into a
  braille sub-pixel field, advanced on a 33 ms tick, rendered per-row so content can
  be composited on top.
- **Progress** (`progress.go`): a determinate braille bar plus an indeterminate
  "shimmer" of random braille runes while work is unknown.

One primitive, four widgets. StzTUI formalises this as a reusable sub-cell canvas.

### 1.4 Declarative click zones via marker injection

ONCE never computes click coordinates by hand. Components wrap interactive text with
`mouse.Mark(name, content)`, which injects a pair of zero-width private CSI markers
(`ESC[<id>z`) around the content. After the full frame is rendered, `mouse.Sweep`
runs an ANSI-aware lexer over the output, strips the markers, and records the screen
rectangle each `name` ended up occupying (accounting for rune widths and newlines).
`mouse.Resolve(x, y)` then maps a physical click to the innermost named zone, and the
root dispatches a `MouseEvent{Target: name}` to the focused screen.

The ergonomic win is that *interactivity is declared inline where the content is
produced*, and resolved after layout — the component author never touches geometry.

### 1.5 Composition by row-splicing and overlay

Screens are assembled by joining strings vertically/horizontally
(`lipgloss.JoinVertical`/`JoinHorizontal`) and by two bespoke helpers in
`styles.go`: `OverlayCenter` (composite a foreground block centered over a
background, used for popups) and `WithBackground` (re-assert a background color
after every SGR reset so inner styles don't punch holes in a panel). The starfield
is layered by rendering the field row-by-row and splicing content into the middle
columns.

### 1.6 Operational hygiene

- **Terminal size guard** — below 80×24 the whole UI is replaced by a centered
  "terminal too small" message rather than rendering garbage.
- **Tick-driven refresh** — metrics scrape every 2 s, user stats every 30 s, all via
  `tea.Every`; data buffers are fixed-size sliding windows.
- **True-color gate** — RGB output is only enabled when detection or `COLORTERM`
  proves the terminal supports it; otherwise synthesised colors fall back.
- **Style rebuild on palette change** — a single `rebuildStyles()` re-derives every
  package-level style after the palette is applied.

### 1.7 The one thing ONCE *doesn't* own (and StzTUI must)

ONCE delegates the cell buffer, the screen diff, rune-width handling, the alt-screen,
and the actual byte output to Bubble Tea + Lipgloss. Its `View()` returns a *string
of styled text*; the framework decides what changed and what to send. That is why the
mouse system has to re-lex the rendered string to find coordinates — the layout is
opaque to the component that produced it.

StzTUI has no such framework underneath it. It **must implement the renderer**:
a double-buffered cell grid, minimal-diff ANSI emission, grapheme/east-asian width
handling, alt-screen and raw-mode lifecycle. The upside is large: because StzTUI owns
the buffer, **click zones are recorded structurally during compositing** (as bounding
boxes), so the marker-injection-then-re-lex dance disappears. This is the principal
architectural difference between the two systems.

---

## 2. Goals and non-goals

### 2.1 Goals

- A native Zig TUI engine that is a first-class StzEngine subsystem.
- A flat, stable **C ABI (`libstztui`)** so Ring, Zin, and any FFI-capable host drive
  it without authoring escape sequences.
- Adaptive theming that harmonises with the user's terminal (ONCE's palette model,
  reimplemented in Zig).
- A sub-cell (braille) canvas powering charts, gauges, progress, sparklines, and
  decorative effects.
- Declarative, geometry-free interactivity (focus, keyboard, mouse zones).
- Allocator-explicit, GC-free, with a per-frame arena for transient work.
- A widget catalogue covering the ONCE surface (forms, menus, panels, metric cards,
  logo, starfield, help bar, size guard) plus the general primitives any business
  app needs (tables, lists, tabs, modals, toasts, text viewers).

### 2.2 Non-goals (v0.1)

- Image protocols (Sixel/Kitty/iTerm). Reserved for v0.2.
- A retained scene graph as the *primary* host model — v0.1 ships an immediate-mode
  builder, which marshals across the ABI far more cleanly. A retained tree may follow.
- Windowing / multiple OS windows. StzTUI is one terminal viewport.
- A DSL. StzTUI is the rendering and input engine; any DSL (e.g. a Zui terminal
  target) compiles *to* these calls.

---

## 3. Design principles

1. **The engine authors; the host observes and executes.** Hosts never emit bytes.
   They describe widgets and consume events. Mirrors `libstz`'s existing contract.
2. **Declarative-first.** A frame is a description, not a sequence of draw commands.
   The host says "a panel titled X containing a chart of these numbers"; the engine
   decides every cell.
3. **The terminal is the theme.** No theme files by default. Detect, harmonise,
   degrade gracefully. Explicit palette override is allowed but not required.
4. **One sub-cell primitive.** Charts, gauges, progress, and effects all derive from
   the same braille canvas, so they share a visual language and a code path.
5. **Pure views, explicit effects.** Internally StzTUI uses a model/update/view core
   (TEA, in Zig). Side effects are values (`Command`s) the engine runs, never done
   mid-update. This keeps it deterministic and testable.
6. **Geometry is the engine's job.** Interactivity is declared by id at build time
   and resolved against the layout the engine computed. Hosts never see coordinates
   unless they ask for raw mouse mode.
7. **Allocator honesty.** Every allocation is accounted for. Transient render data
   lives in a frame arena that is reset, not freed piecemeal.

---

## 4. Architecture

StzTUI is layered. Each layer depends only on those below it. The C ABI sits at the
top and is the *only* surface most hosts touch.

```
┌──────────────────────────────────────────────────────────────────┐
│  L7  C ABI  (libstztui)        immediate-mode builder + event pump │
├──────────────────────────────────────────────────────────────────┤
│  L6  Native Zig API            App, Component, Command, Widget       │
├──────────────────────────────────────────────────────────────────┤
│  L5  Widgets                   Form, Menu, Panel, Chart, Gauge, …    │
├──────────────────────────────────────────────────────────────────┤
│  L4  Layout + Zones            flex/stack/grid, focus ring, hit map  │
├──────────────────────────────────────────────────────────────────┤
│  L3  Cell buffer + Renderer    double buffer, diff, width, overlay   │
├──────────────────────────────────────────────────────────────────┤
│  L2  Theme                     Palette, OKLCH synthesis, styles      │
├──────────────────────────────────────────────────────────────────┤
│  L1  Sub-cell canvas           braille 2×4 grid, bars, gradients     │
├──────────────────────────────────────────────────────────────────┤
│  L0  Terminal I/O              raw mode, alt screen, OSC detect, in  │
└──────────────────────────────────────────────────────────────────┘
```

### 4.1 L0 — Terminal I/O

Owns the terminal lifecycle and is the only code that reads or writes the tty.

- **Lifecycle:** enter raw mode, switch to alternate screen, hide cursor, enable
  mouse reporting (SGR 1006 + any-motion), bracketed paste; reverse on teardown.
  All wrapped so a panic or `error` always restores the terminal (Zig `defer` +
  a signal-safe restore handler).
- **Input decoder:** a state machine that turns the raw byte stream into typed
  `InputEvent`s: `key` (with modifiers and a UTF-8 text field), `paste`,
  `mouse` (press/release/motion/wheel with SGR coordinates), `resize` (SIGWINCH),
  `focus_in`/`focus_out`. No allocation on the hot path; events are POD.
- **Capability + color detection:** the OSC query/timeout protocol from ONCE,
  ported. Query fg/bg/16 ANSI, append DA1 sentinel, read with a deadline
  (default 100 ms), parse `rgb:` triplets at 1–4 hex digits per channel. Result is
  a `DetectedColors{ colors: [18]Rgb, present: [18]bool }`. `supportsTrueColor()` =
  `COLORTERM ∈ {truecolor,24bit}` OR any OSC reply arrived.

```zig
pub const InputEvent = union(enum) {
    key: Key,                 // .code, .text (utf8), .mods
    paste: []const u8,        // borrowed from the decode arena
    mouse: Mouse,             // .x, .y, .button, .action, .mods
    resize: struct { cols: u16, rows: u16 },
    focus: bool,
    tick,                     // synthesized by the loop's timer
};
```

### 4.2 L1 — Sub-cell canvas

The braille primitive, generalised. A `SubCanvas` maps a region of `cols × rows`
cells onto a `(2·cols) × (4·rows)` dot grid and exposes:

- `set(dotX, dotY)` / `clear(dotX, dotY)` — plot a single sub-pixel.
- `line`, `column(height)` — vertical fills (charts/gauges).
- `flush() -> []const Cell` — collapse the dot grid into braille runes
  (`0x2800 + bits`), one rune per cell.

Comptime tables hold the four left-column and four right-column dot bits
(`{0x40,0x04,0x02,0x01}` / `{0x80,0x20,0x10,0x08}`), identical to ONCE. Helpers
`bar(filled, width, rounded)` (the `⢾…⡷` end-cap style) and
`shimmer(width, rng)` (indeterminate progress) live here.

### 4.3 L2 — Theme

A direct, faithful Zig port of ONCE's palette, plus the style table.

- **`Rgb` / `Oklch`** with conversions through linear-sRGB and Oklab. `blendOklch`,
  `complement`, `clampGamut`.
- **`Palette`** holds the 16 ANSI slots (kept as *indexed* colors for output),
  the synthesised RGB colors, and the semantic aliases. Construction:
  - `Palette.default()` — fallback samples (xterm-like dark), used pre-detection.
  - `Palette.fromDetected(DetectedColors)` — replaces samples with detected values,
    recomputes `isDark` from background OKLCH lightness, runs synthesis.
  - Synthesis functions ported verbatim in behaviour:
    `synthOrange(blue)`, `synthTint(bg)`, `synthLightText(bg,fg,blue)`,
    `gradient(t)`, `pickPrimary()`, `healthColor(state)`.
- **`Style`** is a value type (fg, bg, attrs bitset: bold/dim/italic/underline/
  reverse). `Theme` holds the named styles (`title`, `label`, `input`,
  `button`, `button_primary`, `border`, …) rebuilt from the palette via
  `Theme.rebuild(palette)` — the analogue of ONCE's `rebuildStyles()`.

Output policy: ANSI-slot colors are emitted as SGR 30–37/90–97 so the user's theme
applies; synthesised colors are emitted as truecolor only when `supportsTrueColor()`,
else snapped to the nearest ANSI slot.

### 4.4 L3 — Cell buffer + renderer (the part ONCE delegated)

- **`Cell`** = `{ grapheme: [N]u8, width: u2, style: Style }` where width ∈ {0,1,2}
  for combining marks, normal, and wide (CJK/emoji) cells.
- **`Buffer`** = `cols × rows` cells. Two are kept: `front` (on screen) and `back`
  (next frame). The host's frame fills `back`.
- **Compositing** writes styled spans into `back` with clipping to the current
  layout rect. `overlayCenter`, `withBackground`, bordered-box drawing (`boxTop`
  with embedded title, `boxBottom`, `boxSide`) are buffer operations here, not
  string operations — they place cells directly.
- **Diff + flush:** compare `back` to `front` row by row, emit the minimal cursor
  moves + SGR + text runs, coalescing adjacent same-style cells, then swap buffers.
  Target: a steady-state dashboard tick rewrites only the cells that changed
  (typically the sparkline columns and a few numbers), not the screen.
- **Width handling:** grapheme segmentation + `wcwidth`-equivalent table (comptime
  generated) so wide glyphs occupy two cells and zero-width marks attach to the
  preceding cell.

### 4.5 L4 — Layout + zones

- **Layout** is a constraint-light flex/stack/grid solver. Containers are `row`,
  `col`, `grid(n)`, `center`, `fixed(w,h)`, `flex(weight)`, `pad`, `border`.
  `distributeWidths(total, n)` (even split with remainder to the first items, as in
  ONCE) is the leaf allocator.
- **Hit map:** because the engine owns layout, every interactive widget's final rect
  is known at composite time. The engine records `Zone{ id, rect, focusable }`
  directly — **no marker injection, no re-lexing.** `resolve(x,y)` returns the
  innermost zone id; `focusRing()` orders focusable zones for Tab/Shift-Tab.
- **Focus** is engine-managed: a focused id, advanced by Tab/arrows, skipping
  non-focusable widgets (ONCE's `focusToNextFocusable` logic, generalised).

### 4.6 L5 — Widgets

Each widget is a value with a `measure(constraints) -> Size` and a
`paint(buffer, rect, ctx)` method (plus, for interactive ones, an `update(InputEvent,
ctx) -> ?Command`). See §6 for the catalogue. Widgets are pure with respect to the
host's model: they read state passed in, paint cells, and emit `Command`s describing
intent (`Submit`, `Select(id)`, `Navigate(target)`).

### 4.7 L6 — Native Zig API (App / Component / Command)

The TEA core, in Zig, for native and in-engine use.

```zig
pub fn Component(comptime Model: type, comptime Msg: type) type {
    return struct {
        init:   *const fn (*Model) Command(Msg),
        update: *const fn (*Model, Msg) Command(Msg),  // mutates model, returns effect
        view:   *const fn (*const Model, *Frame) void, // paints into the frame
    };
}
```

`Command(Msg)` is a tagged union: `none`, `quit`, `batch([]Command)`,
`tick(duration, fn) `, `task(fn() Msg)` (run on a worker, result re-injected),
`navigate(target)`. The `App` owns the loop: read input → translate to `Msg` →
`update` → run returned `Command`s → `view` into the back buffer → diff → flush.
Background work (StzEngine metrics, queries, long installs) is a `task`/`tick`
exactly as ONCE's scrapers are `tea.Cmd`s.

### 4.8 L7 — C ABI (`libstztui`)

The surface every FFI host uses. Immediate-mode, opaque handle, scalar/pointer args
only. Detailed in §5.

---

## 5. The C ABI — `libstztui`

The design constraint is that the same calls must be ergonomic from Ring, from a
Zin-generated binding, and from C. That rules out passing Zig structs by value or
callbacks-with-closures across the boundary in v0.1. The model is therefore
**immediate-mode** (Dear ImGui-style): the host runs the loop, pumps events, and
between `begin_frame`/`end_frame` issues builder calls. Each builder call is a plain
C function; interactivity is keyed by a host-chosen `u32` id that comes back on
events.

This maps cleanly onto "observe and execute, never author": the host *observes*
events and *declares* the frame; the engine *executes* (renders, lays out, flushes).

### 5.1 Lifecycle

```c
typedef struct StzTui StzTui;

StzTui* stz_tui_init(const StzTuiOptions* opts);   // enters raw/alt screen, detects palette
void    stz_tui_deinit(StzTui*);                   // always restores the terminal

// Drives one iteration. Blocks up to timeout_ms for input; returns a tick event
// on timeout so animations advance. Fills *ev and returns 1, or 0 on quit.
int     stz_tui_next_event(StzTui*, int32_t timeout_ms, StzEvent* ev);
```

`StzEvent` is a flat tagged struct:

```c
typedef enum { STZ_EV_KEY, STZ_EV_TEXT, STZ_EV_MOUSE, STZ_EV_ZONE,
               STZ_EV_RESIZE, STZ_EV_TICK, STZ_EV_PASTE, STZ_EV_QUIT } StzEventKind;

typedef struct {
    StzEventKind kind;
    uint32_t     zone_id;     // STZ_EV_ZONE: which widget id was activated
    uint32_t     key;         // STZ_EV_KEY: keycode
    uint16_t     mods;        // ctrl/alt/shift/meta bitset
    int32_t      x, y;        // STZ_EV_MOUSE: cell coords (only in raw mouse mode)
    uint16_t     cols, rows;  // STZ_EV_RESIZE
    const char*  text;        // STZ_EV_TEXT / STZ_EV_PASTE (engine-owned, valid until next call)
    uint32_t     text_len;
} StzEvent;
```

Most apps only ever switch on `STZ_EV_ZONE` (a button/menu item/field was activated),
`STZ_EV_TEXT` (typing into the focused field), and `STZ_EV_QUIT`. The engine handles
Tab/arrow focus movement and mouse hit-testing internally and reports the resulting
`zone_id`; the host does not see coordinates unless it opts into raw mouse mode.

### 5.2 Frame builder

```c
void stz_tui_begin_frame(StzTui*);
void stz_tui_end_frame(StzTui*);   // layout + diff + flush; resets the frame arena

// Containers return an opaque slot id used to parent subsequent widgets.
uint32_t stz_tui_col(StzTui*, StzLayout);     // vertical stack
uint32_t stz_tui_row(StzTui*, StzLayout);     // horizontal stack
uint32_t stz_tui_grid(StzTui*, int cols, StzLayout);
void     stz_tui_end(StzTui*, uint32_t slot); // close a container

// Chrome
void stz_tui_title_rule(StzTui*, const char* crumbs);     // "─── App · crumb ───"
void stz_tui_help_bar(StzTui*, const StzHelpItem*, int n); // "↑/k up · a actions · …"
void stz_tui_starfield(StzTui*, int enabled);              // background layer
void stz_tui_logo(StzTui*, const char* art, int animate);  // shine sweep

// Content
void stz_tui_label(StzTui*, const char* text, StzStyleRef);
void stz_tui_panel(StzTui*, const char* title, uint32_t* out_slot); // bordered box
void stz_tui_chart(StzTui*, const char* title, const double* data, int n,
                   StzUnit unit, StzScale scale);
void stz_tui_gauge(StzTui*, const char* title, double current, double peak,
                   double max, StzUnit unit, StzThresholds);
void stz_tui_progress(StzTui*, int percent /* -1 = indeterminate */);
void stz_tui_metric_card(StzTui*, const StzMetricCard*);

// Interactive — each takes a host-chosen id, echoed back as STZ_EV_ZONE
void stz_tui_menu(StzTui*, uint32_t id, const StzMenuItem*, int n, int* selected);
void stz_tui_button(StzTui*, uint32_t id, const char* label, int primary);
void stz_tui_text_field(StzTui*, uint32_t id, const char* label,
                        char* buf, int buf_cap, StzFieldFlags);
void stz_tui_checkbox(StzTui*, uint32_t id, const char* label, int* checked);
void stz_tui_table(StzTui*, uint32_t id, const StzTable*);
```

The host stores its own state; the buffers it passes (e.g. the text-field `buf`) are
updated in place by the engine when the field is focused and the user types. This is
the immediate-mode bargain: trivial to bind from any language, no tree to marshal.

### 5.3 Theme and capability access

```c
void stz_tui_palette_override(StzTui*, const StzPalette*); // optional; default = detected
int  stz_tui_supports_truecolor(StzTui*);
void stz_tui_min_size(StzTui*, int cols, int rows);        // size-guard threshold
uint32_t stz_tui_color(StzTui*, StzSemantic);              // resolve a semantic color
```

### 5.4 Binding sketch (Ring host)

```ring
load "stztui.ring"            # thin wrapper over libstztui via Ring's C FFI

ui = stzTui([ :minCols = 80, :minRows = 24 ])
hostname = "books."
running = true
while running
    ev = ui.nextEvent(100)
    switch ev[:kind]
        on STZ_EV_QUIT     running = false
        on STZ_EV_TEXT     hostname += ev[:text]
        on STZ_EV_ZONE     if ev[:zone] = ID_INSTALL { install(hostname) } ok
    off

    ui.beginFrame()
    ui.starfield(true)
    ui.logo("ONCE", true)
    ui.titleRule("install")
    col = ui.col()
        ui.textField(ID_HOST, "Hostname", :ref hostname)
        row = ui.row()
            ui.button(ID_INSTALL, "Install", :primary = true)
            ui.button(ID_CANCEL,  "Cancel",  :primary = false)
        ui.end(row)
    ui.end(col)
    ui.helpBar([[ "enter", "install" ], [ "esc", "cancel" ]])
    ui.endFrame()
end
ui.deinit()
```

The Ring program authors no escape codes, computes no coordinates, and picks no
colors. It declares a frame and reacts to events. StzEngine does the rest.

---

## 6. Widget catalogue (v0.1)

Grouped by origin. Everything in the ONCE column is a like-for-like reimplementation
of a component analysed in §1; the "new" column covers what a general business app
(BCEAO/WAEMU back-office, dashboards, admin tools) additionally needs.

| Category    | From ONCE                              | Added for general use                 |
|-------------|----------------------------------------|---------------------------------------|
| Chrome      | `title_rule`, `help_bar`, `size_guard` | breadcrumb bar, status line           |
| Decoration  | `logo` (shine), `starfield`            | spinner set, rule/divider             |
| Data viz    | `chart` (braille), `gauge`, `progress` | sparkline (inline), histogram, donut* |
| Cards       | `metric_card`                          | stat card, KPI card                   |
| Input       | `text_field`, `checkbox`, `form`       | select/dropdown, radio group, slider  |
| Navigation  | `menu`                                 | tabs, tree, list (virtualised)        |
| Layout      | panel/box, row/col, overlay            | grid, splitter, scroll viewport       |
| Feedback    | (install activity)                     | modal, toast, confirm dialog          |
| Text        | static field                           | text viewer, log tailer, markdown\*   |

\* donut and markdown rendering are v0.2 stretch items.

Each widget specifies: construction parameters, `measure` behaviour, focus/keys,
mouse behaviour, and the `Command`/event it emits. The **Form** widget reproduces
ONCE's field model exactly — a `FormField` interface (`text`/`checkbox`/`static`),
Tab/Shift-Tab focus that skips non-focusable items, required-field validation with
inline error styling, and `submit`/`action`/`cancel` buttons — because that model is
proven and complete.

---

## 7. Palette and theming spec (ported algorithms)

The following are normative; StzTUI must reproduce ONCE's behaviour so output looks
identical given the same terminal.

**Detection.** Query order: `OSC 10;?` (fg), `OSC 11;?` (bg), `OSC 4;0..15;?`,
then `CSI c` (DA1) as sentinel. Read `/dev/tty` raw with deadline (default 100 ms).
Accept termination on: all 18 samples received, DA1 seen, or timeout. Parse
`rgb:R/G/B` with 1–4 hex digits per channel, each scaled by its own max
(`0xF/0xFF/0xFFF/0xFFFF`).

**`isDark`** = OKLCH lightness of detected background < 0.5 (default true).

**Synthesis (OKLCH):**
- `synthOrange(blue)`: `(L,C,H) = oklch(blue)`; `H = clamp(mod(H+180,360), 35, 75)`;
  `C = max(C, 0.10)`; `L = clamp(L, 0.55, 0.85)`.
- `synthTint(bg)`: `L = max(L − 0.015, 0)`, keep C,H.
- `synthLightText(bg,fg,blue)`: `L = bgL + 0.35·(fgL − bgL)`;
  `C = min(blueC·0.15, 0.04)`; `H = blueH`.
- `gradient(t)`: `oklch(green).blend(oklch(orange), clamp(t,0,1))`, used bottom→top.
- `pickPrimary()`: if Blue, BrightBlue, and bg all detected, choose whichever blue has
  greater `|L − bgL|`; else BrightBlue.

**Semantic aliases:** `Border = Muted = LightText`, `Focused = Warning = FocusOrange`,
`Primary = pickPrimary()`, `Error = Red`, `Success = Green`.

**Output:** ANSI slots → indexed SGR (honour user theme). Synthesised colors →
truecolor SGR iff `supportsTrueColor()`, else nearest ANSI slot. Disable
`BackgroundTint` entirely when truecolor is unavailable.

---

## 8. Braille rendering (normative tables)

- Base rune `0x2800`. Per cell: left column dots (bottom→top) `{0x40,0x04,0x02,0x01}`,
  right column dots `{0x80,0x20,0x10,0x08}`.
- **Chart:** inner width `W` cells → `2W` data points; rows `R` → `4R` vertical dots;
  `height[i] = round(v/max · 4R)`, with a 1-dot floor for any positive value; per-row
  color = `gradient((R−1−row)/(R−1))`; value labels (`max` on row 0, `0` on last row)
  rendered in `Border`. "Nice max" rounding: percent → ceil to 100s; bytes → first of
  {1,10,100 MiB, 1 GiB} ≥ raw else ceil to GiB; count → first of
  {100,1k,10k,50k,100k,250k,500k,1M} ≥ raw else ceil to 1M.
- **Gauge:** filled cells in fill-color, remainder in `Border`, single peak cell in
  `FocusOrange`; end-caps `⢾` (left) and `⡷` (right), interior `⣿`.
- **Progress:** determinate uses `2·width` sub-steps (`⣿` full, `⡇` half), else a
  per-tick random braille shimmer.
- **Starfield:** 100 stars, `z ∈ [0.1, 3.0]`, `z −= 0.03` per 33 ms tick, recycle when
  `z ≤ 0.1` or projection leaves the field; project `(x/z, y/z)` onto the `2W×4R`
  sub-grid; `bright` when `z < maxZ/2`.

---

## 9. Input and interaction model

- **Keyboard:** the engine owns focus traversal (Tab/Shift-Tab, arrows in menus,
  `j/k`), text editing inside the focused field, and global quit (`Ctrl-C`). It
  reports only the *consequences* to the host: `STZ_EV_ZONE` when an activation
  happens (Enter on a button, selection in a menu), `STZ_EV_TEXT` for committed text.
- **Mouse:** SGR 1006 decoding; the engine resolves clicks against the structural hit
  map (§4.5) and emits `STZ_EV_ZONE`. A host may opt into `raw_mouse` to receive
  `STZ_EV_MOUSE` with cell coordinates for bespoke widgets.
- **Resize:** SIGWINCH → `STZ_EV_RESIZE`; the next frame re-lays out. Below the
  `min_size` threshold the engine paints the size-guard message instead of the frame.
- **Paste:** bracketed paste arrives as one `STZ_EV_PASTE`.

---

## 10. Memory and performance (Zig specifics)

- **Allocators:** `stz_tui_init` takes (in the native API) an allocator for retained
  state — palette, buffers, zone table, widget registry. A **frame arena** backs all
  transient work between `begin_frame`/`end_frame` and is `reset(.retain_capacity)`
  at `end_frame`, so per-frame rendering does zero long-lived allocation in steady
  state. The C ABI uses StzEngine's default allocator unless overridden.
- **Comptime:** braille tables, wcwidth ranges, SGR templates, and the OKLCH matrices
  are computed at comptime; widget vtables are comptime-generated.
- **Diffing:** the renderer's flush is O(changed cells), not O(screen). A 2 s
  dashboard tick should touch only sparkline columns and changed numerals.
- **No hidden I/O:** all terminal writes funnel through one buffered writer flushed
  once per frame.
- **Budgets (targets):** ≤ 1 ms to compose a typical dashboard frame at 120×40;
  ≤ 16 KB steady-state allocation per frame (arena high-water); ≤ 4 ms cold palette
  detection (bounded by the 100 ms timeout only on non-responding terminals).

---

## 11. Testing strategy

ONCE's testability comes from pure string views; StzTUI keeps that and adds
buffer-level assertions.

- **Golden buffers:** render a frame to a `Buffer`, serialise to a plain-text +
  style-mask snapshot, assert against a golden file. Covers layout and content
  without a real terminal.
- **Palette unit tests:** feed synthetic `DetectedColors`, assert synthesised RGB and
  semantic aliases (port ONCE's `palette_test.go` cases, including light-background
  and incomplete-detection paths).
- **Input decoder fuzzing:** feed random byte streams; assert no panic, valid events.
- **Diff correctness:** render A then B, apply the emitted ANSI to a model terminal,
  assert it equals a from-scratch render of B.
- **Zone resolution:** assert `resolve(x,y)` returns the expected id for every
  interactive widget across layouts and resizes.
- **ABI contract tests:** drive the C surface from a C harness and from a Ring
  harness; assert identical golden buffers.

---

## 12. Integration with StzEngine

- **Packaging:** StzTUI ships as a StzEngine module; its symbols are exported through
  the existing `libstz` C ABI under the `stz_tui_*` prefix, following the
  "observe and execute, never author" rule already governing the FFI surface.
- **Event source unification:** StzTUI's tick/command mechanism reuses StzEngine's
  task runner so a host can fold engine-side work (a query result, a metrics scrape, a
  long-running operation's progress) into the same event pump — the dashboard pattern
  from ONCE, but engine-native.
- **Zui terminal target (note, not a v0.1 commitment):** a future Zui backend could
  compile its declarative UI to StzTUI builder calls, making the terminal one more
  render target alongside web/native. v0.1 deliberately specifies only the engine and
  ABI so any such DSL has a stable foundation to target.
- **Locale/RTL:** because the engine owns width handling and layout, locale-aware
  formatting (XOF amounts, fr_XOF dates, Arabic shaping) is added at L3/L4 once
  v0.1 is stable, not bolted onto host strings.

---

## 13. Roadmap

- **M0 — Floor:** L0 (raw/alt/input/OSC detect) + L3 (cell buffer, diff, width) +
  L2 (palette + theme). Deliverable: a "hello, harmonised terminal" demo that detects
  colors and paints a bordered box that survives resize and teardown.
- **M1 — Canvas + viz:** L1 braille canvas; chart, gauge, progress, sparkline,
  starfield, logo. Deliverable: the ONCE dashboard reproduced from sample data.
- **M2 — Interaction:** L4 layout + zones + focus; menu, form, button, text field,
  checkbox, help bar, size guard. Deliverable: the ONCE install flow reproduced.
- **M3 — ABI:** L7 `libstztui` immediate-mode surface + event pump; Ring binding;
  ABI golden-buffer parity tests. Deliverable: the install flow driven entirely from
  Ring with no escape codes in host code.
- **M4 — General widgets:** table, tabs, tree, modal, toast, select, scroll viewport,
  log tailer.
- **v0.2 candidates:** image protocols, retained scene-graph host model, Zui terminal
  backend, locale/RTL layout.

---

## Appendix A — ONCE → StzTUI mapping

| ONCE (`internal/ui`, Go)        | StzTUI (Zig)                          | Change of note                                   |
|---------------------------------|---------------------------------------|--------------------------------------------------|
| `component.go` `Component`      | L6 `Component(Model, Msg)`            | comptime-generic; views paint cells, not strings |
| `app.go` `App` + nav messages   | L6 `App` + `Command.navigate`         | same TEA shape, Zig tagged unions                |
| `palette_detect.go`             | L0 detection                          | ported verbatim in behaviour                     |
| `palette.go` OKLCH synthesis    | L2 `Palette`                          | ported verbatim in behaviour                     |
| `styles.go` styles + box/overlay| L2 `Theme` + L3 buffer ops            | box/overlay become cell ops, not string ops      |
| `chart.go`, `chart_scale.go`    | L1 canvas + chart widget              | same braille + nice-max logic                    |
| `metric_card.go`, `renderBar`   | gauge + metric-card widgets           | same rounded end-caps + peak marker              |
| `starfield.go`, `logo.go`, `progress.go` | decoration widgets           | same algorithms                                  |
| `menu.go`, `form.go`, `help.go` | interactive widgets                   | same focus/validation model                      |
| `terminal_size_guard.go`        | L3 size guard                         | same threshold behaviour                         |
| `mouse/` marker inject + sweep  | L4 structural hit map                 | **removed**: engine owns layout, records rects   |
| Bubble Tea / Lipgloss (external)| L0 + L3 (owned)                       | **added**: StzTUI implements the renderer itself |

---

*End of StzTUI Specification v0.1.*
