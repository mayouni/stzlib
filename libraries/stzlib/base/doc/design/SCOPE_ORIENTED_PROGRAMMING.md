# Scope-Oriented Programming
### A Softanza paradigm for governing the programmability of complex fields
*Design paradigm — v1.0 (2026-07-20). Governed fields: **Regex** (shipped — see
`stz-regexp-confusion-solved-deepdive.md`), **System programming** (designed —
see `SOFTANZA_SYSTEM_FOUNDATION.md`). This document promotes a pattern that was
born field-specific (regex) into a reusable, field-independent paradigm.*

---

## 1. What this paradigm is for

Some fields are not hard because their operations are hard. They are hard
because **the same expression behaves differently depending on a context that is
invisible at the place you wrote it.** You read the line of code, and you still
cannot say what it will do — because its meaning is bent by a frame you cannot
see from there.

Softanza's answer, repeated deliberately across such fields, is:

> **Make the operative *scope* explicit and first-class at the call site, so
> that behavior is decided by something you can see and name — and so that the
> library itself can reason about it.**

We call this **Scope-Oriented Programming**. It is not a feature of one class.
It is a design stance you apply whenever a field's difficulty traces back to a
hidden governing frame.

---

## 2. The recurring disease: behavior with an invisible governing frame

The shape is always the same:

- There is **one surface act** (match a pattern; ask what system you are on).
- Its result depends on a **frame that lives somewhere else** (regex flags set
  three lines up; whether this code runs on your laptop or on the phone it was
  deployed to).
- At the call site, that frame is **not visible**, so the reader guesses, and
  the guess is often wrong.

The programmer is forced to hold the frame in their head and re-supply it
mentally on every read. That is the tax. It is what makes the field *feel*
cryptic even when each individual operation is simple.

---

## 3. The cure, in four moves

**M1 — Name the hidden frame.** Identify the invisible thing the behavior
actually depends on. In regex it is *the boundary the pattern operates within*.
In system programming it is *which system this code is speaking about*.

**M2 — Turn the frame into a small, closed set of named scopes.** Not an
open-ended flag space — a short, memorable list. Regex: **whole / line / word /
segment**. System: **development / deployment / runtime-current**. The set is
small enough to hold in the hand.

**M3 — Choose the scope *at the call site*, in the verb.** The scope is not set
elsewhere and inherited ambiently; it is part of the act you are writing.
`MatchLine(p)` not `Match(p)`-with-a-multiline-flag-set-earlier.
`App(:mobile).System()` not a bare `CurrentSystem()` whose meaning floats. A
reader of that single line knows the frame without scrolling.

**M4 — Give the library the scope to reason with.** Because the scope is
explicit *and modeled*, the library does more than document it — it *computes*
with it. Regex: the scope selects the right engine flags and dot/greediness
behavior for you, so you never juggle them. System: the scope is checked against
what that system can actually do, so a call that the scope forbids is refused
and a call the scope requires is enabled. **The scope is a semantic handle, not
a comment.**

M4 is what makes this a paradigm and not a naming convention. A convention names
things; a paradigm hands the runtime a modeled object it can *act on*.

---

## 4. Instance 1 — Regular expressions (shipped)

The founding instance. Traditional regex bends one pattern's meaning through
invisible flags: `.` matches newlines only under `/s`; `^`/`$` shift under `/m`;
`*` is greedy until you add `?`. The frame — *what boundary am I matching
within* — is nowhere in the pattern.

Softanza names four scopes and puts them in the verb:

| scope | verb | the frame it fixes |
|---|---|---|
| whole string | `Match()` | `.` crosses lines; the whole text is one field |
| line | `MatchLine()` | boundaries are line ends; `.` stays within a line |
| word | `MatchWord()` | `\b` boundaries automatic; `.` stays within a word |
| segment | `MatchSegment()` / `MatchOneSegment()` | multi-line structure; greedy vs lazy by verb, not by `?` |

The payoff (from the regex deepdive): clearer intent, fewer concepts, more
maintainable and self-documenting patterns, and a natural mapping from problem
to scope (log line -> `MatchLine`, HTML block -> `MatchSegment`, token ->
`MatchWord`). The engine still does the full-power work; the scope just decides,
visibly, *how* it should behave. That is M4 in its simplest form: the scope
picks the flags so the human never does.

---

## 5. Instance 2 — System programming (designed)

The second governed field, and the reason this paradigm is being promoted now.
System code has exactly the disease: a bare `CurrentSystem()` returns your
laptop during development and the Android device after deployment — *the same
line, two answers* — because its meaning is bent by an invisible frame (where is
this code actually running?). Developers cope by holding that frame in their
heads, and get it wrong the moment dev and deployment diverge.

Scope-Oriented Programming names three system scopes and forbids the floating
call:

| scope | how you write it | what it means, unambiguously |
|---|---|---|
| **development** | `Platform.DevelopmentSystem()` | the machine the architect codes on — build, flash, rehearse; **tooling only** |
| **deployment** | `Platform.App(:x).System()` | the system app *x* runs on — **where feature code is written and checked** |
| **runtime-current** | `CurrentSystem()` | whatever system this code runs on *at execution* — laptop in dev, Android in prod |

The rule that removes the confusion is M3 taken seriously: **feature code is
never written against "current."** It is written inside an app's system scope,
resolved to that app's deployment profile at write time. `CurrentSystem()` is
then only a *runtime* value — and by construction it equals the scope the code
was written against, because that is where the app deploys. Dev-machine facts
are reached *only* through the separate name `DevelopmentSystem()`, in tooling
scope. Three names for three worlds; none can be mistaken for another.

This resolves the puzzle that broke every earlier system model: *"after
deployment, `CurrentSystem()` on the phone must return Android."* Yes — and now
that is correct and unconfusing, because `CurrentSystem()` was never the name
you used to mean your laptop. The full model (the architect's common ground of
`stzPlatformProfile` + `stzAppProfile` + attached `stzSystemProfile`s) is
specified in `SOFTANZA_SYSTEM_FOUNDATION.md`; this document records *why* it has
the shape it has — it is Scope-Oriented Programming applied to systems.

---

## 6. What the system instance teaches the paradigm: capability-bridging

Regex never needed this, and it is the genuine advance the second instance
contributes back to the paradigm.

In regex, the *host* — the engine running your pattern — can perform **every**
scope. Whole, line, word, segment are all within its reach; choosing a scope
only changes behavior, never *feasibility*.

In system programming this is no longer true. The developer's machine (the host)
**cannot do everything the scopes can name.** A firmware scope may require GPIO
that a laptop does not have; a mobile scope may forbid a process spawn the laptop
performs freely. So here the scope carries not just *behavior* but a
**capability envelope that can exceed or differ from the host's.** That turns
scope-orientation into a two-way contract:

- **Down-constrain** (host *can*, scope *forbids*): a `Spawn` written inside a
  mobile scope is refused *at write time on the dev machine*, because the scope
  is Android — even though the laptop could spawn all day. The scope stops you
  from assuming your world's affordances.
- **Up-enable** (scope *requires*, host *lacks*): a `ReadPin(4)` written inside a
  firmware scope is allowed and **rehearsed against a virtual twin of that
  system** (simulated pins, on your laptop), then lowered to real firmware on
  deploy. The scope lets you develop for a world you cannot run.

So the paradigm gains a **fifth move**, latent in regex and load-bearing in
systems:

**M5 — When a scope's capabilities can differ from the host's, the scope
becomes a capability contract the library enforces in both directions:
constraining acts the scope forbids, and enabling — through rehearsal — acts the
host lacks but the scope requires.**

This is why the System Foundation binds Scope-Oriented Programming to the
Virtual System Framework: the twin is the mechanism that makes M5's *up-enable*
direction real. You rehearse a foreign system's operations in its twin, and the
one governed crossing lowers them to reality.

---

## 7. How to bring a new complex field under the paradigm

The paradigm is reusable. To apply it to a candidate field, run the five moves
as a checklist:

1. **Find the hidden frame (M1).** Ask: *"what invisible context decides what
   this line does?"* If the honest answer is "it depends on something not on
   this line," you have a scope-oriented field.
2. **Enumerate a small closed scope set (M2).** If you cannot get it under ~5
   named scopes, the frame is probably two frames — split them.
3. **Put the scope in the verb or the receiver (M3).** No ambient modes, no
   set-it-earlier flags. A reader of one line must know the frame.
4. **Let the runtime pick the mechanics from the scope (M4).** The scope should
   *save* the programmer work (flags, boundaries, defaults), not just label it.
5. **Ask whether the host can do every scope (M5).** If yes, you are done. If
   scopes can exceed the host, add the capability contract: constrain what a
   scope forbids, and rehearse what the host lacks.

Four fields already pass this test — none yet designed, all worth designing.
Section 8 runs each through the lens.

---

## 8. The candidate fields under the lens

Each is a genuine scope-oriented field: **a bare value or operation that
silently carries a frame not written next to it.** One disciplinary result up
front — **all four are M1–M4 fields, not M5.** The capability contract stays
System programming's distinctive mark, which is why the instance list stays at
two: these cluster with regex, not with system.

| field | the hidden frame (M1) | named scopes (M2) | the M4 payoff — illegal combinations become *rejected operations* | M5? |
|---|---|---|---|---|
| **Time** | which *clock* and which *zone* a value lives in | clock `{wall, monotonic, process}`; anchoring `{UTC, zoned, floating}` | subtracting a wall instant from a monotonic one, or comparing a floating time to a zoned one, is refused; zones auto-convert | no |
| **Units / quantities** | the *unit / dimension* of a number | units grouped by dimension `{length, mass, time, …}` | dimensional algebra: `m + s` refused, `m + ft` converts, `m * m` = area. The runtime does real algebra on the scope | no |
| **Concurrency** | the *isolation / execution* scope a block runs in | `{isolated, synchronized, main-thread, actor}` | touching UI from a worker, or sharing a non-shareable value across scopes, is refused (Rust's `Send`/`Sync` is exactly this) | partial |
| **Memory** | the *ownership / lifetime* region a pointer belongs to | `{owned, borrowed, shared, arena, static}` | use-after-free and double-free become rejected operations; scope-exit frees automatically (the borrow-checker move) | no |

**These aren't hypothetical — two already bit this codebase.** Time's
clock-scope confusion is a *fixed defect*: `process_uptime` returned the
wall-clock since the Unix epoch (~56 years) where a *monotonic* scope was
required — a value from the wrong clock-scope filling a slot that demanded
another. Scope-typed time makes that unrepresentable. Memory's ownership gap is
*why* Ring's absent destructors leak cached engine handles: there is no scope to
bind a handle's lifetime to.

**What the cluster teaches the paradigm — a second carrier for M3.** Regex and
System are *site-scoped*: the frame is named at an act or region (`MatchLine`,
`App(:x).System()`) and governs the code inside it — you *enter a mode*. Time,
Units, and Memory are *value-scoped*: the frame rides the value (`Meters(5)`,
`MonotonicNow()`, `Owned(buf)`) and the library checks it at every operation
that *combines* values — you *type the data*. Concurrency does both (an
`OnMainThread { }` region, plus a value-carried `Send`/`Sync` mark). Both are the
one move — *name the frame at the call site, let the library reason with it* —
and this value-scoped form is what the candidate cluster contributes, the way
System contributed M5.

**A note on Concurrency specifically.** It is the one candidate whose frame
Softanza has so far chosen to *dissolve* rather than surface: the reactive layer
(Reaxis) runs on a single Ring thread with no call-site scheduler, deliberately
hiding the execution-context frame because at the ergonomic surface it is
accidental complexity, not a decision the programmer must own. The essential
isolation scope still exists — it lives in the reactor *beneath* Reaxis (which
loop, what may cross a thread boundary) — and that is where a scope-oriented
treatment of concurrency would belong, not on the declarative stream surface. A
useful reminder that M1's real question is *"is this frame an essential
decision, or noise to dissolve?"*

---

## 9. Why this is a paradigm, not a trick

A trick solves one field. Scope-Oriented Programming is a *transferable
diagnosis and cure*: the same disease (behavior with an invisible governing
frame) recurs across unrelated fields, and the same five moves resolve it every
time — with the fifth move switching on exactly when the host stops being
all-powerful. Regex proved the core (M1–M4). System programming proved the
extension (M5) and, in doing so, showed the paradigm is not about text at all.

The Softanza signature holds throughout: **intent over mechanics, made legible,
and handed to the library as something it can reason about — not left in the
programmer's head.**

---

### See also
- `stz-regexp-confusion-solved-deepdive.md` — the regex instance in full.
- `SOFTANZA_SYSTEM_FOUNDATION.md` — the system instance and its common-ground
  profile model.
- `Softanza Virtual System Framework.md` — the twin that makes M5's up-enable
  direction real.
