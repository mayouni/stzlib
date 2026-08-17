# SOFTANZA GUI PLAN — analysis and phased plan (G0–G6)

Status: **PLAN OF RECORD**, written 2026-08-13 before any GUI code, and
**reconciled 2026-08-14 against what was actually built.** G0, G1, G2, G3
and G4a are DELIVERED, with a STATUS section each at the foot of this
file; **G4b is BLOCKED on a decision recorded below**; G5 is HALF
delivered ahead of its turn (see §4b); G6 is untouched. 291 guard
assertions green across eight suites in `base/test/gui/`.

**The phase list in §8 is the plan as WRITTEN; the STATUS sections are
what HAPPENED.** Where they differ the STATUS section is right, and the
difference is marked in §8 rather than edited away — a plan that quietly
rewrites its own predictions cannot be checked against them.
Sibling documents this plan inherits from and does not repeat:
`base/graphics/SOFTANZA_GRAPHICS_PLAN.md` (GR0–GR6, complete — this plane
renders THROUGH it), `base/gpu/SOFTANZA_GPU_PLAN.md` (G0–G6, complete),
`base/sound/SOFTANZA_SOUND_PLAN.md` (house style for phases and STATUS
sections), and `engine/SOFTANZA_LOCALE_PLAN.md` (the vendoring precedent).

**The engine choice is MADE. RmlUi.** The survey that made it is
`D:\GitHub\stzzui\doc\GUI-SYSTEM.md` — read it in full before touching
anything here. This document implements; it does not re-run the survey.
The conditions under which the choice would be revisited are §2.4, and
they are the only door back.

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

Written to be **sufficient on its own** for a dedicated session that has
never seen this work, on the sound plane's precedent: one document, no
companion "context" file. This repo has already been bitten by duplicated
rule lists that DRIFT — the knob-gate audit found two entry points whose
copies of the same rules had diverged.

### The mission, in one paragraph

Give Softanza the widget, layout and interaction layer that sits **above**
the graphics plane: RmlUi for layout and markup, rendering through
`stzCanvas`, text through the existing SheenBidi → HarfBuzz →
rasterization pipeline, accessibility through AccessKit, behaviour through
the reactive layer — and authored **declaratively from Softanza**, never
by hand-writing markup. `stzWindow` already named this and left room for
it: *"it is not a widget toolkit… the rest is a different product."* This
is that different product.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/gui/SOFTANZA_GUI_PLAN.md` |
| **the survey that decided RmlUi** | `D:\GitHub\stzzui\doc\GUI-SYSTEM.md` — READ IN FULL |
| the law this plane obeys (never computes) | `D:\GitHub\stzzui\` — rules.json, `doc/THE-SECOND-FOUNDING.md` |
| the emission doctrine (§12: CSS is emitted, never authored) | `D:\GitHub\stzzui\doc\STZSENSE.md` |
| the plane below (READ its STATUS sections) | `base/graphics/SOFTANZA_GRAPHICS_PLAN.md` |
| the painter this plane draws into | `base/graphics/stzCanvas.ring` |
| the window and frame loop (GR5) | `base/graphics/stzWindow.ring` |
| **the reversible text layout (§0, landed)** | `engine/src/gpu_text.zig`, face on `base/graphics/stzFont.ring` |
| engine sources | `libraries/stzlib/engine/src/*.zig` |
| vendored deps (the pattern to copy) | `engine/vendor/` — see `harfbuzz/VERSION.txt`, `wgpu/VERSION` |
| build definition (domains + `addXxx` helpers) | `engine/build.zig` |
| Ring loaders for engine DLLs | `engine/stz_*.ring`, registered in `base/common/stzRingLibs.ring` |
| Ring faces for this plane | `base/gui/` — `stzPanel`, `stzUiDocument`, `stzAccessibilityTree`, and `stzGui.ring` (a LOADER, never a class — §2.5) |
| **the authored surface** | `.stzui`, §4b. Examples: `base/test/gui/showcase.stzui`, `gallery.stzui`, `form.stzui` |
| the engine half | `engine/src/stz_rmlui.cpp` (RmlUi behind a C ABI), `gui.zig`, `gui_font.zig`, `ring_bridge_gui.zig`, loader `engine/stz_gui.ring` |
| guards | `base/test/gui/` — eight suites, 291 assertions |
| scope-oriented moves (§7 runs M1–M5) | `base/doc/design/SCOPE_ORIENTED_PROGRAMMING.md` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```
# build every engine DLL (from libraries/stzlib/engine)
zig build

# run a guard (MUST be run from inside its topic directory)
cd libraries/stzlib/base/test/gui && ring gui_panel_narrated.ring
#   gui_panel_narrated 50 · gui_panel_adversarial 32 · gui_stzui_narrated 43
#   gui_font_narrated 30 · gui_rtl_narrated 37 · gui_tier_agreement_narrated 24
#   gui_input_narrated 38 · gui_accessibility_narrated 37

# see it, rather than read about it
ring gui_stzui_showcase.ring      # showcase.stzui, live (R reloads from disk)
ring gui_form_window.ring         # an operable form: tab, arrows, enter
ring gui_showcase_window.ring     # 1/2/3 layouts, T theme, S save
#   any of them with `shot` renders a PNG + SVG instead of opening a window

# the §0 gate's own guard, in the plane below
cd libraries/stzlib/base/test/gpu && ring gpu_text_reversible_narrated.ring

# cross-compile check
zig build -Dtarget=x86_64-linux-gnu
zig build -Dtarget=aarch64-macos
```

### The working discipline (non-negotiable)

1. **Measure before believing anything, including this plan.** Every phase
   gate is a measurement. The sibling plans named the wrong line
   repeatedly — G0's crossover seed was 62x too cautious, GR0's kill
   criterion aimed at a tier costing 3% of the budget. **Where contact
   with the code contradicts this document, the contradiction is the most
   valuable thing the session produces. Write it down.**
2. **Kill criteria are written BEFORE the numbers**, in this file, and
   applied even when they hurt.
3. **Guards are narrated and assert the MECHANISM**, never the vibe — and
   every positive needs its negative sibling, the thing that proves the
   guard would notice a failure.
4. **A bounded record COUNTS what it drops.** Dropped events, refused
   focus moves, unrendered nodes — countable from the first phase.
5. **Engine-first**: substance in Zig so any binding gets it; Ring is ONE
   face. Ring-side logic is capability other bindings will not have.
6. **CI has no GPU and no window.** Every guard passes through an offline
   path; device and window assertions are gated on presence, exactly as
   the graphics guards do.
7. **Parallel sessions work this repo**: `git add <explicit paths>`, never
   `-A`. Expect foreign commits between your edit and your commit;
   rebuild before diagnosing a strange failure.
8. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; VERIFY both with
   `git ls-remote <remote> main` against `git rev-parse main` — push
   output can lie. If codeberg fails, say PENDING and move on.
9. **Record the outcome in this file** (a `## G<n> STATUS/RESULTS`
   section) when a phase ends. This is the house rule most often skipped.

---

## §0 · THE GATE — CLOSED 2026-08-13

**Status: LANDED.** The full finding is filed where it belongs, with the
plane that owns the layout: `SOFTANZA_GRAPHICS_PLAN.md`, section
*"CROSS-PLANE FINDING — 2026-08-13: the text layout is now REVERSIBLE"*.
Guard `base/test/gpu/gpu_text_reversible_narrated.ring`, **41 asserts
green**, no device, no download, no system font.

In one paragraph, so this document stands alone: every platform IME —
Windows TSF (`GetTextExt`, `GetACPFromPoint`), macOS
(`firstRectForCharacterRange:`, `characterIndexForPoint:`), Android, the
Web's `EditContext` — demands **the screen rect of a character range** and
**the character index at a point, with a leading/trailing affinity bit**.
The layout could not answer either, and could not be *made* to by a
consumer, because the pipeline computed the necessary data and discarded
it: the per-glyph `x_advance` (folded into the pen), the run's bidi level
(reduced to one bool), and the cluster's end byte (recoverable only by a
scan in LOGICAL order over an array held in VISUAL order — so every
consumer would have written that reversal, and written it differently).
All three now survive; `rectsForRange`, `indexAtPoint` and `caretRect`
follow; and the property asserted is that **the round trip closes** —
`IndexAtPoint(x)` fed back to `CaretRectAt` lands on an edge of the very
glyph box containing `x`, through LTR runs, the RTL run, and the seams.

**Nothing in G1–G6 may start before this section reads LANDED.** It does.

**What the gate did NOT buy**, restated here because it will be tempting
to forget: the queries re-shape per call (a retained layout handle is a
wrapper, not a rewrite — but it is unbuilt and unmeasured); the layout is
still single-line; and **no IME was written.** This makes IME *possible*.
Nothing makes it cheap.

---

## §1 · What this plane is, and is not

**It is** the widget, layout and interaction layer above the graphics
plane: RmlUi for layout and markup, rendering through `stzCanvas`, text
through SheenBidi → HarfBuzz → rasterization, accessibility through
AccessKit, behaviour through the reactive layer, authored declaratively
from Softanza rather than by hand.

**It is not**:

- **a renderer** — the graphics plane owns that, and this plane must not
  grow a second one;
- **a semantic law** — StzZui owns which meanings exist and which
  conflicts are refusable. **If this plane ever grows a `:Danger`, the
  layering has collapsed;**
- **a composition binder** — `.face` owns that;
- **a delivery mechanism** — Zing owns that, and Zing's choice of the web
  for business applications stands (§6).

### The four constraints RmlUi was chosen to satisfy SIMULTANEOUSLY

Restated here so no later phase quietly trades one away. Any phase that
would break one of these is not a trade-off to weigh; it is a decision to
escalate under §2.4.

1. **permissive, vendorable source** — MIT;
2. **the host supplies the renderer** — 8 pure virtuals, vertices and
   indices out, no pixels in;
3. **no JavaScript engine** — behaviour comes from the reactive layer, so
   there is no second programming model and no JS runtime to vendor;
4. **a real input model** — focus, keyboard navigation, gamepad and
   directional navigation, text fields with selection and clipboard, and
   `ActivateKeyboard(caret_position, line_height)`, which is the IME
   positioning hook and which the §0 gate now has the numbers to feed.

### Why here, in `stzlib`, and not a repository of its own

The family's extraction rule is *an asset consumed by many projects lives
in none of them.* That rule already fired, one layer up: it extracted the
UI **law** to StzZui, because a law is a **contract** pinned by many
courts. This plane is not a contract. **It is an engine: it renders.**
Engines live in the foundation — which is why graphics, sound, GPU and
locale all do, despite each being consumed by several projects.

Extracting the renderer too would separate it from `stzCanvas`,
`stzWindow`, `gpu_text.zig` and the reactive layer, which it depends on
intimately, for no gain.

**When extraction WOULD become right**, so the question reopens on
evidence rather than instinct: *if the plane acquires consumers who take
it without stzlib.* That is an observation to make later, not a prediction
to act on now.

---

## §2 · Decisions recorded before code

Each is settled by `GUI-SYSTEM.md`. They are recorded with their reasoning
because a later session will otherwise re-litigate them badly.

### 2.1 · Flexbox only. No CSS Grid.

**No open-source C or C++ HTML/CSS engine implements CSS Grid. Not one** —
verified at source level, not read off feature lists:
`litehtml/src/render_flex.cpp` exists and `render_grid.cpp` 404s, with not
one `grid` identifier in its property headers; RmlUi's property index
lists complete flexbox including `gap` and no `grid-*` at all. Grid exists
only in **Rust** (Taffy, and Blitz/Servo through it), in WebKit-derived
**commercial** engines, or in **Sciter**. The alternative therefore costs
either a Rust toolchain as a hard build dependency or a proprietary
licence.

This constrains the design language of **every screen Softanza will ever
ship**, and it is deliberate on the project's own reasoning: the
expression stratum is **relational**, not metric — `STRUCTURE` declares
what is grouped and subordinate, never a track list — so grid is a
projection's implementation detail rather than a contract term.

**The trap, named so it is refused on sight: grid on the web tier and
flexbox natively.** That is two design languages wearing one name, and it
is precisely the drift this project exists to prevent.

> **THIS DECISION IS NOW IN TENSION WITH G4.** The reasoning above —
> *no Rust toolchain in the build* — is the same reasoning AccessKit
> would spend, and AccessKit ships no binaries. See
> *"G4 · THE CONTRADICTION INSIDE THIS PLAN"* below. **§2.1 stands until
> that decision is made**; it is cross-referenced here so nobody reads
> this section and believes the question is closed.

**One recorded trap for whoever reads Yoga's headers**: 43 CSS Grid
functions landed in Yoga's *public API* on 2026-03-05 as "part 1/9", and
there is **no grid file under `yoga/algorithm/`** and nothing since. The
API advertises grid; the engine cannot do grid.

### 2.2 · Logical caret movement, not visual

**The single highest-leverage scope decision in the text area.** Blink
retreated from visual in Chrome M76 saying it was *"based on hacks with
many bugs"* and that it blocked their layout rewrite; Gecko's meta bug ran
from 2003 with 35 dependants. Platforms genuinely disagree — Windows,
Android, Word and Docs move logically; macOS moves visually with a split
caret; GTK visual, Qt logical — and UAX #9 specifies reordering for
*display* and says nothing about caret movement, selection or deletion, so
this is the implementation's call and never the standard's.

**Already applied**: the §0 gate's `caretRect(index, trailing)` is the
logical shape, and the decision is recorded in the graphics plan too.

### 2.3 · RTL from commit one

Text direction is **a parameter threaded through the layout protocol**,
not a feature added later. Flutter needed a dedicated PR introducing
`Directionality` as an inherited widget plus `EdgeInsetsDirectional`,
touching its core layout files, because the parameter cannot be
retrofitted cheaply. With SheenBidi already in the pipeline and Arabic a
first-class case, this is a **differentiator**; retrofitted, it is a
rewrite.

The comparison that says how much of one: **egui has no bidi after five
years** (its bidi *editing* issue has been open since 2021, funded and
actively released); **LVGL has positional forms without a shaping
engine**; **Avalonia carries a six-year tail of RTL regressions.**

Concretely, every phase below: no layout API takes a width without also
being able to take a direction, and no guard asserts an LTR case without
its RTL sibling.

### 2.4 · When RmlUi would be revisited — the only door back

Named now so the answer is evidence and not fatigue:

- if the `TextShapingContext` hook **cannot carry what HarfBuzz needs**
  (decided in G0 — and this one ends the choice, because it was the whole
  reason RmlUi won);
- if **render-to-texture text quality fails at oblique angles** (G0);
- if the project's **licence or maintenance posture changes**.

**Absent one of those, the choice stands.** If one fires, the survey's own
fallback is recorded and it is *not* litehtml: it is **Clay plus
composition** on Slint's precedent, accepting that you then own the 6.6 MB
of non-layout surface §3's cost table describes. litehtml avoids the
markup dialect and charges the same bill anyway.

### 2.5 · The name — `stzGui` is a LOADER, never a class

`stzGui` and `StzZui` differ by one letter and name two adjacent layers of
one stack that will appear in the same sentence forever. Rather than
rename a directory, the collision is **dissolved at its actual source**,
which is the M1 move this project already knows: *ask whether the frame is
an essential decision or noise to dissolve.*

The confusable token is a **class name**, not a directory. So:

- `base/gui/` stays — it sits beside `graphics/` and `sound/`, and
  "the GUI plane" beside "StzZui" reads without ambiguity;
- `gui/stzGui.ring` is a **pure loader/aggregator**, like `stzBase.ring`.
  **No class is named `stzGui`, and none may be.** There is no god-class
  here to need one;
- classes are named for what they are — `stzPanel`, `stzFocusTree`,
  `stzUiEvent` — and none of those collides with anything.

*The author's veto was invited at the cheapest moment and did not come.*
**Settled by use as of 2026-08-14**: `base/gui/` and `stzGui.ring` are in
nine commits, three classes and eight guard suites. It is still
reversible — the change is a directory rename and one loader line — but
it is no longer free, and this records that the moment passed rather than
leaving an open question that reads as though it is still cheap.

---

## §3 · The CSS/RCSS profile is a CONTRACT, not an implementation

This is the section that turns a vendoring decision into an architecture,
and it is load-bearing enough to stand alone.

If Softanza emits RCSS and RmlUi renders it, then **RmlUi's coverage
silently becomes the definition of what Softanza's UI can express**, and
the native and web tiers diverge without anyone noticing — the drift this
whole project exists to prevent, reappearing at the rendering layer.

> **Name a CSS/RCSS profile. The emitter targets the profile. RmlUi is one
> conforming implementation; a browser is another. Fixtures render the
> same document both ways and compare on stated observables.**

Consequences that bind the phases:

- the profile is **written down as data**, in the family's habit — not
  implied by whatever the emitter happens to produce;
- **G0 begins the fixture**, in embryo: one document, two renderings,
  compared. It does not wait for G6;
- a property RmlUi supports but the profile does not name is **not
  available to the emitter**. Convenience is exactly how the profile
  rots;
- and the payoff: **the native path can be replaced later without
  touching a single sense sheet.**

---

## §4 · RML is emitted, never authored

`STZSENSE.md` §12.1 establishes that CSS is emitted and never hand-written
because *every hand-written CSS rule is a meaning that escaped the
semantic layer* — the court cannot see it, the culture axis cannot vary
it, the statute tier cannot constrain it. **The same rule binds RML, and
harder**, because RML is XML-syntax markup and **not HTML**: element names
are open-ended, and unclosed `<br>` and `<img>` will not parse. A dialect
invites hand-authoring precisely because no browser will check it.

So the architecture is stated once:

> **Softanza declarations are the contract. RML is one projection and HTML
> is another.** The web tier emits HTML for a browser; the native tier
> emits RML for RmlUi; **neither is the source of truth.**

A Softanza application that hand-writes RML has bypassed its own semantics
exactly as one that hand-writes CSS has, and the honest statement is the
same: **the court is blind there** — not that it is forbidden.

---

## §4b · The authored surface: `.stzui` (v0.1, and it GREW)

**Delivered with G1; extended by every phase since.** The grammar below
is the shape as first shipped; three fields were added by later phases
and are marked where they appear — `TEXT_ALIGN` (the RTL pass),
`FOCUSABLE` (G3), and `ROLE` + `LABEL` (G4a). The full emitter default
table is the one at the end of this section, which is kept current.

§4 forbids hand-writing the projection and §5 of `GUI-SYSTEM.md` forbids
hand-writing the meaning — which left the plane with **no text surface a
person may write at all**. That gap is real: every other Softanza plane
has one (`.stzgraf` for graphs, the material language for shaders, `.game`
for scenes, `.zui` for intent), and a UI plane whose only authoring story
is "call Ring methods" fails the family's own contracts-are-the-substrate
doctrine. `.stzui` is that surface: **the file IS the contract, and RML/
HTML are its projections.**

### Jurisdiction, stated before the grammar

- `.stzui` declares the **projection**: boxes, sizes, directions, colours.
  It declares **no meanings** — there is no `:Danger` and there never may
  be. When the sense sheet lands (G6), colour fields learn to carry sense
  *references*; resolving them stays StzZui's.
- `.zui` (StzZui) declares **intent** and remains untouched. The two
  formats meet only when a later phase binds a panel to a flow.
- **It conforms to the Grammar Commons (C6 v1.0)** — `DEFINE <KIND>
  <name> ( fields ) RATIONALE "…"`, `--` comments, case-sensitive
  `UPPER_SNAKE` keywords, `[ a, b, c ]` lists with trailing comma,
  double-quoted strings, `lower_snake` identifiers. A language born after
  the commons has no licence to diverge, and this one records **no
  divergence**. The commons' Ring trap is handled: every keyword compare
  is `strcmp`, never bare `=`.

### What was taken from QML, and what was refused

QML is the strongest prior art for declarative UI ergonomics, and the
survey of it produced one adoption, two deferrals and two refusals:

- **ADOPTED — the property-bag-per-item shape.** A QML item is a name
  plus typed properties; so is a commons declaration. The mapping is
  direct.
- **REFUSED — anonymous nested items.** QML nests item trees inline, and
  most items end up nameless. Here structure is `CHILDREN [a, b, c]` and
  **every box has a name**, because a nameless box is exactly what makes
  accessibility (G4), hit-testing (G3) and the court's paint-time audit
  retrofits instead of queries. Flat declarations also diff and merge
  cleanly — the commons' own argument for its list form.
- **REFUSED — the JavaScript engine.** QML's expressions ride V8;
  constraint 3 of §1 forbids exactly that. Behaviour belongs to the
  reactive layer.
- **DEFERRED — property bindings** (`width: parent.width * 0.3`). The
  grammar's value forms leave room for a reference form; wiring it to
  Reaxis is G5's, and RmlUi's own `{{ }}` data bindings are the likely
  carrier.
- **DEFERRED — states and transitions.** G5 territory.

### The grammar, v0.1 — four kinds, closed

```
-- app.stzui -- one sentence saying what this interface is.

DEFINE PANEL main (
  SIZE [1000, 640],
  DIRECTION column,
  FONT "segoeui",
  BACKGROUND "#0f1419",
  CHILDREN [bar, work]
) RATIONALE "The screen: a bar over a work area."

DEFINE STYLE card (
  WIDTH "30%", HEIGHT 92, MARGIN 9, BACKGROUND "#243040"
) RATIONALE "One plane tile, reused by every card."

DEFINE BOX bar (
  DIRECTION row, HEIGHT 52, BACKGROUND "#2b6cb0", CHILDREN [t1]
) RATIONALE "Top navigation."

DEFINE TEXT t1 (
  CONTENT "Softanza", SIZE 20, COLOR "#e8eef5", PADDING 14
) RATIONALE "The brand, top left."
```

**Kinds**: `PANEL` (exactly one per file, the root), `BOX`, `TEXT`,
`STYLE`. **Fields per kind are closed sets**; an unknown field is an
error, not a warning. Values are numbers (px), strings (`"30%"`, colours,
content), identifiers (`row`, `column`, `fill`, `yes`, `rtl`), and lists.

**Layout vocabulary is flexbox because §2.1 decided flexbox**: `DIRECTION
row|column`, `WRAP yes`, `GAP n`, `PADDING n`, `MARGIN n`, `ALIGN
start|center|end`, `JUSTIFY start|center|end|between`, `WIDTH`/`HEIGHT`
as px, `"n%"`, or `fill` (grow into the leftover). `TEXT_DIRECTION rtl`
threads §2.3's parameter. `STYLE <name>` on a box merges a named bag,
local fields winning.

**`RATIONALE` is mandatory on every declaration** — the commons legislates
it, and here it is not ceremony: a rationale per region is the seed of the
G4 accessibility tree, a sentence per widget saying why it exists.

### Why the emitter is the argument

The format's defaults absorb, invisibly, every divergence G1 paid to
find. An author writes none of this:

| the author writes | the emitter guarantees |
|---|---|
| nothing | explicit `display` on every element (RML defaults to INLINE — divergence 4) |
| nothing | the root sized to its panel (`body` does not fill — divergence 3) |
| `FONT "…"` once, or nothing | a `font-family` always declared (no font = NO TEXT AT ALL — divergence 5) |
| `TEXT_DIRECTION rtl` | `--rmlui-direction: rtl` (RCSS rejects the CSS spelling — divergence 1) |
| nothing | every tag XML-closed (divergence 2) |
| `WIDTH 210` | **210 means 210**: `flex-shrink: 0` rides along, because a size a person declares is a floor, not a basis — the flexbox default cost this plane two invisible-bar bugs |
| `WRAP yes` | `align-content: flex-start` rides along, or wrapped lines spread down the container |
| `WIDTH 210, PADDING 20` | **210 total, padding inside**: `box-sizing: border-box` on every element. CSS's content-box default made the first rendered sidebar 250 px and nothing at the call site said why |
| `TEXT_DIRECTION rtl` **once, on the panel** | the whole subtree flips: `text-align: right`, `flex-direction: row-reverse` on every row, and the shaper's base-direction hint on every element. RmlUi's own direction property reaches ONE line of its layout — a dirty flag feeding the shaper — so it aligns nothing and reverses nothing |
| `TEXT_ALIGN start` / `end` | direction-**relative**, resolved per element against the direction in force. RCSS knows only `left`/`right`, so without this an author writes two stylesheets |
| `ROLE button` | the accessibility tree's role, from a closed vocabulary every platform already knows — and `LABEL` for the name a reader says. **A role is not a meaning**: it decides no colour, no emphasis, no refusal |
| `FOCUSABLE yes` | `tab-index: auto` **and** `nav: auto`. Both are opt-ins that read like defaults, and `nav-*` defaults to `none` — so arrows do nothing until set. The APG contract is one tab stop per composite with arrows *within*; half of it silently absent is the gap Rule 80 forbids |

**A declared size means what it says** is the design decision that makes
`.stzui` better to write than the CSS it compiles to.

### The court, from birth

The commons' four checks, implemented in the face (`stzUiDocument`) with
C2-shaped diagnostics (`code`, `severity`, `message`, `span`, `cites`,
`language: "stzui"`): **closure** (one verb, four kinds, closed field
sets), **reference resolution** (every `CHILDREN` and `STYLE` name
resolves; a box appears under one parent; no cycles), **duplicate
declaration**, and **round trip** — `Parse → ToText() → Parse` is a
fixpoint, asserted in the guard.

### Status — v0.1 SHIPPED with G1 (2026-08-13)

`base/gui/stzUiDocument.ring`: parse, court, canonical printer, RML
emitter, `ToPanel()`. Guard `base/test/gui/gui_stzui_narrated.ring` —
**42 asserts green**: every court refusal by name (including the
lowercase-`define` case-sensitivity trap), the round-trip fixpoint
byte-identical, every emitter default asserted on the RML and then
proven on a laid-out panel (`WIDTH 100` lays out as exactly 100;
`HEIGHT fill` takes exactly the leftover; `WIDTH 100, PADDING 10`
occupies 100, not 120). The G1 showcase screen exists as
`base/test/gui/showcase.stzui` — 20 declarations, court-clean,
round-trips, renders via `gui_stzui_showcase.ring` (window with
press-R-to-reload, or `shot` → PNG + SVG). Two findings from contact:
**RmlUi honors `box-sizing: border-box`** (registered in its property
table, verified by layout), and **flexbox `gap` works** — `GAP 26` on
the showcase bar laid out correctly, confirming the survey's claim.
**Not ratified as a Ringua language** — like `.game`, the decisions are
settled, the expression becomes a Ringua language when Ringua Phase 2
reaches it, and v0.1 is marked so.

---

## §5 · The cost, measured rather than feared

Carried forward from the survey so no phase is planned in ignorance of it.
These are the numbers that make §6's ordering the only defensible one.

| Piece | Evidence-backed cost |
|---|---|
| IME across five platforms | **1–3 engineer-years**, and it never closes |
| Bidi *editing* on top | **+1–3 engineer-years** — unless logical caret movement is chosen (§2.2 chose it) |
| Accessibility from scratch, five platforms | **3–6 engineer-years** |
| …adopting **AccessKit** instead | cuts the *adapter* half only |
| Selection, graphemes, clipboard, undo | +3–6 months |
| Latin-only field, no IME, no bidi | days — **and it is a trap, because it looks finished** |

**Layout is about 15% of a toolkit.** Flutter's own source, counted by
subsystem, puts the non-layout non-paint surface at **~6.6 MB**: scrolling
1,051 KB (including a physics engine with two national dialects, and
*slivers* — a **second layout protocol** invented because box constraints
cannot express lazy infinite content); text input, IME and selection
686 KB; **keyboard mapping alone 569 KB** — half a megabyte just to know
which key was pressed; gestures and hit-testing 462 KB; focus 238 KB (a
**separate sparse focus tree** parallel to the widget tree, with pluggable
traversal policies); intents/actions/shortcuts 184 KB.

**And the single most useful number in the survey**: Flutter could not
write an accessibility tree, so it forked Chromium's —
`third_party/accessibility/` is **228 files, 3,467,964 bytes of C++**, and
its README freezes it. Slint's equivalent is **40,211 bytes of AccessKit
glue.** *3.3 MB forked and frozen against 40 KB leased.* That is not a
trade-off; it is a correction, and it is why G4 is not optional.

**One deadline worth knowing**, because for some buyers accessibility is
not this project's law but statute: the US DOJ's Title II rule binds state
and local government **mobile apps** to WCAG 2.1 AA with deadlines of
**April 2027** and **April 2028**; the European Accessibility Act already
covers kiosks, ATMs, banking and e-commerce — exactly the embedded and
custom-UI territory this plane would serve.

---

## §6 · Order of attack — and the one thing not to do

**Start with the in-scene and game case, not business applications.**
There the graphics plane's strengths are highest, RmlUi is proven in
shipped games, in-world panels are a trodden path — and the
constitution's hardest requirements bind least, since Rule 60's
screen-reader duty and Rule 80's keyboard sovereignty are scoped by a
preamble addressing *"business users… under pressure, responsibility,
fatigue and risk"*, which a game HUD is not.

**Do not point this plane at operator-facing business software until
accessibility and IME are funded as multi-year work.** Doing so would ship
a product that violates this project's own law, in the medium where that
law is strictest. **The web tier remains the delivery path for business
applications**, as Zing already chose; nothing in the survey argued for
changing that and a great deal argued against — the web tier gets IME,
accessibility and CSS Grid free from the browser, and the native tier pays
years for the first two.

This is an argument about **order**, not an argument against the native
GUI.

---

## §7 · The Scope-Oriented moves, run on this field

A GUI has hidden frames, and naming them early is cheaper than discovering
them. `SCOPE_ORIENTED_PROGRAMMING.md`'s thesis: *some fields are hard not
because their operations are hard, but because the same expression behaves
differently depending on a context invisible at the place you wrote it.*

**M1 — the candidate frames**, with the paradigm's real question asked of
each: *an essential decision, or noise to dissolve?*

| Frame | Invisible today because… | M1 verdict (to be tested by contact) |
|---|---|---|
| **coordinate space** | local, layout, window, screen, texture — the same number means five things and nothing at the call site says which. **The bug factory in every toolkit.** | ~~Surface~~ → **DISSOLVED**, and M3 below explains why the first verdict was wrong: a panel admits ONE space, so there is nothing to confuse, and the conversion is a named function at the boundary |
| **input source** | pointer, keyboard, gamepad, synthetic, assistive technology | **Surface.** Rule 80 makes "did a human keyboard do this" legally material, and an AT-originated event must be distinguishable from a synthetic one |
| **tier** | in-scene, window, texture | **DISSOLVED**, confirmed by contact: nothing in G1–G4 ever needed to know its tier. A panel draws into a canvas and the canvas decides its destination |
| **which document** | several panels alive at once | **Dissolve.** This is an object, not a scope: a panel IS the document |

### M2–M5, run before G3's event model — 2026-08-14

**M2 — are they small closed sets?**

- **Coordinate space**, *for this plane*: only two conversions exist —
  a window's pixels, and a texture's uv when a panel hangs in a 3D
  scene. With the panel's own space that is three. Passes.
- **Input source**: pointer · keyboard · gamepad · synthetic ·
  assistive. Five. Passes.

**M3 — and here the two frames take opposite answers, which is the
useful part.**

**Coordinate space is DISSOLVED, not surfaced.** The paradigm's own
guidance is that a frame you can eliminate should be eliminated, and
M1's sanity check asks for exactly one such candidate. This is it: a
panel admits **one** space — its own pixels — and every input verb takes
that and nothing else. The conversion is then not a hidden frame but an
ordinary named function at the boundary, `FromWindow()` or
`FromTexture()`, called where the conversion actually happens and
nowhere else. There is no ambient "current space", no mode, and no way
to pass window pixels to a panel by accident, because the panel has no
other space to confuse them with.

The §0 gate is the counter-example that proves the frame was real
before it was dissolved: `x` (draw position) and `pen` (hit box) are two
coordinate meanings on one axis, and conflating them is the classic
caret bug. Two names, no frame.

**Input source is SURFACED, and it rides on the event.** It is a
property of a particular event, not of a region of code, so a carrier on
the event object is the honest home. It earns its place twice over:
Rule 80 makes *"was this reachable by a human keyboard"* materially
different from *"did something dispatch a click"*, and G4 needs an
assistive-technology activation to be distinguishable from a pointer.
A synthetic event that could not be told from a real one would make the
keyboard-sovereignty guard unfalsifiable.

**Tier is DISSOLVED**, as M1 suspected. A panel draws into a canvas and
the canvas already decides its destination; the graphics plane made the
same call when it adopted the swapchain frame as an ordinary render
target rather than a mode. Nothing in G1–G3 needed to know its tier.

**Which document** was dissolved before it was written: a panel *is* the
document.

**M4 — what the library computes with them.** The input source makes
Rule 80 checkable: a guard drives a screen with keyboard events only and
asserts every action was reached, which is a *property of the run*
rather than a property of the markup. Nothing computes with coordinate
space, which is the strongest argument for having dissolved it.

**M5 — rehearsal.** `oPanel.PointerMovedTo(x, y)` reads as panel pixels
because a panel has no other pixels; `oPanel.FromWindow(oWin, nx, ny)`
says the conversion out loud at the one place it happens; and an event
answers `Source()` because the answer differs per event and matters to
the law.

---

## §8 · Phases

House discipline throughout: **kill criteria written before the numbers**,
a **challenge pass before the faces**, and a **STATUS section per phase
recording measurements AND what was not measured.**

### G0 · The spike — vendoring authorized here, and only here
**DELIVERED** — see *G0 STATUS*. Three of four criteria passed; criterion
3 moved to G1 and passed there.

One real Softanza screen through RmlUi into a `stzCanvas` texture, with
`RMLUI_FONT_ENGINE` off and the existing pipeline supplying
`FontEngineInterface`.

**Vendoring authorized**: RmlUi, MIT, ~54k LOC core, active through August
2026 (6.2 released January 2026), into `engine/vendor/rmlui/` under the
house `VERSION.txt` discipline — source URL, tag, commit, date, SHA-256,
and *this plan section* as the authorization. **Core only**: no samples,
no backends, no FreeType font engine, no Lua or Lottie plugins.

**Kill criteria, stated before any measurement:**

1. **Does `TextShapingContext` carry enough for HarfBuzz shaping?** If
   shaping cannot be plugged in, **STOP** — that was the whole reason
   RmlUi won, and §2.4's first door is the one that opens.
2. **What is layout cost per frame**, and does caching make
   re-layout-on-change viable? Every retained-mode UI answers this by
   caching; the question is whether the numbers permit it here.
3. **Is text legible in a texture mapped at an oblique angle?** The
   in-scene tier is where this plane starts (§6), so this is not a
   curiosity.
4. **Does it build under `zig c++` with no cmake and no SDK?** The
   vendor-table test every dependency in this house has passed. HarfBuzz
   and ggml are the precedents that say a large C++ vendor is possible;
   neither says it is free.

**Also in G0, because §3 says the fixture starts in embryo**: one
document, rendered by RmlUi and by a browser, compared on stated
observables. Not the full conformance suite — the first fixture, and the
shape of the comparison.

### G1 · The render interface
**DELIVERED** — see *G1 STATUS*.

The 8 pure virtuals against `stzCanvas`; `PushLayer` / `CompositeLayers` /
`SaveLayerAsTexture` for the in-scene case. **Prove a panel inside a 3D
scene**, since that is the tier this plane starts with (§6). Watch the
`tier` frame here and decide M1's verdict on it by contact.

### G2 · The font engine
**DELIVERED** — see *G2 STATUS*.

Replace FreeType outright. **This is where bidi and Arabic are proven**,
and where the plane's advantage over every surveyed toolkit is realised —
see §2.3's comparison. The §0 gate feeds this phase directly: RmlUi's
`ActivateKeyboard(caret_position, line_height)` takes exactly what
`caretRect` now returns.

### G3 · Input, events and focus — the real gap
**DELIVERED** — see *G3 STATUS*, which records that this section
**under-credited RmlUi**: it already had input, focus, tab order and
spatial navigation, so the phase became *expose and add the three missing
things* rather than *build a model*.

Graphics input is **polled** (`KeyPressed`, `MouseClicked`), which is the
game-loop shape and is right for a game. It cannot express *which element
was hit*, *who has focus*, or *what bubbles*. So this is a genuine
architectural addition, not a wrapper.

Build: a **routed event model**; a **sparse focus tree separate from the
widget tree** (Flutter's 238 KB says this separation is not optional); and
**traversal policies**. Adopt the **WAI-ARIA APG keyboard contract** — one
tab stop per composite widget, arrows within — as it is the only genuinely
cross-platform semantic standard.

**Rule 80, Keyboard Sovereignty, is `machine` tier: this phase is legally
required, not optional polish.** §7's M2–M5 land before this phase's
design, not after.

### G4 · Accessibility, via AccessKit — and NOT last

> **SPLIT. G4a (the tree) is DELIVERED; G4b (the adapter) is BLOCKED.**
> The instruction below — *adopt AccessKit* — collides with §2.1, because
> AccessKit ships no binaries and so means a Rust toolchain. It is left
> standing as written, with the collision recorded in *"G4 · THE
> CONTRADICTION INSIDE THIS PLAN"*, because editing the instruction away
> would hide the decision instead of forcing it.

Adopt AccessKit (Apache-2.0 OR MIT), bridging UI Automation,
NSAccessibility, AT-SPI, Android and iOS. **Know its limits before
designing around it**: no rich text or hypertext, no AT-SPI `Collection`,
and **no web adapter** (listed as planned; egui falls back to an
experimental built-in screen reader in the browser). So the story is solid
natively and unsolved on the web — the inverse of the usual situation, and
it lands squarely on the transversality claim.

**The redemption is real and better than parity**: a browser *infers* an
accessibility tree from markup; Softanza can *emit* one from **declared
intent**, which is strictly better information.

**Two structural warnings from the survey, and the phase must do
neither:**

- **virtualised lists are the universal failure mode** in every custom
  renderer examined;
- **every toolkit gates accessibility behind a performance flag, which is
  where users silently get nothing.**

### G5 · The declarative surface

> **HALF DELIVERED, AHEAD OF ITS TURN.** *Softanza declarations →
> RML/RCSS* is what `.stzui` and its emitter already do (§4b), shipped
> with G1 because §4 had otherwise left nothing a person may write. What
> REMAINS of G5 is the second clause: **the binding to the reactive
> layer** — making a declared value change and the screen follow.

Softanza declarations → RML/RCSS, with RmlUi's data-binding wired to the
reactive layer. Its `data-` attributes and `{{ }}` expressions are a
closer architectural cousin to Reaxis than any JS engine would be — **use
them rather than inventing a parallel mechanism.**

### G6 · The sense sheet lands
**NOT STARTED**, and blocked outside this repo: it needs `stzSense` from
StzZui.

`stzSense` → RCSS for this tier, and → CSS variables for the web tier,
**from one artifact**. This is where the whole semantic stack meets the
renderer, and where §3's profile stops being a promise.

### Deferred, and COSTED rather than forgotten: IME

1–3 engineer-years across five platforms, and it never fully closes —
GLFW's request has been open since **2013**; `winit` still lists Windows
as partial with iOS and Android absent; Flutter's Windows embedder still
uses IMM32 rather than TSF, so Windows Voice Typing and handwriting
**cannot type into a Flutter text field at all**; and Zed — well funded,
custom renderer — carries roughly **ten open IME bugs simultaneously**,
including a memory leak during Chinese composition. Alacritty has had IME
crashes and a **preedit leaking into a password field**.

**§0 makes it possible. Nothing here makes it cheap.**

---

## §9 · Risks, named now

1. **RmlUi's coverage becomes the contract by default.** Answered by §3 —
   but only if the profile is actually written down, and the cheapest
   moment to skip that is G0.
2. **The dialect invites hand-authoring.** RML is not HTML and no browser
   will check it, so the pressure to hand-write "just this one panel" is
   higher than it ever was for CSS. §4 is the answer and it needs a guard,
   not just a paragraph.
3. **The in-scene start becomes the only tier.** §6's ordering is about
   order; if G1–G3 optimise exclusively for in-scene, the business tier
   becomes unreachable rather than merely deferred.
4. **Accessibility slips to "after the faces."** It has slipped in every
   toolkit surveyed. G4 sits before G5 in this plan deliberately, and
   moving it is a decision to record, not a scheduling detail.
5. **A large C++ vendor destabilises the build.** HarfBuzz collected two
   Windows lessons the hard way (a vendor-root `VERSION` file collides
   with C++'s `<version>` header on case-insensitive filesystems; a bare
   `text` import shadowed bridge locals). RmlUi is larger. Expect to pay
   something similar and write down what it was.
6. **The window may simply be absent.** `stz_window.dll` cannot be
   cross-built for every OS from one machine, and `IsAvailable()` answers
   false on a headless runner. Every guard in this plane must have an
   offline path, and the texture tier is what provides it.

---

## §10 · Do not

- **Do not fork RmlUi early.** Vendor it under the house `VERSION.txt`
  discipline and send patches upstream. A fork is a permanent tax — note
  that Avalonia deleted its second rendering backend for want of parity
  maintenance.
- **Do not implement platform accessibility bridges by hand.** That is the
  3.47 MB mistake, and it is measured.
- **Do not build or embed a JavaScript engine**, and do not adopt anything
  that links one. This is constraint 3 of §1 and it is not negotiable at
  phase level.
- **Do not let this plane compute meanings.** Which meanings exist and
  which conflicts are refusable are StzZui's. A `:Danger` here means the
  layering has collapsed.
- **Do not treat §8's phase list as fixed.** It was written from a survey,
  not from building.

---

# G0 STATUS — 2026-08-13. VERDICT: **GO**, on three of four criteria; the fourth is untouched and says so

Reproduce: `zig build rmlui-g0` (from `libraries/stzlib/engine`), 57 s cold.
Probe: `engine/tools/rmlui_g0_probe.cpp` — drives RmlUi for real with STUB
render, font and system interfaces. No canvas, no GPU, no Ring, no
HarfBuzz: the point was to learn what the seam demands **before** building
the real thing against it.

## Vendored

**RmlUi 6.2**, MIT, `engine/vendor/rmlui/`, SHA-256
`814c3ff7b9666280338d8f0dda85979f5daf028d01c85fc8975431d1e2fd8e8b`.
Core only: **183 `.cpp`, 424 files, ~3.1 MB**. Dropped at the root rather
than disabled at build time — `FontEngineDefault` (FreeType), `Backends/`,
`Samples/`, `Tests/`, `Lua`, `Lottie`, `SVG`, `Debugger`. Full reasoning in
`vendor/rmlui/VERSION.txt`.

**The vendored tree has ZERO external dependencies.** Dropping
`FontEngineDefault` is what achieved that: `ft2build.h` was the only
non-standard include in the whole core, and it lived there. The remaining
non-C++-standard includes across 424 files are `<ctype.h>`, `<float.h>`,
`<limits.h>`, `<stdarg.h>`, `<stddef.h>`, `<stdint.h>`, `<stdio.h>`,
`<stdlib.h>`, `<string.h>` and, on Windows, `<windows.h>`.

## Criterion 4 — builds under `zig c++`, no cmake, no SDK: **PASS**

**183 of 183 TUs, zero errors, 232 s** on the dev machine. Two flags were
paid for in build errors, and both are **differences from HarfBuzz**, the
house's other large C++ vendor:

| flag | HarfBuzz | RmlUi | what happens without it |
|---|---|---|---|
| `-DRMLUI_STATIC_LIB` | n/a | **required** | `RMLUICORE_API` defaults to `__declspec(dllimport)`; 22 errors, "dllimport cannot be applied to non-inline function definition" |
| `-fno-exceptions` | fine | **must NOT** | the in-tree `itlib/flat_map` throws; 3 TUs refuse |
| `-fno-rtti` | fine | **must NOT** | `Traits.h` calls `typeid(T).name()`; **391 errors** |

**RmlUi requires C++ exceptions and RTTI.** That is a real constraint on
whatever DLL eventually links it, and it is recorded here rather than
discovered at G1.

## Criterion 1 — can `TextShapingContext` carry HarfBuzz? **PASS**, and the survey understated the answer

`TextShapingContext` carries `language`, `text_direction`, `font_kerning`
and `letter_spacing`. Script is absent but derivable —
`hb_buffer_guess_segment_properties` already does it in `gpu_text.zig`.
Measured through the probe: **saw direction=rtl: YES**, **saw a language
tag: YES** — the plumbing works end to end.

**But the important finding is about what the interface is HANDED, and it
is sharper than the survey said:**

```
  width is asked for   : [A] [ panel] [ laid] [ out] [ by] [ RmlUi,] ...
  GenerateString gets  : [Softanza] [Graphics] [Sound] [GUI] [Panels] ...
```

- **`GenerateString` receives the whole line** (`line.text`, with
  `line.position` as the baseline origin). So **full bidi reorder plus
  shaping is possible at render time.** This is the fact criterion 1
  actually turns on, and it passes.
- **`GetStringWidth` receives TOKENS** — one word at a time, in **logical**
  order, during line building. Line breaks are decided by summing token
  widths.

> **RmlUi does no bidi. At all.** `Direction::Rtl` appears in exactly ONE
> place in 183 files — parsing the `dir` attribute — and is then passed
> through to the font engine as a hint. There is no reorder pass, no run
> splitting, no base-direction resolution.

That is *consistent* with the survey (we supply the font engine), but the
consequence is stronger than "we supply a shaper": **RTL is entirely ours,
including the reordering**, and RmlUi's line breaking will be measuring
logical-order tokens whatever we do. Acceptable — a line's total advance
is essentially order-independent, and Arabic does not join across the
spaces that delimit tokens — but it is a limitation to write into G2's
guard, not to discover there.

Two second-order consequences, recorded now:

- **`GetStringWidth` returns `int`.** Our layout is f64 at 1/64 px.
  Rounding is per token and accumulates across a line. Measure it in G2.
- **Text-overflow ellipsis truncates the line from the end by UTF-8
  codepoint**, so on an RTL line it removes the *logically* last
  characters — which are the visually leftmost. Logically defensible,
  visually surprising, and not grapheme-aware.

## Criterion 2 — layout cost, and does caching make re-layout viable? **PASS, with the number that sizes G2**

| | measured |
|---|---|
| parse + load the document | 0.55 ms |
| first `Update` (full layout) | 0.009 ms |
| first `Render` | 0.040 ms → 6 compiles, 6 draws, 28 verts, 42 indices |
| `Update`, unchanged tree | **0.0006 ms/frame** |
| `Render`, unchanged tree | **0.0023 ms/frame** |
| geometry re-compiles over 500 still frames | **0** |
| `Update` after one property change | **0.235 ms/frame** |
| ratio dirty / still | **362x** |

**The caching is real and it is not subtle**: a still frame costs a
three-hundredth of a dirty one, and 500 still frames re-compile zero
geometry. Re-layout-on-change is viable.

**And the number that actually sizes the font engine:**

> **988 `GetStringWidth` calls per re-layout**, on a four-card screen.
> RmlUi does **not** memoize width queries — every layout re-measures every
> token. With the probe's codepoint-counting stub that is free. **With a
> real HarfBuzz shaper at ~1 µs per token, that alone is ~1 ms per frame,
> before a single glyph is drawn.**

So: **a width cache inside the font engine is not an optimization, it is a
precondition.** G2 ships with one or G2 does not ship. Keyed on (face,
size, bytes, direction, language, kerning, letter-spacing) — every field of
`TextShapingContext` is part of the key, which is a second reason the
struct matters.

## Criterion 3 — is text legible in a texture at an oblique angle? **NOT MEASURED**

Stated plainly rather than assumed: **nothing was rendered.** The probe
counts geometry instead of drawing it, so nothing in G0 touched a texture,
a canvas or a GPU. This criterion needs G1's real render interface and a 3D
scene, and it moves there. **It remains a live kill criterion**, and §2.4's
second door stays open until it is answered.

## What else the probe established, for G1

- **The box tree is inspectable after `Update`** — `GetBox().GetSize()` and
  `GetAbsoluteOffset()` give the laid-out geometry per element, which is
  what a Softanza-side inspector and the court's paint-time audit (§3 of
  `GUI-SYSTEM.md`) will both read.
- **Flexbox flexes**: `#main` went 1044 → 426 px when the viewport went
  1280 → 640.
- `GetBox().GetSize()` is the **content** box, and `width` sets content
  width. A declared `width` on a flex item is a **basis, not a floor** —
  `#side` shrank from 180 to 132 until `flex-shrink: 0` was set. That is
  CSS being correct; it is recorded because the first reading of the probe
  called it a bug.
- **Shutdown is clean**: 6 geometry handles compiled, 6 released.

## The first entries in §3's profile divergence table

Contact with the code produced the first two concrete divergences between
the profile and its two conforming implementations, which is exactly what
§3 exists to hold:

| the profile says | a browser renders | RmlUi needs |
|---|---|---|
| `direction: rtl` | `direction: rtl` | **`--rmlui-direction: rtl`** — RCSS rejects the CSS spelling outright ("Syntax error parsing property declaration") |
| a line break | `<br>` unclosed | **`<br/>`** — RML is XML syntax and will not parse the HTML form |

Neither is a defect. Both are exactly the reason the emitter targets a
named profile rather than an engine.

## What was NOT done in G0

- **No pixels.** Criterion 3 above.
- **No real font engine.** The probe's stub is monospace by codepoint
  count; nothing about HarfBuzz integration was executed — only the
  interface it must satisfy was measured.
- **No Ring face, no DLL, no bridge.** RmlUi is vendored and proven to
  build and run; it is not yet reachable from Softanza.
- **No browser-side fixture.** §3 asked for one document rendered both ways
  in embryo. The RmlUi side exists; the browser side and the comparison do
  not.
- **Windows only.** No cross-compile check was run for the RmlUi TUs.
- **No input, no focus, no accessibility, no data binding** — G3, G4 and
  G5 are untouched, and nothing in G0 says anything about them.

---

# G1 STATUS — 2026-08-13. The render interface, and criterion 3 answered

Guard: `base/test/gui/gui_panel_narrated.ring` — **50 asserts green**. The
device-free scenes are this suite's CI coverage; the 3D scenes gate on a
GPU, exactly as every graphics guard does.

A Ring caller now writes

```ring
oP = new stzPanel(640, 400)
oP.LoadMarkup(cRml)
oP.DrawInto(oCanvas)
```

and gets `ToSVG()` on a machine with no GPU and `ToPNG()` on one with a
device — because the panel never paints. It hands over geometry.

## The shape that was chosen, and why

**The eight pure virtuals are implemented as a RECORDER, not a painter.**
RmlUi hands out vertices and indices; `stz_rmlui.cpp` records them into
one flat buffer and answers with it. GR2b already settled this shape for
the house — one display list, two renderers, so the GPU and SVG tiers
cannot disagree about where anything sits. A UI that painted itself would
be a third renderer outside that discipline. Recording is also what lets
RmlUi's output cross a C ABI at all.

**The display list gained a `mesh` command** (`gpu_scene.zig`). Every
other `Add*` on `stzCanvas` names a SHAPE and lets the engine tessellate;
a UI toolkit arrives having *already* tessellated, and turning its
triangles back into rectangles to hand them forward again would be a lie
about what was drawn. `sceneMesh` takes `x,y,r,g,b,a` per vertex plus
indices and expands into the **existing** shape vertex buffer — no new
shader, no new segment kind, no extra draw call. The SVG tier emits one
`<polygon>` per triangle: exact for flat-coloured UI geometry, an
approximation for a gradient mesh, and said so in the code rather than
discovered from a screenshot.

Indices are range-checked **at the door**, not at draw time: an
out-of-range index would read someone else's memory during tessellation,
on the far side of a C ABI from whoever wrote it.

## Two seam details, paid for rather than assumed

1. **RmlUi's vertex colour is PREMULTIPLIED alpha**; the scene blends with
   straight alpha (`SrcAlpha` / `OneMinusSrcAlpha`). The recorder divides
   it back out. Without that, translucent surfaces render too dark and
   opaque ones look perfect — the worst way for a bug like this to
   present, and the reason the guard checks the channel range as well as
   one exact colour.
2. **`RenderGeometry` carries a per-draw translation**, baked into the
   positions here, because the display list downstream has no per-draw
   transform and should not grow one for this.

## THE DAY THIS COST — and it is the finding worth keeping

> **A `zig build-lib -dynamic` DLL with a Zig root module gets Zig's own
> entry point, which never runs the C CRT startup. C++ STATIC
> CONSTRUCTORS NEVER RUN.**

Measured, not guessed: a global whose constructor sets a flag to 42 still
reads 0 after `LoadLibrary`, and a `DllMain` added for the test was never
called either.

**It does not present as an initialisation problem.** RmlUi initialises
and creates contexts perfectly well without its constructors — it is
built on a `ControlledLifetimeResource` pattern that is deliberately
ctor-independent — and then corrupts the **heap** (`0xC0000374`, raised
inside ntdll) the moment a document is loaded.

Two false trails were followed first, and both are recorded because each
looked right:

- **Walking the `.ctors` list by hand.** lld synthesizes `__CTOR_LIST__`
  (there is no `__CTOR_END__`; the list is null-terminated, and asking for
  one is a link error). The walk works in an isolated 3-TU DLL and
  crashes here.
- **Function-local statics.** They crash *earlier* than file-scope
  globals, because their guard machinery (`__cxa_guard_acquire`) is just
  as absent.

**The fix is one flag, on this domain only:**
`lib.entry = .{ .symbol_name = "DllMainCRTStartup" }` — mingw's real DLL
startup, constructors included.

Verified by an isolated build outside the repo: the same sources linked
with `zig c++ -shared` (which uses that entry by default) work;
`build-lib` without the flag does not; `build-lib` with it does.

`build.zig` already carried a note about hitting this from the other side
with ggml — that attempt went for the MSVC ABI so constructors would land
in `.CRT$XCU`, and was blocked by a Zig 0.15.2 libc++abi bug. It is now
recorded from the front as well. Our own C++ objects are still constructed
**explicitly**, behind POD pointers, as belt and braces: if the flag is
ever lost, this file keeps working instead of corrupting a heap three
layers down.

**This is a house-wide property, not a GUI one.** Any future DLL here that
vendors C++ with meaningful static initialization needs the same flag.

## KILL CRITERION 3 — answered: **PASS**, and the answer is better than expected

G0 deferred it because nothing was rendered there. It is a question about
*this house's* rasterization and sampling, not about RmlUi, so it is asked
directly: text from the plane's own SheenBidi → HarfBuzz → stb_truetype
pipeline, drawn into a canvas, uploaded as a `LINEAR`-sampled texture, and
mapped onto a quad in a 3D scene at four elevations.

**The metric, and why it is this one.** The obvious measure — count the
lit pixels — falls with the angle for a reason that has nothing to do with
legibility: the quad covers less screen. So the measure is the *shape* of
the luminance distribution over the pixels the quad **does** cover. Blur
moves pixels out of the ink bucket into the smear between ink and paper;
shrinking does not.

| elevation | covered px | ink | smear |
|---|---|---|---|
| 89° (face-on) | 198,346 | 12‰ | 9‰ |
| 45° | 152,280 | 11‰ | 8‰ |
| 20° | 78,486 | 11‰ | 7‰ |
| 12° (hard graze) | 48,420 | 11‰ | 7‰ |

> **The distribution barely moves. What an oblique angle costs is SIZE,
> not sharpness** — coverage falls 4x while the ink and smear fractions
> stay within a tenth of face-on.

The negative sibling that stops this being a tautology: **coverage falls
steeply and monotonically**, which is what proves the four renders really
are four different angles rather than the same picture measured four
times.

**One honest limit on that result.** The texture is 512×256 rendered into
480×480, so the texel-to-pixel ratio never becomes extreme. **There are no
mipmaps in the texture path** — the kinds are render-target, sampled
NEAREST and sampled LINEAR, and nothing generates a mip chain. A grazing
angle with a much larger texture or a much smaller on-screen quad is
minification this measurement did not reach, and it is untested.

A second honest note: the material transpiler linearises on entry and
encodes on the way out, so the texture's dark "paper" renders as mid-grey.
The first version of this scene used absolute thresholds against the
colour as *drawn* and reported the same wrong number at every angle. The
thresholds now come from a measured histogram.

## Three more entries for §3's profile divergence table

Contact with the code again produced the most valuable output. The table
now reads:

| the profile says | a browser renders | RmlUi needs |
|---|---|---|
| `direction: rtl` | `direction: rtl` | **`--rmlui-direction: rtl`** — RCSS rejects the CSS spelling outright |
| a line break | `<br>` unclosed | **`<br/>`** — RML is XML syntax |
| the root fills the viewport | `body` fills it | **`width: 100%`** — RmlUi's `body` shrinks to content otherwise |
| `div` is a block | `display: block` by default | **`display` must be declared** — RmlUi defaults every element to `inline`, and width/height correctly do not apply to a non-replaced inline box |

**The last one is the largest, and it is asserted both ways in the
guard**: the same markup that collapses to 0×0 under a block parent lays
out to 50×20 the moment `display: block` is declared on the element. In a
browser the first version works. **The emitter must declare `display` on
every box it emits.**

## And one correction to the survey

> **RmlUi's document loader is LENIENT.** An unclosed `<br>` is a real
> parse error — the log says *"Closing tag 'body' mismatched … was
> expecting 'br'"* — but `LoadDocumentFromMemory` **still returns a
> document**, partially built, and the status is OK.

The survey's phrasing ("unclosed `<br>` and `<img>` will not parse")
implied a refusal. There is none. So an emitter bug produces a broken
screen **silently**, and this plane must read `LastEngineMessage()` rather
than trust a status code. That is a G5 obligation, recorded now.

## What G1 did NOT do

- **No text in a panel.** The font engine is still the monospace stub, so
  a panel has chrome and no glyphs. That is the honest state of the phase,
  not a defect — G2 is the font engine. The guard asserts the stub was
  never asked to draw, so the day it *is* asked, the number moves.
- **No textures and no clipping.** Both are COUNTED rather than skipped
  silently (`droppedTexturedDraws`, `ignoredScissors`), and both read zero
  on a document that needs neither. A nonzero reading is precisely what G2
  turns on.
- **No input, no focus, no events.** G3.
- **`PushLayer` / `CompositeLayers` / `SaveLayerAsTexture` are untouched.**
  The phase's brief named them for the in-scene case; the in-scene case
  was proven instead by rendering the panel's canvas to a texture and
  mapping it, which needs none of them. They arrive when a filter or an
  effect asks for them.
- **Windows only.** No cross-compile check was run for stz_gui.
- **Layout cost was not re-measured here.** G0's numbers (a still frame at
  1/362 of a dirty one, zero geometry re-compiles over 500 frames) stand
  unchallenged but were not repeated through the Ring face.

---

# G2 STATUS — 2026-08-14. The font engine: RmlUi lays out with the glyphs it will be painted with

Guard `base/test/gui/gui_font_narrated.ring` — **30 asserts green**, no
GPU, on the committed Amiri fixture so CI shapes real Arabic with no
system font. Sweep after the change: panel 50, adversarial 32, stzui 42,
font 30 — all green.

## The architecture, and why it is not a second renderer

The plane's own rule (§1) is that it must not grow a renderer, and G0's
measurement said the font engine needs a width cache to exist at all. Both
are satisfied by one decision:

> **The same `gpu_text.zig` is compiled into BOTH DLLs.** `stz_gui.dll`
> measures with it; `stz_gpu.dll` paints with it. Two copies of one source
> over one font file cannot disagree — a protocol between two DLLs could.

`needs_textshape` and `needs_stb` were added to the `stz_gui` domain, and
`src/gui_font.zig` exports three entries over a C ABI (`load`, `metrics`,
`width`) for the C++ font engine. There are **no cross-DLL calls**: each
DLL holds its own font table over the same bytes, which the Ring face
guarantees by handing the identical buffer to both (`stzPanel.UseFont`).

**Text crosses the C ABI as COMMANDS, not quads** — font, size, baseline,
colour, bytes. So this plane still owns no glyph atlas, no textured vertex
format and no rasterizer, and the canvas paints strings through the same
scene-text machinery every other graphics face uses. Both tiers come free:
SVG gets glyph outlines, the GPU tier gets the atlas.

## The seam agrees — the assertion this phase exists for

| string | RmlUi laid out | the shaper says | delta |
|---|---|---|---|
| `Hamburgefonstiv` | 164 | 163.59 | 0.41 |
| `iii` | 19 | 18.94 | 0.06 |
| `WWW` | 63 | 63.23 | 0.23 |
| `سوفتانزا` | 59 | 58.59 | 0.40 |

Agreement is **to the integer and no further**, which is G0's recorded
cost of `GetStringWidth` returning `int` against a 1/64-px `f64`. The
guard asserts `delta < 1.0` *and* `delta > 0` — "equal" would be a lie
that passes.

And it is really shaping, not counting: **`iii` is 19 px and `WWW` is
63 px**, where the G1 stub gave both 36. Arabic joins — the same eight
letters measure **59 px joined and 163 px apart**.

## The width cache — the precondition, measured

G0 made this a gate: 988 unmemoized `GetStringWidth` calls per re-layout,
~1 ms/frame at real shaping cost before a glyph is drawn.

> **21 layouts: RmlUi asked 675 times, the shaper ran 26 times** — 649
> cache hits, and `shapeCalls` did not move at all across the 20
> re-layouts while `widthCalls` grew every time.

The key carries everything that changes a width (face, size, direction,
letter-spacing, bytes); the scratch key buffer is reused so 988 lookups a
frame allocate nothing. `Counters()` grew two fields — `widthCacheHits`
and `shapeCalls`, appended never reordered — so the gauge is readable
rather than asserted once and forgotten. **If those two ever converge, the
precondition has silently lapsed.**

## The finding that shaped the design: text must ride RmlUi's cache

The first implementation recorded a text command inside `GenerateString`,
which is the obvious place. It produced text on the first frame and
**nothing on every frame after** — because RmlUi calls `GenerateString`
only when the text is *dirty* and replays the compiled geometry forever
after. G0 had already measured that (500 still frames, zero recompiles)
and the consequence still had to be paid for.

So a string is emitted as a real 4-vertex quad — its own box, so culling
and sizing behave — with the bank index hidden in the first vertex's
texture coordinate behind a marker no real UV can reach (`987654.0`).
`CompileGeometry` recognises it, `RenderGeometry` replays it **with that
frame's translation** (which is what makes a scrolled label land
correctly without re-shaping), and `ReleaseGeometry` frees the bank slot.
The command therefore lives exactly as long as the string is on screen.
Asserted directly: three renders of an unchanged panel keep every command,
with the same bytes and the same baseline.

## What this deleted

The G1 bridge — walk `TextsToPaint()`, look up `BoxOf()`, guess a
baseline, paint with a separate font — **is gone**, and with it the chance
of painting a label somewhere the layout did not put it. The `.stzui`
showcase's paint function is now three lines: clear, background,
`DrawInto`. `stzUiDocument.UseFont()` binds the face *before* `ToPanel()`
loads the markup, because RmlUi measures during load: a font registered
afterwards would lay the document out on stub widths and then paint it
with real glyphs, which is precisely the mismatch this phase forbids.

## Two facts recorded from contact

- **Font families are process-wide**, not per-panel — RmlUi keeps faces in
  its own global registry and so does this engine. A family registered by
  any panel is visible to every other one, and a test cannot get the stub
  back once anything has registered a font. Asserted rather than
  discovered.
- **An unknown family falls back to any registered face.** The
  alternative is the G1 divergence — text that silently vanishes — and
  one screenshot was enough to pay for that lesson.

## What G2 did NOT do

- **No fallback CHAIN.** One face answers everything; a document mixing
  Latin and CJK gets tofu for whatever the face lacks. Real fallback needs
  a per-codepoint face walk, and it belongs with the font *policy* work,
  not here.
- **No font effects.** `PrepareFontEffects` is unimplemented, so shadows,
  outlines and glows declared in RCSS do nothing.
- **No bold or italic synthesis**, and no weight/style selection: a family
  is one face. `Style::FontWeight` and `FontStyle` are accepted and
  ignored.
- **No `has_ellipsis`**, so RCSS `text-overflow` cannot use the real
  ellipsis glyph.
- **Underline metrics are derived, not read** from the face's `post`
  table — position is half the descender, thickness is size/14.
- **The layout is still single-line per string.** RmlUi does the line
  breaking and hands each line down separately; the engine's own layout
  contract has not changed.
- **No IME.** §0 made it possible; nothing here makes it cheap.

---

# RTL AND THE VARIED-SCREEN PASS — 2026-08-14

Undertaken between G2 and G3, on the observation that **every visual
defect this plane has had was found by looking at a picture, never by an
assertion**: the flex-shrink collapse that zeroed the bar and footer, the
`SetFont`-before-`AddText` ordering that made every label one size behind,
the content-box sidebar. Three from one screenshot. This pass rendered a
second and third kind of screen and found two more, one of them a real
engine defect that five green guards had not noticed.

## What §2.3 actually required, measured

`--rmlui-direction` appears in **exactly one line** of RmlUi's layout — a
dirty flag in `ElementText` that feeds `TextShapingContext`. It aligns
nothing, reverses nothing, moves no box. And RCSS `text-align` takes only
`left, right, center, justify`, with no direction-relative `start`/`end`.

So the plan's promise — *"RTL is a parameter threaded through the layout
protocol, not a feature added later"* — is entirely the emitter's to keep.
It now keeps it: **one `TEXT_DIRECTION rtl` on the panel flips the
screen.** Direction inherits down the tree, a subtree may override it (a
Latin code block inside an Arabic page) and the override inherits in turn;
`TEXT_ALIGN start`/`end` resolve per element against the direction in
force; and a `DIRECTION row` becomes `row-reverse`, so a sidebar declared
first sits on the right of an Arabic screen. Guard
`gui_rtl_narrated.ring`, **33 asserts green**, and the fix exists because
a screenshot showed left-aligned Arabic while every assertion passed.

`.stzui` gains **`TEXT_ALIGN`** (`start | center | end | justify`) on
PANEL, BOX, TEXT and STYLE. `DirectionOf()`/`IsRtl()` answer before
anything renders — they were a side effect of `ToRml` at first, which
made them return `ltr` until something had been emitted.

## The defect the pass existed to find

**Registering one font family twice freed the font id that live faces
still pointed at.** The gen-keyed table then answered `-1` to every width
query, the text quads came out zero-wide, RmlUi culled them, and the panel
that had been built FIRST silently lost its text. No counter moved; no
exception was raised.

It needed **two panels sharing a font family** to appear — which is why
every single-panel guard was green while a two-panel screen was losing
lines. Registration is now idempotent per family, which makes a dangling
id structurally impossible; swapping a face at runtime needs a new family
name, and that is said out loud rather than discovered.

**The invariant is now a number**: `textMeshes` must equal
`generateCalls`, exposed as `TextIsWhole()` and asserted in three guards.
A string that is measured and then produces no geometry is text vanishing
silently, and that is exactly what it counts.

## And a guard defect worth recording

The assertion that should have caught the missing line was
`x < 4` on a helper that answers **-1 when the string is absent** — so a
vanished string read as one aligned to the left edge and **passed**. This
is the house's own assertions-that-agree-by-coincidence rule, live: every
caller now checks for the absence before comparing the position.

## Two Ring traps, rediscovered

`oR` is the `or` KEYWORD (comparisons are case-insensitive) and `cR` is
the `CR` global — nine syntax errors between them. And a bare `Doc()`
helper collided with an existing stzlib global. Two-letter locals in
guards are a minefield; `CLAUDE.md` says so and this pass paid for it
again.

## Tier agreement — CHECKED, and it holds

`gui_tier_agreement_narrated.ring`, **24 asserts green**. The house has
said since GR2b that a picture is described once and rendered twice "so
the two backends cannot disagree about where anything sits", and §3 rests
on the same idea one level up. Nothing had ever checked it: both tiers
were exercised separately, every guard passed, and no test had put the
SVG and the pixels side by side. It was an argument, not a result.

The observables are stated rather than assumed, because geometry and a
pixel grid cannot be compared byte for byte: **each box's bounding
rectangle, its colour, and the presence and position of text.** Three
bands in unmistakable colours are reduced to a bounding box from the SVG
polygons and to a bounding box from the rasterized pixels, and compared.

    band    vector tier         raster tier
    red     [0, 0, 400, 60]     [0, 0, 400, 60]
    green   [0, 60, 400, 140]   [0, 60, 400, 140]
    blue    [0, 140, 400, 190]  [0, 140, 400, 190]

**They agree to the pixel**, with one pixel of stated slack for the f64
edge against the whole-pixel grid. Two negative siblings keep it honest:
a colour the document never used must be found in neither tier, and the
three bands must be genuinely different rectangles — otherwise "they
agree" would be trivially true of any three identical boxes.

## Still owed from the pass
- **The browser fixture** (§3), still owed from G0.
- **A panel inside a 3D scene** — §6 says this plane starts with that
  tier; criterion 3 used a canvas texture, not a panel.

---

# G3 STATUS — 2026-08-14. Input, events and focus: a form you can operate with a keyboard

Guard `base/test/gui/gui_input_narrated.ring` — **38 asserts green**, no
GPU. Live: `gui_form_window.ring` (mouse, Tab/Shift+Tab, arrows, Enter,
a visible focus ring), or `shot` for `gui_form.png`. Sweep after the
phase: panel 50, adversarial 32, stzui 43, font 30, rtl 37, tier 24,
input 38 — **254 all green**.

## The plan under-credited RmlUi, and that changed the phase

G3 was written as *"build a routed event model, a sparse focus tree, and
traversal policies"*. Measured, RmlUi already ships: full input
processing (mouse, keyboard, text, wheel, touch), focus with
`Focus`/`Blur`, **tab order in document order**, and **spatial
navigation by heuristic** for directional moves. What it does not ship is
a queryable ring, counted refusals, and any notion of where an input came
from.

So the phase became: **expose it, decide its shape at the seam, and add
the three missing things.** That is a smaller phase than the plan
budgeted and a better outcome than building a parallel model beside a
working one.

## The two shape decisions

**Events are DRAINED, never dispatched.** Ring cannot be re-entered
safely from inside a C++ event dispatch, so one listener on the document
root — subscribed to a closed set of nine event types, in the bubble
phase, after RmlUi has already routed — writes each event down, and
`Events()` hands over the list. The house had already settled this shape
twice (the display list, the text commands), and the Ringine charter's
*no per-entity callback, ever* is the same rule in another plane.

**Every input verb takes PANEL PIXELS**, which is §7's coordinate-space
frame **dissolved rather than surfaced**: a panel admits exactly one
space, so there is nothing to confuse it with, and the two conversions
are named functions at the boundary — `FromWindow(oWin, x, y)` and
`FromTexture(u, v)`. The second one *is* the whole in-scene input story
(§6's tier): a ray hits a quad, the caller has a uv, the panel takes
pixels, and nothing about the panel knows it is in a scene. `v` is
flipped in exactly one place, because a texture's origin is bottom-left
and a panel's is top-left.

## Rule 80, asserted as a property of the RUN

`FOCUSABLE yes` on a box puts it in the ring. `TabRing()` walks the whole
cycle and answers the stops in order, so *"can a keyboard reach every
action"* is a question about the run rather than about the markup — the
form's ring is `row_one → row_two → confirm → cancel`, and the guard
asserts both the act **and the way back** are in it, since the rule
requires both. The negative siblings matter as much: the title, the row
that merely *contains* the buttons, and a label inside a field are all
absent, or the ring would be a list of everything and prove nothing.

**A ring is a CYCLE and it wraps** — Tab from the last stop returns to
the first, because a ring that refused at the end would strand a keyboard
user at the bottom of every screen. Recorded with it: `TabRing()` enters
the cycle wherever focus currently sits, because RmlUi resumes tabbing
from the last focused element even after a blur. The set and the order
are stable; the entry point is not.

## The finding that changed the format

**`nav-up/right/down/left` default to `none`, so arrow keys do nothing at
all until they are set.** `tab-index: auto` is likewise the opt-in
despite reading like a default. An author who declares a thing focusable
means both — the WAI-ARIA APG contract this plane adopted is *one tab
stop per composite, arrows within* — so `FOCUSABLE yes` now emits
`tab-index: auto; nav: auto;`. Half that contract silently absent is
exactly the gap Rule 80 exists to forbid, and it would have shipped
looking correct.

## The input source, and why it is on the event

§7 chose to surface this frame and it carries on the event, because the
answer differs per event. It earns its place twice: Rule 80 makes
*"reachable by a human keyboard"* materially different from *"something
dispatched a click"*, and G4 needs an assistive activation
distinguishable from a pointer one. The live form stamps **synthetic** on
Enter-to-activate deliberately — a dispatched activation that could not
be told from a real pointer one would make the keyboard guard
unfalsifiable.

## The bounded record

The queue holds 4096 events and **counts what it drops**: 1600 undrained
clicks produce the ceiling and a nonzero drop count, so a caller that
stopped draining can see why it stopped receiving. Asserted with its
negative sibling — an empty queue reports zero drops.

## What G3 did NOT do

- **No text editing.** RmlUi's `ProcessTextInput` is wired and text
  events are recorded, but there is no text field in the format, no
  caret, no selection and no clipboard. The §0 gate's `caretRect` still
  has no consumer.
- **No IME**, and nothing here moves it. `ActivateKeyboard` is recorded
  when RmlUi fires it and fed to nothing.
- **No gamepad or touch.** The source enum names them; no verb produces
  them, and `ProcessTouch*` is unexposed.
- **No composite widgets.** A "composite" is currently any box the author
  marks focusable; there is no listbox, no tabset, no menu, and so no
  place where the APG's *one stop per composite* is enforced rather than
  merely possible. That is G5's vocabulary.
- **No focus TRAP**, so a modal cannot yet hold focus inside itself.
- **No hover styling.** `:hover` is not in the profile, so a pointer over
  a button changes nothing visually — the events fire, the paint does
  not.
- **Enter does not activate by itself.** The live form dispatches a
  synthetic click because RmlUi does not activate a plain `div` on
  Enter; a real widget vocabulary would.

---

# G4 · THE CONTRADICTION INSIDE THIS PLAN — surfaced 2026-08-14, before any G4 code

> **THIS MEASUREMENT WAS WRONG, AND THE CONTRADICTION IT NAMED DOES NOT
> EXIST.** See *"G4b RESOLVED"* at the foot of this file. The section is
> left standing because the reasoning below is still the reasoning that
> would apply IF the premise held, and because a plan that deletes its
> own mistakes cannot be checked against them. Read it as a record of a
> question, not of a fact.

**Measured first, as the phase gate requires.** AccessKit publishes
**60 releases and not one binary asset**: `accesskit_c` exists, but it is
a crate, and using it means **cargo as a hard build dependency of this
engine**.

That collides with §2.1 of this document, which gave up **CSS Grid** —
"the design language of every screen Softanza will ever ship" — on this
exact reasoning:

> *"Flexbox-only forever — permissive, vendorable, pure C/C++ — or CSS
> Grid, which costs either **a Rust toolchain as a hard build
> dependency** or a proprietary licence… Choosing it keeps the entire
> native stack permissive C/C++ with no Rust in the build."*

And §10 forbids the other road just as plainly: *"Do not implement
platform accessibility bridges by hand. That is the 3.47 MB mistake."*

So the plan says **no Rust**, **no hand-written bridges**, and **adopt a
Rust library**. Two of those three can hold. This is the contradiction
the working discipline asks a session to surface rather than resolve
quietly, because resolving it changes a standing decision.

## What follows, stated so the choice is made on consequences

**If cargo is adopted**, §2.1's *reasoning* is spent — and CSS Grid
becomes reconsiderable, because the plane cannot pay the Rust cost and
still refuse grid *on the grounds of the Rust cost*. That is not an
argument against adopting cargo; it is the honest price list. Taffy
would then be available and §2.1 would need rewriting rather than
merely amending.

**If cargo is refused**, the adapters are hand-written per platform,
which is the measured 3.47 MB mistake, or accessibility is native-only
by some other route, or it waits.

**Neither is this session's call.** It changes a decision the plan made
deliberately and recorded with reasons, and §2.4's discipline — name the
conditions, decide on evidence — applies to a standing decision at least
as much as to an engine choice.

## What is NOT blocked by it, and is therefore what G4 builds now

The survey's own accounting says the adapter is **half** of
accessibility:

> *"The semantics tree — merging, dirty tracking, stable IDs, traversal
> order, text segmentation — is comparable in size again and **is the
> part no library removes**."*

AccessKit's adapters are 3,763 lines (Windows), 2,590 (macOS), 2,403
(Android), 2,499 (iOS), 801 (Unix). The **tree** is ours in every
scenario — with AccessKit, with a hand-written UIA bridge, with a web
mirror DOM, or with nothing at all. It is a precondition of all four and
wasted work in none.

It is also the half where this plane is **better than a browser**, which
is §5 of `GUI-SYSTEM.md`'s one genuinely optimistic finding: a browser
*infers* an accessibility tree from markup; Softanza can **emit** one
from declared intent, which is strictly better information. `.stzui`
already carries the seed — the commons' mandatory `RATIONALE` on every
declaration is a sentence per region saying why it exists, which is
precisely what a description field wants and what no HTML document has.

**So G4 splits**: **G4a — the tree**, built now and offline-testable;
**G4b — the adapter**, blocked on the decision above and not started.

---

# G4a STATUS — 2026-08-14. The accessibility tree: emitted, not inferred

Guard `base/test/gui/gui_accessibility_narrated.ring` — **37 asserts
green**, no GPU, no font, no device. Sweep: panel 50, adversarial 32,
stzui 43, font 30, rtl 37, tier 24, input 38, accessibility 37 —
**291 all green**.

**G4b, the platform adapter, is NOT started** and is blocked on the
decision recorded above. Everything here is required whichever way that
goes.

## What the format gave, without being asked

The tree is `base/gui/stzAccessibilityTree.ring`, built from a
`.stzui` document plus a laid-out panel. Three of its fields cost
nothing because the format already carried them:

| the node needs | the format already had |
|---|---|
| **stable ids** — the survey lists this as part of the hard half | a declaration's NAME, stable by construction |
| **a description per region** | **`RATIONALE`**, which the Grammar Commons made mandatory for its own reasons and which turns out to be exactly a sentence saying why a region exists — something no HTML document has |
| **bounds** | the laid-out box, queryable since G1 |

`ROLE` (closed vocabulary, 19 names all of which exist in ARIA and in
AccessKit's 182-role schema) and `LABEL` were added to `.stzui`. **A role
is not a meaning** and this plane still computes none — it decides no
colour, no emphasis, no refusal, and there is still no `:Danger` here.
It is the accessibility projection's own term, in the same family as
`display: block`, and it is what lets Softanza *emit* a tree where a
browser can only *infer* one.

## Two real defects the first tree had, both invisible to a count

**A focusable button announced as "group" with no name.** A screen-reader
user tabbing to Confirm would have heard "group". The fix is ARIA's own
name-from-content rule, and the guard now asserts the law rather than the
shape: **every focusable node has a role and a name**, with the negative
sibling that an unnamed focusable in a different document *is* caught.

**Then name-from-content was over-applied**, so the window announced the
entire screen as its name and a plain grouping row announced "Confirm
Cancel". ARIA gates that rule by role and so does this now: button, link,
heading, label, listitem, tab, checkbox, radio take their name from
content; window, group, textbox and the rest do not. A textbox is absent
deliberately — its content is its **value**, and a reader announcing the
value as the name is a classic form-field defect.

Both were found by reading what the tree would *say*, in order, out loud
— which is the accessibility equivalent of looking at the picture, and it
found two defects the same way the gallery did.

## The laws the guard asserts

- **Every focusable node has a role and a name.** Not a preference: a
  focusable thing a reader cannot announce is the failure Rule 60
  forbids, checkable here instead of in a manual audit.
- **The reading order and the keyboard order agree** — the same four
  stops in the tree and in the tab ring. If they drift, a screen-reader
  user and a keyboard user are operating different screens.
- **Every node has a description**, because every declaration must.
- **Unknown bounds are `null`, never a zero rectangle** — a magnifier
  told a thing is at 0,0 goes there.
- **The tree is DATA** (JSON), which is Rule 104's requirement: *what a
  screen reader can operate, an agent can operate*. A tree only a C++
  adapter can read serves the first and not the second.
- **An unclean document is refused, not described.**

## The survey's two structural warnings, answered

**"Every toolkit gates accessibility behind a performance flag, which is
where users silently get nothing."** There is no flag. A tree is built on
demand from data that already exists, so there is nothing to gate and
nothing to forget to switch on — asserted by building one with no panel,
no font and no device.

**"Virtualised lists are the universal failure mode in every custom
renderer examined."** Not answered, because nothing is virtualised yet:
every declared box exists and every one becomes a node. The warning is
recorded against the day a list becomes lazy, which is the day it
becomes a defect.

## What G4a did NOT do

- **No platform adapter.** Nothing reaches UI Automation, NSAccessibility
  or AT-SPI. Nothing is announced by a real screen reader; the tree is
  correct as data and untested against an actual AT.
- **No live updates.** A tree is a snapshot built on demand. There is no
  dirty tracking, no incremental push, and no notion of "the tree
  changed" — which is exactly the merging-and-dirty-tracking half the
  survey warned about, and it is deferred rather than done.
- **No rich text.** AccessKit does not have it either; a paragraph is one
  node with a name, with no runs, no offsets, and no relation to the §0
  gate's `rectsForRange` — which still has no consumer.
- **No relations**: no labelled-by, described-by, controls, or owns. The
  `LABEL` field is a string, not a reference to another node.
- **No live regions**, so `status` is a role here and announces nothing
  when it changes.
- **No hit-testing entry point for AT** — a screen reader's
  "what is at this point" is `ElementAt`, but nothing maps it to a node
  yet.

---

# §6 STATUS — 2026-08-15. The in-scene panel: the tier this plane was supposed to START with

Guard `base/test/gui/gui_scene_narrated.ring` — **43 asserts green**.
Sweep: panel 50, adversarial 32, stzui 43, font 30, rtl 37, tier 24,
input 38, accessibility 37, scene 43 — **334 all green**. Graphics
guards re-run because the engine changed: gg4_multipass, gg4_framegraph,
gg5_material_language all green.

`base/gui/stzScenePanel.ring`, `base/test/gui/console.stzui`,
`base/test/gui/gui_scene_demo.ring` (four PNGs).

## It was deferred three times, and the deferral cost something

§6 says this plane starts here — "the graphics plane's strengths are
highest, RmlUi is proven, in-world panels are routine". It then didn't:
G1 rendered no scene, G1's criterion 3 grazed a HAND-DRAWN canvas rather
than a panel, and G3 built `FromTexture` and rehearsed it **without a
scene**. Standing the tier up found **four defects in one afternoon**,
two of them in code that had been green for days.

## The whole class is two conversions, and only one was at risk

    OUT   panel -> canvas -> pixels -> a GPU texture -> a quad's material
    IN    a screen point -> a ray -> the quad's plane -> uv -> panel pixels

The OUT direction was routine, exactly as §6 predicted. **Every defect
was in the IN direction**, and every one of them is silent: a mis-mapped
click lands on the wrong button, which looks like a working program
doing something else.

The engine exposes no unproject, so the ray is built from the camera
basis by hand. Against it stands the engine's OWN `Project()`, which
shares no code with it: a uv mapped out to a world point, projected to
the screen by the engine, then mapped back by the ray, must return the
uv it began with. That is the class's `VerifyAgainstProjection()`, and
it is the house's rule for a check that can actually fail rather than an
identity computed from one set of anchors.

## The four defects

**1. Two self-checks that agreed by construction.** The first round trip
passed at 0.000000 — and so did both negative controls. Ring copies an
object on assignment, so the scene held as `@oScene` was a SNAPSHOT:
moving the camera changed nothing the panel could see, and BOTH the
ray's camera and `Project()`'s camera were the same stale copy, agreeing
with each other while agreeing with nothing real. This is the
engine-wrapper copy law arriving in a plane with no engine handle to
hide behind. The camera is now DATA, and the sync is a verb a game loop
calls beside `Refresh()`:

    oSP.LooksThrough(oScene)     # the camera moved
    oSP.Refresh()                # the interface changed

A stale mapping is a missing call rather than an invisible fork, and
`CameraInUse()` lets a caller SEE the snapshot instead of inferring it
from a wrong answer. The negative control is now genuine — point the ray
through one camera and `Project()` through another, and the error goes
to 0.19.

**2. The uv direction was guessed, not read.** `buildPlane` gives the
corner at (-h,+h) the uv (0,1), so v grows with +z; the first draft had
it backwards. It was invisible to the round trip — that check maps uv
out and back through the SAME convention, so it cannot see a convention
error. **The corner assertions caught it**, because they check against
the mesh rather than against the class.

**3. A corner is a miss.** Floating point puts the quad's own corner at
u=1.0000000001, and a strict bound made it a miss. The bound is tolerant
by a hair and the answer is clamped.

**4. THE COLOURS WERE ALL WRONG, and only the picture said so.**
`gpu_wgsl.zig` deliberately does not linearise a `sample()`: it recorded
that "texture colour space is a FORMAT decision (an sRGB texture view
lets the sampler do it) and is its own measurement, not this one."
**That measurement came due here** — the first consumer whose texels are
a picture of colours rather than data. A canvas hands over sRGB-encoded
bytes, the shader treated them as linear, and the fragment tail encoded
to sRGB a second time. A near-black `#0d1219` background rendered as mid
slate; every colour in the interface was pale.

Fixed engine-first, as `TEX_SRGB` (kind 4) in `gpu.zig` + `samplerFor`
in `gpu_render.zig`: an sRGB texture view, so the SAMPLER decodes.
`TEX_LINEAR` is untouched, because a texture holding DATA — a height
field, a mask, a lookup — must not be gamma-decoded. **The distinction
is what the texels MEAN, which is why it is a kind and not a flag.**

## The running count, updated

Across this plane, **defects found by looking at pictures: 6.** By
reading a tree aloud: 2. **By assertions written before the fact: still
0.** Every guard here was written after the picture showed the problem.
That is not an argument against the guards — they hold the fix — but it
is now a measured property of this plane rather than an impression.

## What criterion 3 looks like on a real interface

G1 answered criterion 3 with a hand-drawn canvas. Re-run on an actual
declared console at a hard graze (`gui_scene_3_graze.png`): the text is
smaller and still legible, edges stay sharp, no mipmaps exist. **An
oblique angle costs SIZE, not sharpness** — the same verdict, now on the
thing it was a proxy for.

## What this did NOT do

- **No window.** The four frames are rendered to PNG. Driving a live
  camera from a mouse in a real window is the swapchain path GR5 already
  built, and it is not wired to this yet.
- **No per-instance material**, so a scene may hold ONE panel. The
  graphics plane's own note says per-instance materials are a different
  phase, not a bigger version of this one.
- **The quad is at the origin, in XZ, facing +Y.** A panel on a wall, or
  on a moving object, needs the ray in the quad's local space — a model
  transform this class does not take.
- **No depth ordering against the interface**: a panel is a surface in
  the scene like any other, and nothing here says what happens when
  something occludes it. A ray that passes through a wall still clicks.

---

# G4b RESOLVED — 2026-08-15. The contradiction was a measurement error, not a conflict

**I measured the wrong repository.** `AccessKit/accesskit` is the Rust
monorepo and it does publish 60 releases with no binary assets — that
part was true. But the C bindings are **a separate repository**,
`AccessKit/accesskit-c`, and it ships **official prebuilt binaries for
fifteen targets**:

    macOS arm64 / x86_64        Windows x86_64 / arm64 / x86  (msvc)
    iOS + simulator             Windows x86_64 / x86          (mingw)
    Linux x86_64 / x86          Android arm64-v8a / x86_64

Latest `0.22.3`, released 2026-07-14 — one asset,
`accesskit-c-0.22.3.zip`, 64.5 MB for all fifteen. Built in CI by
`.github/workflows/publish.yml` on a pinned stable toolchain, packaged
with the cbindgen-generated `include/accesskit.h`. The mingw targets
matter: Zig's default Windows ABI is the gnu one, so there is no ABI
gamble.

**No cargo enters this build.** The header declares 436 entry points,
and all three platform adapters are present with one uniform shape —
`accesskit_windows_subclassing_adapter_new`,
`accesskit_macos_subclassing_adapter_for_window`,
`accesskit_unix_adapter_new`, each with `_update_if_active`,
`_update_window_focus_state`, `_free`. The *subclassing* variants attach
to a window that already exists, which is exactly the shape GR5's
`stz_window.dll` presents.

## The rule the house was ACTUALLY following, which is better than the one written down

§2.1 refused CSS Grid on the ground of *"no Rust in the build"*. **The
repository already contradicts that sentence**: `engine/vendor/wgpu/` is
wgpu-native — Rust — vendored as a 9 MB prebuilt DLL plus its import
library and header, under a `VERSION` file carrying the upstream tag,
the release asset name, the git commit and two SHA-256 checksums. Every
triangle this library draws goes through Rust. It has since GR0.

So the rule that is genuinely load-bearing is not about a language:

> **A dependency may be written in any language, provided it presents a
> stable C ABI AND ships official prebuilt binaries — so that no foreign
> toolchain ever enters our build.**

That is testable, and it sorts the three candidates cleanly:

| candidate | C ABI | official prebuilts | verdict |
|---|---|---|---|
| **wgpu-native** | yes (webgpu.h) | yes | already vendored, since GR0 |
| **accesskit-c** | yes (cbindgen) | **yes, 15 targets** | **PASSES — adopt** |
| **Taffy** (CSS Grid) | no official bindings | **0 assets, all releases** | **FAILS — grid stays refused** |

## §2.1 is not spent. Its conclusion survives on a better reason

The previous session's price list said adopting AccessKit would spend
§2.1's reasoning and make CSS Grid reconsiderable. **It does not.** Taffy
fails the prebuilt test that wgpu and accesskit-c both pass, so grid
would still mean a cargo toolchain in the build while accessibility does
not. §2.1's *conclusion* stands unchanged; only its *stated reason* was
too coarse — and it was already false when written, because the GPU tier
had disproved it a plane earlier.

**§10 is untouched.** It forbids hand-writing platform bridges, and
nothing here does.

## The options that lost, recorded so they are not re-litigated

- **Hand-written UIA provider in Zig.** Feasible for Windows — the
  provider COM surface for a static tree is small — but it is Windows
  only, macOS needs the Objective-C runtime, and **Linux AT-SPI is
  D-Bus**, which is where a hand-written bridge stops being a weekend.
  This is §10's 3.47 MB mistake, and it is now also the *more expensive*
  road, not merely the forbidden one.
- **Build accesskit-c ourselves and vendor the artifact.** Was the plan
  when the premise was that no prebuilt existed. Unnecessary now, and
  strictly worse: our artifact would not be reproducible by a third
  party, where upstream's is.
- **Out-of-process adapter reading the JSON tree.** Attractive under Rule
  104 and it stays useful for AGENTS, but it cannot serve a screen
  reader: a UIA provider must answer `WM_GETOBJECT` on the window's own
  handle, so in-process code is required regardless.
- **Defer G4b indefinitely.** Rejected as a *reason* — but see the gate
  below, where the sequencing argument turns out to be real even though
  the dependency argument was not.

## THE REAL GATE, which the false contradiction was hiding

G4b is not blocked by Rust. It is blocked by **this plane having no
window.** Every platform adapter attaches to an HWND, an NSWindow or an
AT-SPI application object. The GUI plane currently renders to a canvas,
to a PNG, or to a quad in a 3D scene — and §6's status section lists
"no live window" as its first outstanding item. A panel hanging in a game
world has no window handle to subclass, and the web tier gets
accessibility from the browser for free.

**So the order is: wire the panel to GR5's `stz_window.dll` first, then
G4b.** That is a smaller and better-understood piece of work than the one
this plan spent a session treating as a standing-decision crisis.

## What to do, concretely

1. Vendor `engine/vendor/accesskit/` in the **wgpu shape** — `include/`,
   `lib/` for the host target only, and a `VERSION` file with the tag,
   asset name, upstream commit and SHA-256s. The per-platform artifact
   size is the one number still unmeasured; measure it at vendoring time
   and record it, because §10's mistake was 3.47 MB and honesty requires
   the comparison.
2. Wire the panel to a real window — the §6 gap, and the actual gate.
3. Bind `stzAccessibilityTree` to the adapter: our nodes already carry
   id, role, name, description, bounds, focusable, focused and actions,
   and AccessKit's 182-role schema was checked against our 19 when G4a
   chose them.

---

# §6b / G4b-PRECONDITION STATUS — 2026-08-15. The panel in a real window

Guard `gui_scene_narrated.ring` grew to **58 asserts** (was 43). Sweep:
panel 50, adversarial 32, stzui 43, font 30, rtl 37, tier 24, input 38,
accessibility 37, scene 58 — **349 green**. Graphics re-run because two
graphics faces changed: window_narrated 60, gg5_texture 30,
gg5_materialgraph 36, gg4_framegraph 18, gg5_material_language 15,
gg3_hierarchy and gg_visual_probes (narrative) all clean.

New: `base/test/gui/gui_scene_window.ring`. Changed:
`base/graphics/stzScene.ring`, `base/graphics/stzWindow.ring`,
`base/gui/stzScenePanel.ring`.

## What was actually blocking G4b, and it was one line

`stzenginewindownativehandle` **has existed since GR5 and was never
exposed on the Ring face.** It answers an HWND on Windows, an NSWindow
on macOS and an X11 window id on Linux — which is exactly and only what
`accesskit_windows_subclassing_adapter_new`,
`accesskit_macos_subclassing_adapter_for_window` and
`accesskit_unix_adapter_new` take. `stzWindow.NativeHandle()` and
`NativeDisplay()` now surface it, documented with *why* a raw platform
handle is exposed at all, so it does not read as an invitation to reach
around the library.

Measured live: **3868394** — a real HWND, far below the f64 integer
limit the guard asserts against, since the house has paid once already
for an f64 boundary.

## THE DEFECT THIS TRIP FOUND, and it was in the graphics plane

`stzWindow.Draw` keeps the FACE's idea of its size equal to the
engine's — *"the engine retargets either way; without this the canvas
would keep reporting the size it was constructed with"* — **for a
canvas. Not for a scene.** Both `Draw` and `DrawXT` had the gap, in both
of their `:Scene` branches.

Invisible until now, because the engine resizes a 3D scene by itself on
draw, so **the picture was always right**. What went stale was the face:
`stzScene.Width()`, and therefore `Project()`, and therefore the in-scene
raycast, which divides by the viewport to turn a screen pixel into a ray.
**In a resized window every click would have landed somewhere else** —
silently, in the way this plane's defects are always silent.

Fixed by giving `stzScene` a `Resize()` and calling it from both
`:Scene` branches, mirroring what the canvas branch already did. The
guard asserts the mapping MOVES when the viewport does, and — the part
that matters — that it takes a `LooksThrough` to notice, because the
camera snapshot is deliberate.

## Two more found by writing the loop rather than reasoning about it

**`Mount()` was not idempotent.** `AddMesh` appends, so a second mount
hangs a second quad in the same place and the scene accumulates a stack
of identical panels. Exactly the shape of G2's font-family bug: *a
registration that is not idempotent damages the thing it was called to
refresh.* Now early-returns TRUE, and the guard counts instances before
and after with the negative sibling.

**An app that reacts produces a NEW panel, and the quad wore the old
one.** Three wrong answers were available — mount the new one (a second
quad), keep the old one (a screen the user dismissed), or swap it.
`Shows(poPanel)` swaps it: the quad stays, its skin changes, and a panel
of a different size gets a new texture AND a re-bound material, since
the old handle would be freed under the sampler.

**`Shows()` is the seam G5 replaces.** A reactive binding would change a
bound value and re-lay-out the same panel, with no rebuild and no
re-upload of unchanged pixels. Until then this is the honest shape and
it says so.

## The live loop

`ring gui_scene_window.ring` — drag orbits the camera, W/S move in and
out, the pointer hovers the element under the ray, a click activates it
*through* the camera, TAB walks the panel's own ring unchanged, R
reloads `console.stzui` from disk through the court, ESC quits.

Two loop-shape decisions worth keeping: a click is refused on the frame
that ended a drag (letting go of an orbit is not a click on whatever the
pointer is over), and the camera is polar — an angle around, an angle
up, a distance — because that is what a drag actually moves. Pitch is
clamped away from both edge-on and straight-down: neither reads.

`ring gui_scene_window.ring frames N` runs N frames and closes itself,
so the loop is checkable without a person in it. That is a *build,
draw and tear down* proof, explicitly **not** a substitute for driving
it by hand — every visual defect in this plane was found by a person
looking at a picture, and the count stands at 6.

## What is now unblocked, and what is not

**G4b is unblocked.** The handle exists, the tree exists, the prebuilt
binaries exist. What remains is vendoring `accesskit-c` in the wgpu
shape and binding `stzAccessibilityTree` to the adapter.

Still open, unchanged: **G5's reactive binding** (the `Shows()` seam),
one panel per scene (per-instance materials are a graphics-plane phase),
the quad fixed at the origin in XZ, no occlusion, and the §3 browser
fixture.

---

# G4b STATUS — 2026-08-15. Accessibility, reaching a real screen-reader API

Guard `base/test/gui/gui_a11y_narrated.ring` — **27 asserts green**.
Sweep: panel 50, adversarial 32, stzui 43, font 30, rtl 37, tier 24,
input 38, accessibility 37, scene 58, a11y 27 — **376 green** across ten
suites.

New: `engine/vendor/accesskit/` (VERSION + header + 352 KB DLL),
`engine/src/a11y.zig`, `engine/src/ring_bridge_a11y.zig`,
`engine/src/stz_a11y_entry.zig`, `engine/stz_a11y.ring`,
`base/gui/stzScreenReaderBridge.ring`, `base/test/gui/gui_a11y_host.ring`,
`base/test/gui/gui_a11y_read.ps1`. Changed: `build.zig`,
`base/common/stzRingLibs.ring`, `base/gui/stzAccessibilityTree.ring`.

## The shape, and why none of it is a new decision

`stz_a11y.dll` is its **own DLL**, because AccessKit is per-OS — the
same property that put windowing in `stz_window` and audio devices in
`stz_audiodev`. The portable half of a plane does not carry a per-OS
dependency.

The vendored runtime is **loaded by name at runtime, never linked**, the
arrangement `stz_gpu` has with `wgpu_native.dll`. So `stz_a11y.dll`
always loads and a machine without `accesskit.dll` simply has no
screen-reader bridge — a state, reported honestly, exactly like a machine
with no GPU having no 3D scene. It also dissolves the msvc/gnu ABI
question, which is why the 352 KB msvc build is vendored rather than the
5 MB mingw one.

**352 KB.** §10 calls a hand-written bridge "the 3.47 MB mistake". This
is a tenth of it, and someone else maintains it.

**One JSON string crosses**, the one `stzAccessibilityTree` already
published. Rule 104 taken literally: what a screen reader can operate an
agent can operate, and both read the same document. The Ring side gained
a platform bridge without the tree changing at all.

## THE PROOF HAS TWO SIDES, because one side proves nothing

In-process, *"we pushed a tree"* looks identical on a machine with a
screen reader and a machine without one. So the verdict comes from a
client sharing no code with us: **Windows' own UI Automation**, driven by
`gui_a11y_read.ps1` against `gui_a11y_host.ring`.

    WINDOW name=[STZ-A11Y-PROBE-WINDOW] type=ControlType.Window
    COUNT 11
    NODE type=Text      name=[NAV CONSOLE]
    NODE type=Group     name=[BEARING 137.4   RANGE 8.20 km]
    NODE type=Group     name=[drift nominal - hull 98%]
    NODE type=Button    name=[Fire]   focusable=yes
    NODE type=Button    name=[Abort]  focusable=yes
    NODE type=StatusBar name=[click me through the camera]

and the same event, seen from our end:

    FINAL announced=1 read=1 nodes=12
    VERDICT something read the tree

Either half alone is weak — a client could be reading some other window,
a counter could be counting our own calls. Together they are one event
observed from both ends. `TimesRead()` exists for exactly this: it stays
**0** on a quiet machine, and the guard asserts that it does, because a
bridge that counted its own pushes as success would be indistinguishable
from a bridge that did nothing.

## THE ROLE MAPPING WAS MEASURED, and two of three candidates lose the text

Our `label` role — a run of static text — has three plausible homes in
AccessKit. Measured against the real client:

| AccessKit role | what the client saw |
|---|---|
| `LABEL` | present as `ControlType.Text` **with an empty name**. The whole instrument readout was SILENT while the heading beside it announced fine. AccessKit's `Label` is the form-label element, so its text is attributed elsewhere. **Present and silent is the worst of the three.** |
| `TEXT_RUN` | **GONE.** The descendant count fell from 11 to 7 — a text run is an internal text-position node, not a control. |
| `PARAGRAPH` | visible, named, announced. **Shipped.** |

The cost of the winner is stated: a paragraph arrives as a named `Group`
rather than the more informative `Text`. A named Group is read aloud
where a nameless Text is not, so the trade is the right way round.

**No assertion written beforehand would have caught any of this**, and
none of it is visible from inside the process. That is the fourth time
this plane has learned the same lesson, and the count now reads: six
defects found by looking at pictures, three by reading a tree through
something that isn't us, zero from assertions written first.

## Two defects found in our own code on the way

**The published JSON carried `depth` but not `children`.** The structure
was RECOVERABLE — a node's children are the following nodes at depth+1 —
but not STATED, and the first consumer that had to build a real platform
tree had to reconstruct it. A structure a reader must infer is one a
reader can infer wrongly. `children` is now explicit; `depth` stays,
because it is what makes the flat list readable aloud in order.

**An empty tree was accepted and published.** `{"nodes": []}` parses
perfectly, and pushing it REPLACES a good tree with nothing — a window
that had been fully described going silent, with no error anywhere. A
window always has at least a root, so an empty node list is a caller's
bug; it is refused now and the previous tree is left exactly where it
was.

## Two sharp edges paid for inside the module

**The adapter panics if the window is already visible**, and GLFW shows a
window at birth. So `attach` hides the window, builds the adapter, and
shows it again. Three calls, invisible when done right after creation —
and the constraint stays inside `a11y.zig` instead of reshaping the
graphics plane's API. A caller who attaches mid-session will see a blink,
and the class says so.

**The activation handler runs when an AT first connects**, which may be
long after the tree was pushed, and it must RETURN a tree. So the latest
JSON is kept and a fresh AccessKit tree is built on demand. A bridge that
only answered pushes would be silent for every reader that started after
the program did — which is most of them.

## What G4b did NOT do

- **No real screen reader was run.** UI Automation is the API a screen
  reader uses, and a UIA client is a genuinely independent reader, but
  NVDA or Narrator saying the words out loud is not what was measured.
- **Descriptions are unverified.** Every node's `RATIONALE` is published,
  and AccessKit maps it to UIA's `FullDescription` — which the legacy
  .NET client cannot read (it predates the property and refuses a raw
  id). Recorded as owed, not reported as working.
- **Actions do not route back.** A reader can request `Focus` or `Click`;
  the handler drops them. Counting them would be a lie about capability.
  Activating a control FROM a screen reader is not delivered.
- **No live-region announcements**, so a `status` node changing says
  nothing.
- **Windows only in practice.** The macOS and Linux adapters are in the
  vendored ABI and the module is written around them, but only the msvc
  DLL is vendored and only Windows was measured.
- **No incremental updates.** Every announce rebuilds and pushes the
  whole tree. Fine at twelve nodes, asserted at twenty-two pushes, and
  the wrong shape for a virtualised list — which is the survey warning
  G4a already recorded against the day a list becomes lazy.

---

# THE 256-SEGMENT CLIFF — 2026-08-15. The labels were right; the render pass refused to draw them

**Reported by the author, from a screenshot**: the G4b probe window's
labels disappeared after a few seconds. The boxes kept rendering. That
is a graphics-plane defect, found — again — by a person looking at a
window, and it had been reachable since GR1.

Sweep after the fix: GUI 380 (scene 62, a11y 27), graphics
window_narrated 60, gg_adversarial 57, gg5_texture 30, gg5_materialgraph
36, gg5_gallery 24, gg4_framegraph 18, gg5_material_language 15,
gg_convergence 15, gg_image_primitive 14, gg_scalewall 11, gg_baseline 7,
gg4_multipass and gg4_oneframe closed.

## Three innocents, each cleared with a number

The temptation was to blame the newest thing. Every candidate was
measured instead, and all three were fine:

| suspect | measurement | verdict |
|---|---|---|
| the panel's text pipeline | 6 text meshes, 6 generate calls, `TextIsWhole` true at 1, 60, 200 and 400 repeats | innocent |
| the glyph atlas | 66 entries, **0 dropped**, at every depth | innocent |
| the tessellator | 204,000 text vertices built at 400 repeats | innocent — it built every glyph |

**The geometry existed, was uploaded, and was never drawn.**

## The cause, and the exact boundary

`PASS_MAX_BG = 256` in `gpu_render.zig`. Only a TEXTURED draw takes a
bind-group slot, so the real ceiling was **256 text or image segments in
one render pass** — and the 257th draw returned `BAD_ARG` *before its
vertex buffer was set*. Refused, and counted nowhere.

Bisected to the pixel:

    255 pairs -> 510 segments -> text renders
    256 pairs -> 512 segments -> text renders
    257 pairs -> 514 segments -> TEXT GONE

Reproduced with **no panel and no GUI plane at all** — a bare canvas
alternating a rect and a string — which is what moved the defect from
this plane to the graphics one. The alternation matters: consecutive
text merges into a single segment, so a naive "draw 600 strings" test
passes while a panel loop fails at 257.

## The fix, and the rule it restores

**The pool grows**, the way the handle table learned to. `g_pass_bgs`
became an `ArrayListUnmanaged`, both `PASS_MAX_BG` checks are gone, and
a growth that genuinely fails increments `g_pass_bg_refused` rather than
returning in silence. `passBindGroupStats()` answers
`[ in flight, peak, refusals ]`, so a pass approaching pathology is
visible before a screenshot is.

**Two silent `catch continue`s in the tessellator were also counted.**
`textLayout` and `glyphEntry` each dropped a whole string or glyph
without moving a number. `sceneStats` grew two fields — strings dropped,
glyphs dropped — both gauges describing the current build, the contract
the atlas's own `dropped` already used. They read 0 throughout this
investigation, which is exactly why they had to exist: **they are what
let the tessellator be ACQUITTED** instead of merely suspected.

## The caller's bug, which is a different bug

The probe loop drew the panel into a canvas every frame and never
cleared it: 7 shapes a frame, 2,800 by frame 400, every one
re-tessellated and re-uploaded. `stz_gpu.ring` already warns about this
shape — *"an ANIMATED scene calls Clear each frame; without it a frame
loop appends shapes forever — a defect a one-shot renderer cannot
expose"*. The loop now clears.

Both were real. The missing `Clear()` was wasteful and was the thing that
*exposed* the cliff; the cliff was the thing that ate the labels. Fixing
only the demo would have left a 256-segment ceiling waiting for the first
genuinely complex screen.

## What the guard now holds

`gui_scene_narrated` §9 builds **514 segments** — one pair past the old
ceiling — and asserts three things, in order of how easily each could
lie:

- the segments were built (514) and nothing was dropped (0, 0)
- **and the pixels are actually painted**: bright pixels are counted in
  the readback, because a segment count proves geometry, and only ink
  proves drawing. That distinction is the entire content of this defect.

The running count for this plane: **seven defects found by looking at
pictures**, three by reading a tree through something that is not us,
zero from assertions written first.

---

# G5 STATUS — 2026-08-15. The binding: a declared value changes, and the screen follows

Guard `base/test/gui/gui_binding_narrated.ring` — **35 asserts green**.
Sweep: panel 50, adversarial 32, stzui 43, font 30, rtl 37, tier 24,
input 38, accessibility 37, scene 62, a11y 27, binding 35 — **415 green**
across eleven suites.

New: `base/gui/stzUiBindings.ring`, `base/test/gui/bound.stzui`,
`base/test/gui/gui_binding_narrated.ring`. Changed: `stz_rmlui.cpp`,
`gui.zig`, `ring_bridge_gui.zig`, `stzPanel.ring`, `stzGui.ring`.

**G5's first clause shipped early, with G1** — `.stzui` already turned
declarations into RML and RCSS, because §4 forbade hand-writing markup
and had left nothing a person may write. This is what remained.

## The engine could only LOAD

Everything after `LoadRml` was a QUERY — boxes, hit tests, focus, events.
So the only way to change what a screen said was to build the whole
document again, which is exactly what `stzScenePanel.Shows` and the
showcase viewer's reload do, and what both of them say in their comments
they are waiting to stop doing.

`stz_gui_set_text` and `stz_gui_set_style` are the update path. Text goes
through RmlUi's text NODE where the element holds one, and falls back to
inner RML with the value **escaped** — a bound value is DATA, and a model
holding `<span>` must not inject markup into a document the court already
passed. That is the injection seam of the whole phase and it is closed at
the only place it can be.

## A placeholder is an ordinary string

    DEFINE TEXT line_one ( CONTENT "BEARING {bearing}   RANGE {range} km" )

**No grammar change.** The Grammar Commons fixes what a field value may
BE — string, number, identifier, list — and `CONTENT @bearing` would mint
a fifth kind for one plane's convenience. `"{bearing}"` is a string, so
every older document still parses and the court's round-trip fixpoint
still holds, which the guard asserts rather than assumes.

**A lone brace is prose.** The test document's footer reads *"use {} for
a set"* and must survive untouched; a template language that eats
ordinary punctuation is one people stop writing prose in. Only
`lower_snake` inside braces is a binding.

## THE CLAIM THIS GUARD WAS WRITTEN TO CHECK WAS WRONG

The obvious claim — *a binding re-shapes only the string that changed* —
is **false**, and finding that out is most of what the guard is for.
Measured on a six-string console, with a still redraw costing zero as the
control:

| change | strings re-shaped |
|---|---|
| still redraw | **0** — RmlUi's geometry cache is real |
| a background colour | **0** |
| a text colour | **1** — the string it touched |
| **one bound text value** | **6 — all of them** |

That last number did not move when the cheaper engine call was used
(setting the text NODE rather than replacing inner markup): it is
**RmlUi's invalidation granularity**, not ours. A text change dirties the
document and every string in it is generated again.

So `Set` and `SetStyle` stay **different verbs**. They have genuinely
different costs, and a caller choosing between them should be able to see
which is which.

## What a binding actually buys, then

**The document survives.** No re-parse, no new context, no font
re-registration, no accessibility tree rebuilt — and **focus stays where
it was**. The guard proves it with the negative sibling that makes it an
argument rather than a claim: bind a value while `fire` has focus and
focus is still on `fire`; rebuild the same document the old way and the
new panel has no focus at all.

That is a **correctness** difference, not a cost one. A form that
re-declared itself to update a status line was throwing away the user's
place in it.

## What G5 did NOT do

- **No dependency graph.** `Set` re-renders every template that mentions
  the name; there is no computed value, no chain, no invalidation
  ordering. `stzReactiveObject` has `Watch`/`Computed`/`BindTo` and this
  deliberately does not touch them: that layer needs a libuv reactor
  turning, and a GUI frame loop is not one.
- **No two-way binding.** A textbox's edits do not flow back. G3 left
  text editing undone (`caretRect` still has no consumer), so there is
  nothing to flow.
- **No formatting.** A value is substituted as the string it is — no
  number formats, no dates, no locale. `stzLocale` exists and this does
  not reach for it, because a template that formats is a template that
  computes.
- **No batching across a frame.** `SetMany` coalesces one call; two calls
  in one frame still push twice. The reason to fix it would be the
  re-shape cost above, and that cost has not yet been felt on a real
  screen.
- **The two rebuild sites are unchanged.** `stzScenePanel.Shows` and the
  showcase reload still rebuild, because both replace the WHOLE document
  rather than a value in it. They are the right shape for what they do;
  what they were standing in for is now available beside them.
