# SOFTANZA COLOUR — plan of record

One colour language for every plane: 2D canvas, 3D scenes, diagrams,
plots, `stzApp`, `stzZui`, RingFace, Ringine.

---

## 0. What is already right, and must survive

The existing system's best property is that **an author writes a meaning
and gets a colour**:

```ring
oC.FillQ(:Danger).AddRoundRect(x, y, w, h, 8)
oC.AddTextQ("down", tx, ty).Color(StzContrastingText(:Danger))
```

Three things earn their place and are **kept unchanged**:

- **One word is enough.** `:Danger` needs no theme object, no context, no
  setup. Any redesign that makes the simple case longer has failed.
- **A colour is an EXPRESSION, not a value.** `blue+`, `:Success`,
  `StzThemeColor(:pro, :primary)` and `#3E6EA8` are all colours, and every
  face takes all of them through one choke point (`StzColorToNumber`).
- **The picture answers, not the author.** `StzContrastingText` decides
  what can be read on a fill. Nobody types a label colour.

Everything below is additive. Nothing here removes a spelling that works
today.

---

## 1. What is measurably wrong

### The ramp is not a ramp

Perceptual luminance (BT.709) of each shade, measured:

| base | `--` | `-` | base | `+` | `++` | steps between |
|---|---|---|---|---|---|---|
| blue | 227 | 173 | **29** | **91** | 11 | 54, 144, **−63**, 79 |
| green | 232 | 190 | **75** | **91** | 29 | 42, 114, **−16**, 61 |
| red | 233 | 190 | **76** | **114** | 30 | 42, 114, **−38**, 83 |
| yellow | 251 | 244 | 225 | 45 | 10 | 6, 18, **180**, 34 |
| gray | 238 | 208 | 127 | 100 | 50 | 30, 80, 27, 49 |

Two defects, both visible in the pictures:

1. **Non-monotonic.** `blue+` is LIGHTER than `blue`. The base sits darker
   than both its neighbours, so the "ramp" zigzags. This is why the
   `light` theme rendered `:Success` as near-black olive: `green+` is not
   "slightly lighter green", it is a different lightness entirely.
2. **Wildly uneven.** Yellow's four steps are 6, 18, 180, 34. A ramp whose
   steps differ by 30x cannot be used to express hierarchy.

The cause is arithmetic in **sRGB**. Equal RGB steps are not equal
perceived steps, and the base names are saturated primaries (`#0000FF`
has luminance 29 — nearly as dark as black) so the base is not the middle
of anything.

**The guard did not catch this.** `gg_color_dsl.ring` asserted only that
`--` is lighter than the base and `++` is darker — both true of a zigzag.
Monotonicity was never checked. Recorded, because a green suite that
misses this is the more expensive lesson.

### Contrast is a coin flip, not a ratio

`StzContrastingText` returns `"white"` or `"black"` against a threshold of
150. It cannot answer "is this pair legible?", so nothing can refuse an
illegible combination. A design system that cannot fail an accessibility
check does not have one.

### A shade is not a role

`blue+` says *how light*. It never says *what for*. So every face invents
its own convention for which shade is a border and which is a fill, and
they drift.

---

## 2. What the mainstream does, and which part is worth taking

**Radix Colors** — a 12-step scale where *each step has a declared job*:
1–2 backgrounds, 3–5 component backgrounds (normal / hover / active),
6–8 borders (subtle / interactive / focus), 9–10 solid fills, 11–12 text
(low / high contrast). The insight is not "twelve steps". It is that
**a step is a ROLE, not a lightness** — which is exactly what `blue+`
lacks.

**Material Design 3** — every surface role is declared with a paired
foreground: `primary` / `on-primary`, `primary-container` /
`on-primary-container`. Contrast becomes a **declared pair** rather than a
computation repeated at every call site. Roles map onto tonal palettes
(tones 0–100) generated from a seed colour, so a whole scheme can be
derived from one brand colour.

**OKLCH / Oklab** — a perceptually uniform space. Equal steps in `L` look
equal *across hues*: a yellow and a blue at the same `L` read as the same
brightness, which is precisely what the table above shows sRGB failing to
do. This is the fix for defect 1, and it is arithmetic, not taste.

**APCA** — the modern successor to the WCAG 2 contrast ratio, modelling
polarity (dark-on-light behaves differently from light-on-dark). Gives a
*number* that can be asserted, so a theme can be **gated in CI**.

**What is deliberately NOT taken:** Material's dynamic-colour extraction
from wallpaper, and Radix's exact hue set. Both are product decisions for
someone else's product.

---

## 3. The design

### 3.1 A colour expression gains a ROLE STEP, keeping the old spelling

```
:Danger                  the solid  — unchanged, still one word
:Danger.Surface          a tinted background for a container
:Danger.Border           a border that reads against Surface
:Danger.Solid            the filled control (same as :Danger)
:Danger.Text             text on the app background
:OnDanger                what can be READ on :Danger  (the M3 pair)
```

Six steps rather than Radix's twelve — the four Softanza actually needs,
plus the pair. The names say the job. `blue+` keeps working and keeps
meaning "one step lighter".

### 3.2 The ramp moves to OKLCH, in the ENGINE

`stz_color.zig`: sRGB ↔ linear ↔ Oklab ↔ OKLCH, and a ramp generator that
walks **L** while holding **H**, clamping **C** to the sRGB gamut.

- Monotonic by construction: `L` decreases across the ramp, so no zigzag
  is representable.
- Even by construction: equal `L` steps.
- Hue-stable: `green+` stays green instead of sliding to olive.
- Engine-side because it is per-pixel-class arithmetic that plots,
  scenes and gradients will call in bulk — the seam law.

### 3.3 Contrast becomes a NUMBER that can be refused

```ring
StzContrastOf(:Danger, :White)     # an APCA-style Lc figure
StzIsLegible(fill, text)           # against a stated minimum
StzOnColor(fill)                   # the best of the theme's on- colours
```

`StzContrastingText` keeps its exact current behaviour and answer, because
pictures depend on it. The new calls are the ones a theme is **gated** by.

### 3.4 A theme is DATA, and it is EXPORTABLE

A theme is a hashlist: roles → expressions. That is what it already is.
What is added is that it can leave Ring:

```ring
oT = StzTheme(:pro)
oT.ToCSS()          # custom properties, for stzZui and stzweb
oT.ToJSON()         # design tokens, for RingFace and any tool
oT.ToRing()         # a literal, for embedding
```

One source of truth for a product whose UI is partly Ring and partly web.

### 3.5 The planes, and what each needs that the others do not

| plane | what it needs |
|---|---|
| `stzCanvas`, diagrams, plots | what exists today, plus role steps |
| `stzScene` (3D) | **linear-space colour.** A semantic colour used as albedo must be linearised or it renders wrong. Today `SetBackground(:Danger)` and a material's colour go through different paths and only one is right. |
| `stzApp` / `stzZui` | a theme it can EXPORT, and light/dark as a first-class switch |
| RingFace | tokens as data, since it is not necessarily drawing through this library |
| Ringine | a palette resolved ONCE at load, never per frame — the budget is 2,000 script decisions per frame and colour resolution must not compete with it |

The 3D row is the sharpest: it is a correctness bug waiting, not a
preference.

---

## 4. Phases, each with a kill criterion

**C1 — OKLCH in the engine.** `stz_color.zig` + the ramp generator.
*Kill:* if an OKLCH ramp is not monotonic and even across all base hues
when measured the same way as the table in §1, the space is not buying
what it claims and the shade algebra stays sRGB.

**C2 — role steps.** `:Danger.Surface` etc., generated from the ramp.
*Kill:* if the six steps cannot be told apart in a rendered picture, they
are ceremony; keep the solid and the pair only.

**C3 — contrast as a number.** `StzContrastOf`, `StzIsLegible`, and a
CI gate over the shipped themes.
*Kill:* if the existing themes cannot pass a stated minimum and cannot be
adjusted to, the minimum is wrong or the themes are — either way that is
the finding, and it gets written down rather than lowered quietly.

**C4 — linear-space 3D. DONE.** The paths did NOT agree: a material saying
`tint * k` with `#808080` and k=0.5 rendered **64** where linear light gives
**92**. Multiplying an sRGB-ENCODED value does not halve the light, it halves
the ENCODING — so every shadow in every material was far too dark and every
mid-tone muddy. The classic gamma bug, and it had been shipping.

The material transpiler now linearises every declared colour and the instance
colour on entry, and encodes once on the way out. Verified: flat colours
round-trip with **zero drift** across six test colours, and backgrounds stay
**literal** — a clear colour has no arithmetic applied, so linearising it too
would have been a regression dressed as a fix.

Textures are deliberately NOT wrapped. Their colour space is a FORMAT
decision (an sRGB texture view lets the sampler do it for free) and deserves
its own measurement rather than a guess inside this phase.

Guard: `test/graphics/gg_color_c4.ring` (6).

**C5 — export. DONE.** `stzTheme` — `ToCSS` / `ToJSON` / `ToRing`, one theme
shared between a Ring face and a web face.

Every role goes out with its four C2 steps and its `on-` pair, **resolved to
hex**, because the far side has no resolver and must not need one: **37
tokens** per theme, not 7. `background` deliberately carries no steps — it
is a surface, not something that holds text.

*Kill criterion, met in pixels:* out to CSS, back through
`StzThemeFromCSS`, painted from nothing but the parsed file, against the
same paint from the live theme — **0 bytes differing** across 7,783
sampled. The negative sibling bends one token and the same comparison
reports 282. All ten themes export, and their exported pairs still clear
C3's 4.5:1 on the FAR side — otherwise C3 would guarantee a property of a
file nobody uses.

Guard: `test/graphics/gg_color_c5.ring` (20).

**C1–C5 are complete.**

---

## 5. Risks, named now

- **Two systems during the transition.** The sRGB palette and the OKLCH
  ramp will both exist while C1 lands. That is exactly the divergence
  that produced two colour tables before. The rule: OKLCH generates the
  palette at build/load, and there is never a second live table.
- **The base names are saturated primaries.** `#0000FF` as "blue" is a
  poor anchor for any ramp. Re-anchoring them is a VISIBLE change to
  existing pictures and must be its own decision, made once, with
  before/after renders — not smuggled inside C1.
- **APCA is not WCAG 2.** Quoting an Lc number where somebody expects a
  4.5:1 ratio will confuse. Report both, or name the metric every time.
- **Ringine's frame budget.** Anything per-frame here is wrong by
  construction; colour resolves at load.
