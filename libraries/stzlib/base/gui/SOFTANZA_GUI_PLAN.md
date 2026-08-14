# SOFTANZA GUI PLAN — analysis and phased plan (G0–G6)

Status: **PLAN OF RECORD**, written 2026-08-13, before any GUI code.
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
| Ring faces for this plane | `base/gui/` |
| guards | `base/test/gui/` (create) |
| scope-oriented moves (§7 runs M1–M5) | `base/doc/design/SCOPE_ORIENTED_PROGRAMMING.md` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```
# build every engine DLL (from libraries/stzlib/engine)
zig build

# run a guard (MUST be run from inside its topic directory)
cd libraries/stzlib/base/test/gui && ring gui_xxx_narrated.ring

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

*The author's veto is one word, and this is the cheapest moment to use
it.* If it comes, the replacement is `base/surface/` + `stzSurface*`.

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

## §4b · The authored surface: `.stzui` (v0.1, shipped with G1)

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
| **coordinate space** | local, layout, window, screen, texture — the same number means five things and nothing at the call site says which. **The bug factory in every toolkit.** | **Surface.** It is a genuine decision: an in-scene panel and a window panel differ *precisely* here |
| **input source** | pointer, keyboard, gamepad, synthetic, assistive technology | **Surface.** Rule 80 makes "did a human keyboard do this" legally material, and an AT-originated event must be distinguishable from a synthetic one |
| **tier** | in-scene, window, texture | **Probably dissolve.** It looks like a frame and behaves like a *target parameter* — the graphics plane already adopted the swapchain frame as an ordinary render target rather than a mode. Watch it in G1 before minting vocabulary |
| **which document** | several panels alive at once | **Dissolve.** This is an object, not a scope: a panel IS the document |

**M2** (are they small closed sets?), **M3** (the frame goes in the verb,
each frame picks its carrier), **M4** (what the library computes with
them) and **M5** (rehearsal) are **due before G3's event model is
designed**, not after — G3 is where coordinate space and input source both
become load-bearing at once. The §0 gate has already produced one datum
for M1: `x` (draw position) and `pen` (hit box) are *two coordinate
meanings on one axis*, and conflating them is the classic caret bug. That
is the frame arguing for its own existence.

---

## §8 · Phases

House discipline throughout: **kill criteria written before the numbers**,
a **challenge pass before the faces**, and a **STATUS section per phase
recording measurements AND what was not measured.**

### G0 · The spike — vendoring authorized here, and only here

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

The 8 pure virtuals against `stzCanvas`; `PushLayer` / `CompositeLayers` /
`SaveLayerAsTexture` for the in-scene case. **Prove a panel inside a 3D
scene**, since that is the tier this plane starts with (§6). Watch the
`tier` frame here and decide M1's verdict on it by contact.

### G2 · The font engine

Replace FreeType outright. **This is where bidi and Arabic are proven**,
and where the plane's advantage over every surveyed toolkit is realised —
see §2.3's comparison. The §0 gate feeds this phase directly: RmlUi's
`ActivateKeyboard(caret_position, line_height)` takes exactly what
`caretRect` now returns.

### G3 · Input, events and focus — the real gap

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

Softanza declarations → RML/RCSS, with RmlUi's data-binding wired to the
reactive layer. Its `data-` attributes and `{{ }}` expressions are a
closer architectural cousin to Reaxis than any JS engine would be — **use
them rather than inventing a parallel mechanism.**

### G6 · The sense sheet lands

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
