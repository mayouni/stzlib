# SOFTANZA CULTURE PLAN — analysis and phased plan (CU0–CU5)

**Contract**: C8, numbered 2026-08-18. The contract file
(`softanza/contracts/culture.md`) is deliberately **not written yet**: the module comes
first and the contract is extracted from what it establishes, the same order C2 came
from the zui verifier. Central writes it once this plane establishes something.

**Founding law, and it is the whole design:**

> **A locale formats. A culture interprets.**
>
> A locale says how something is written down; a culture says how it will be read. A
> locale can be derived from a published standard; **a culture must be contributed.**
> **No call in this module may return a *meaning* from a locale identifier alone.**

**The law that follows from the survey below, and which numbering made load-bearing:**

> **No facades. An operation either honours the culture it was given, or refuses.**

Under a module, a facade is an internal detail that reports success. **Under a contract it
is a conformance failure.** That was the Principal's decisive reason for numbering culture
C8, so the existing `base/i18n` facade is in scope for this plane rather than adjacent to
it — it is the first thing C8 refuses.

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

### The mission, in one paragraph

Softanza can already say how a value is written down. It cannot say how it will be read.
`base/graph/stzDiagramColor.ring:45` hard-codes `:Success = "green"` and `:Danger = "red"`
as though those were meanings; they are one culture's reading, and they **invert** in
Chinese, Japanese, Korean and Taiwanese financial convention where red is gain. A Softanza
financial dashboard shipped to Shanghai renders profit in the colour of loss. This plane
builds the model that lets a declared meaning be rendered per culture — and, just as
importantly, lets the library **refuse** rather than guess.

### Orientation — where everything is

| What | Where |
|---|---|
| This plan | `base/culture/SOFTANZA_CULTURE_PLAN.md` |
| The module | `base/culture/` — does not exist yet; CU1 creates it |
| Guards | `base/test/culture/` — narrated scenarios |
| Layer one (locale) | `base/i18n/` ~3,500 lines, five classes |
| Layer one's plan | `engine/SOFTANZA_LOCALE_PLAN.md` — L0, L1 done; **L2–L4 not started** |
| The case for the module | `stzzui/doc/THE-SECOND-FOUNDING.md` §4.6 (a proposal to us, not a specification of us) |
| The full brief | `stzzui/doc/prompts/culture-module.md` |

### Commands

```bash
# run a guard (MUST be run from inside its topic directory)
cd libraries/stzlib/base/test/culture && /d/ring127/bin/ring.exe 00_culture_narrated.ring

# run the library's own recorded expectations for a topic
python libraries/stzlib/base/meta/promises.py culture
```

### The working discipline (non-negotiable)

- **Extract, never invent.** Whatever `base/i18n` really holds, this module consumes.
  Whatever it does not hold is a finding for L2–L4, **not work to duplicate here.**
- **A culture may reference locales; a locale must never reference a culture.** If the
  dependency ever points the other way, the separation has failed and this plane should
  say so rather than paper over it.
- **Build a general model, not a UI law.** Ratification gives this module consumers; it
  does not give it jurisdiction. Which meanings an interface *must* express and which
  conflicts are *refusable* remain StzZui's. **If this plane grows a `:Danger`, the
  layering has collapsed.**
- Naming law verbatim: a method is an explicit verb, `...Q()` returns the main object,
  `To...()` returns data.

### The first action

CU0. It is a spike with one question and the honest expectation is a negative answer;
see §3.

---

## 0. The facts that shape everything (surveyed 2026-08-18)

**Every row below was verified in this session by running it, not by reading the brief's
table.** The brief asked for exactly that, and one of its own three named defects turned
out to need a sharper diagnosis than it carried while another was already repaired.

### FACT 1 — the casing facade is four levels deep, and the bottom one has no locale at all

The brief called this "a facade at three levels". It is worse and more specific:

| Level | Code | What happens to the locale |
|---|---|---|
| 1 | `stzString.UppercasedInLocale(pcLocale)` | `return upper(This.Content())` — ignored, **and** Ring's byte-based `upper()`, which a comment two methods below in the same file warns "fail[s] on multibyte chars" |
| 2 | `stzStringLocale.UppercasedInLocale(pcLocale)` | builds a `stzLocale` and calls `ToUppercase` — **carries it faithfully** |
| 3 | `stzLocale.StringUppercased(pcStr)` | `StzEngineLocaleToUpper(pcStr)` — the locale object is `This` and is **never passed on** |
| 4 | `stz_locale_to_upper(src, src_len, buf, buf_len)` | **the parameter does not exist** |

Measured:

```
UppercasedInLocale("tr_TR") = ISTANBUL
UppercasedInLocale("en_US") = ISTANBUL
```

The function at the bottom is *named* `locale_to_upper` and has never had a locale. The
engine carries no Turkish/Azeri special casing at all (`grep -i turkish|dotless|special_casing`
over `locale.zig` and `unicode.zig` returns nothing).

**This is the code equivalent of the fake progress bar Rule 18 forbids.** A caller believes
they received locale-sensitive casing. Level 2 is the cruellest part: it does the right
thing, which is why nobody looking at it would suspect the result.

### FACT 2 — the engine and the Ring layer disagree about Hebrew, and the cause is an off-by-one in a comment

Measured:

| Text | Engine says | Ring says |
|---|---|---|
| `שלום` (Hebrew) | **Neutral** | rtl |
| `مرحبا` (Arabic) | RTL | rtl |
| `hello` | LTR | ltr |
| `hello שלום` (mixed) | **LTR** | ltr |

`engine/src/locale.zig` carries this comment and switch:

```zig
// utf8proc bidi classes: 1=L, 2=LRE, 3=LRO, 5=R, 6=AL, 7=RLE, 8=RLO, 13=AN, 14=EN
switch (bidi) {
    1, 14 => has_ltr = true,   // L, EN
    5, 6, 13 => has_rtl = true, // R, AL, AN
```

utf8proc's actual numbering, from the vendored `utf8proc.h`: **L=1, R=4, AL=5, RLE=6,
EN=9, CS=13, NSM=14.** The comment's table is shifted from `R` onward, and the code
faithfully implements the comment. So:

- **`R = 4` is missing entirely** — which is Hebrew, and every RTL script that is not Arabic.
- `RLE = 6` (an embedding control) and `CS = 13` (a number separator) are counted as RTL.
- `NSM = 14` (a nonspacing mark) is counted as LTR.
- Arabic works **by luck**: `AL = 5` happens to sit in the RTL set.
- Mixed text never reports MIXED, because `has_rtl` cannot become true for Hebrew.

**Filed, not fixed here** — it is layer one's, and it is a finding for the locale plan.
Recorded at this precision because "uses the wrong constants" would send the next reader
looking for the wrong thing: the constants match the comment, and the comment is wrong.

### FACT 3 — collation, digit shaping, non-Gregorian calendars and time zones do not exist

Verified: no Hijri function and no time-zone function in the loaded surface; sorting is
the engine's ordinal sort. These are **L2–L4's**, and this module must refuse rather than
reimplement them.

### FACT 4 — what layer one does hold, and holds properly

Unicode normalization (all four forms, utf8proc). Script detection. Locale/country/
language/script/currency tables. Bidi and Arabic shaping — **but only inside GPU glyph
layout**; there is no bidi service for a plain string, which is why FACT 2 matters.

First-day-of-week, decimal point and group separator are genuinely locale-derived — and
three defects in that derivation were repaired earlier today (`ar_EG` opening its week on
Monday; `Script()` reading a many-to-one mapping backwards and answering *Duployan* for
French; the abbreviation carrying the script). **That repair is why FACT 4 can be stated
positively at all**, and it is the evidence for the survey discipline: the brief's table
said this row was fine, and it was fine only in part.

### FACT 5 — the identifier rule has teeth, and today it is unenforced rather than violated

`lower(upper("istanbul"))` round-trips today **because the Turkish path does not exist.**
The moment FACT 1 is repaired, it stops round-tripping under `tr`, which is precisely why
the invariant rule must be stated and guarded *before* the repair lands, not after:

> **Identifiers and stored data use the invariant. Only human-facing text uses a culture.**

---

## 0.5 Lessons inherited from the sibling planes (each already paid for)

- **GRAPHICS / GPU — measure before naming the line.** The numeric plane's plan named the
  wrong bottleneck four times out of six. CU0 is a spike for that reason.
- **SOUND — kill criteria in writing before the numbers.** Below, in §3.
- **LOCALE (L0) — generate offline, commit the output.** The library dropped libcurl for a
  Zig HTTP client, chose SheenBidi + HarfBuzz over ICU, built regex on PCRE2, and generated
  the currency table offline with a provenance header. Any external data this plane needs
  follows that path. **No ICU, no CLDR at runtime.**
- **PERF — an identity is not a self-check.** A formula computed from one set of anchors
  can never fail. Inversion symmetry (§7) is a real self-check because it compares two
  independently recorded readings.
- **THIS SESSION — a guard that asserts a bug keeps the bug.** Found today in
  `numeric_handle_table_narrated`, which pinned "a circled numeral answers 0 — unchanged,
  and wrong, and pre-existing" and thereby turned the eventual correct fix into a failing
  test. Pinning a known gap is legitimate **only** when the assertion fails the day it is
  fixed and says so in its label.

---

## 1. The vendor decision

| Candidate | What it would give | Verdict |
|---|---|---|
| **ICU** | collation, calendars, casing, time zones | **KILLED.** Layer one's decision, already made and standing (L0). Enormous, and it answers layer-one questions this module does not ask. |
| **CLDR at runtime** | locale data, plural rules | **KILLED.** Same L0 precedent. If data is needed: generate offline, commit the output with a provenance header. |
| **CLDR for meanings** | — | **DOES NOT EXIST.** There is no CLDR for meanings. This is the point of CU0. |
| **Any "meanings" dataset** | readings per culture | **KILLED BEFORE LOOKING.** Anything claiming to be authoritative is someone's guess with a version number. Vendoring one would import exactly the essentialism this module exists to prevent. |
| **Contributed + evidenced** | readings, with strength and provenance | **The only admissible source.** See §6. |

**The kill that matters is the fourth**, and it is recorded here in writing so that a later
session tempted by a convenient dataset finds the reasoning rather than re-deciding it.

---

## 2. The model

A **model**, not a lookup table. Offered as a starting vocabulary to improve or refuse.

- **Sign system** — a *closed* set of kinds: colour, sound, shape, gesture, number,
  direction, time, name. Closed because the signature move needs it closed.
- **Sign** — a value in a system: `red`, `rising-contour`, `octagon`, `4`, `Friday`.
- **Meaning** — the semantic target: `danger`, `gain`, `mourning`, `rest-day`.
- **Reading** — sign + culture → meaning, carrying a **strength**
  (`settled` · `common` · `contested`) and its **evidence**. Strength is not optional: a
  culture is not monolithic, and a model that cannot say *contested* commits the
  essentialism it exists to prevent.
- **Inversion** — a first-class relation: two cultures assigning **opposite** meanings to
  one sign. The highest-value data in the module, because inversion is where harm
  concentrates.
- **Hazard** — a sign that must not be used, or must not be *conscripted*, with a severity
  (`offensive` · `unlawful` · `diplomatic`).
- **Norm** — the boundary items that are half locale and half culture: workweek, calendar
  system, name model, address model, honorifics. **Each must say which half it is.**

### The operations

```
ReadingOf(sign, culture)              -> meanings + strength + evidence
SignFor(meaning, culture, system)     -> the rendering        <- what StzZui needs
Inversions(cultureA, cultureB)        -> the conflict set
IsHazardous(sign, culture, usedAs)    -> severity or none
Invariant()                           -> the culture-free baseline
Parent(culture)                       -> the fallback chain
```

**`usedAs` is load-bearing and is the whole design of hazard.** A national flag is the
*correct* sign for country of registration on a customs form and a political claim when
conscripted to mean a language. The API must answer differently for `:asLanguageLabel` and
`:asCountryOfRegistration`, or it will forbid legitimate use and be rightly ignored.

---

## 3. Phases

### CU0 — the spike. One question, and the expected answer is negative

> **Is there any defensible source of meaning data, or must all of it be contributed?**

**Kill criteria, written before the numbers:**

| # | Criterion | If it fails |
|---|---|---|
| K1 | A source exists that is *authored by* the cultures it describes, versioned, and citable | Fall back to contributed-only; the module ships empty and honest |
| K2 | That source distinguishes strength (settled/common/contested) or can be mapped to it without inventing the distinction | Reject it — a source that flattens contest is worse than none |
| K3 | Its licence permits offline generation and commitment with provenance | Reject it — L0's path is the only one |
| K4 | The two-layer split survives contact: no meaning is derivable from a locale id in the candidate data | **Stop the plane and report.** This is the refusal the brief calls the most valuable outcome available |

**The honest expectation is that K1 fails**, and that is a result, not a failure of the
spike. An empty module that admits what it does not know is worth more than a full one
that guesses.

### CU1 — the model, and the two-layer separation as a guard before any data

Types and operations with **no readings at all**. The guards come first: no meaning
derivable from a locale id; the invariant round-trips identifiers under hostile casing;
`usedAs` distinguishes conscription from use; inversions are symmetric.

### CU2 — the refusal path

`UnsupportedCulture` and the no-facade law made real: every operation that resolves
through layer one either works or raises. This phase is where FACT 1 is confronted rather
than inherited.

### CU3 — the challenge pass, before the faces

As GR4 and SN4 both did. Adversarial reading of the model against its own founding law:
where does a meaning leak from a locale id? Where does the model assume monolithic
culture? Where has UI law crept in?

### CU4 — the faces

`stzCulture` and companions, in the naming law.

### CU5 — the first real readings, contributed and evidenced

Governed by §6. Not before.

---

## 4. Risks, named now

1. **The plane grows a UI law.** The single likeliest failure. Mitigation: CU3 exists, and
   a `:Danger` appearing anywhere in `base/culture/` is the tripwire.
2. **The module becomes `CultureInfo` with a different prefix.** Mitigation: the founding
   law's last sentence, guarded in CU1 before any data exists.
3. **Readings get contributed by people outside the culture described.** This is the
   failure the module exists to prevent, committed by the module. Mitigation: §6, and a
   refusal recorded with its reason is as valuable as an admission.
4. **The two-layer split does not survive contact.** If locale and culture cannot be
   separated cleanly in practice, **say so and say why.** The entire design rests on the
   separation holding, so that refusal is the most valuable outcome this plane can produce.
5. **Repairing FACT 1 breaks identifier comparison somewhere.** The moment a `tr` path
   exists, `lower(upper(id))` stops round-tripping. Mitigation: FACT 5 — guard the
   invariant rule *before* the repair lands.

---

## 5. The invariant culture, and the identifier rule

> **Identifiers and stored data use the invariant. Only human-facing text uses a culture.**

Not theory: the Turkish dotless *i* is the canonical case, where uppercasing and
lowercasing an ASCII identifier does not round-trip. Anything written to Bedrock, to
`world.json`, to a `.zql` literal or to a file format is invariant by construction.

---

## 6. The governance of the data

There is no CLDR for meanings, so this module's data **cannot be bought, scraped or
generated**. It inherits commons governance by necessity rather than by choice:

- Every reading carries **evidence** and a **strength**.
- **A reading contributed by someone outside the culture it describes is inadmissible.**
- **A refusal, recorded with its reason, is as valuable as an admission.**

---

## 7. Guards (CU1 onward, in the plane's narrated-Ring genre)

At minimum:

1. The two-layer separation holds — **no meaning derivable from a locale id.**
2. The invariant round-trips identifiers under hostile casing.
3. `usedAs` distinguishes conscription from use.
4. **Inversions are symmetric** — and this is a real self-check rather than an identity,
   because it compares two independently recorded readings.

---

## 8. Findings filed to other planes (not this plane's work)

Each is layer one's, in the genre this library already uses for cross-plane findings.

| # | Finding | Where |
|---|---|---|
| F1 | Hebrew reported `Neutral`; `R = 4` missing from the RTL set while `RLE` and `CS` are in it, and `NSM` counted as LTR. The comment's table is shifted and the code matches the comment. Mixed text never reports MIXED. | `engine/src/locale.zig` → locale plan |
| F2 | `stzNumber.ApplyFormatXT` — **verified, and larger than inherited.** The option is dead because there is nothing for it to separate: the FRACTIONAL PART IS DROPPED ENTIRELY. `1234.56` formats as `+1 234`. `_cFractionalSeparator_` is assigned twice (a default, then from `paFormat[:FractionalSeparator]`) and read nowhere; only `_cThousandsSeparator_` reaches the emit. Measured: asking for `,` and asking for `#` both give `+1 234`. | `base/number/` → locale plan |
| F3 | `base/test/datetime/76_example_15...ring` — **verified, and larger than inherited.** The brief said the arithmetic treats the Hijri year as 365 days. It is not arithmetic: `:CountingFromIslamicCalendar` is IGNORED. The test promises `2021-08-13 01:00:00`; the actual answer is `2000-01-01 00:00:00`, the default. So the promise is wrong (1400 AH is 1979–80 CE, not 2021) **and** the feature it documents does not exist. **A guard that asserts a wrong answer is worse than no guard**, and this one sits exactly where culture and calendar meet. | `base/test/datetime/` → locale plan |
| F4 | The casing facade of FACT 1 — four levels, bottom has no locale parameter. | `base/i18n/`, `base/string/`, `engine/src/locale.zig` → **C8 refuses it; repair belongs to L2–L4** |
| F5 | Cross-plane, to the sound session: `base/sound/stzEarcons.ring:354` asserts rising-means-good is "close to universal across musical cultures" without citation, and `strength: common` may be the honest value. In tonal languages pitch contour carries *lexical* meaning, so a rising contour is not perceptually neutral there. SS1 already measures which of contour, interval, duration and timbre carries identity — **running it across listener populations rather than one answers this at no extra cost.** Do not change their motifs. | `base/sound/` |

---

## STATUS

### CU0 — NOT STARTED

Nothing measured. This section carries the spike's numbers and, explicitly, what it did
**not** measure, when it runs.

**Survey status (2026-08-18):** FACTs 1–5 established by running the library, not by
reading. All five findings verified before filing, because an unverified finding costs the
receiving plane a wasted investigation.

**Three of the five were LARGER than the brief described them**, which is the argument for
the survey discipline rather than a criticism of the brief — it surveyed on 2026-08-13 and
said plainly to verify rather than take the list on faith:

- **F1** — the constants are not "wrong"; they match a comment whose table is shifted from
  `R` onward. `R = 4` is missing while `RLE` and `CS` are counted as RTL and `NSM` as LTR.
  Arabic passes by luck. A reader told "wrong constants" would look for the wrong thing.
- **F2** — not a dead option but a dropped fractional part. The option is dead *because*
  nothing emits a fraction to separate.
- **F3** — not Hijri arithmetic off by a leap rule; the option is ignored and the default
  date is returned.

And one was **smaller**: the brief's table listed first-day-of-week / decimal point /
group separator as sound. Two of the three defects repaired in `base/i18n` earlier today
sat in exactly that row. It is sound *now*.
