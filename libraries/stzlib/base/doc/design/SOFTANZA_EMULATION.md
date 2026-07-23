# The Softanza Emulation Technology
### `Deploy(:Emulated)` — the whole multi-target solution, running for real, in a browser

> Status: built. Components: `stzDelivery`, `stzBuildPlan`, `stzEmulator`,
> `stzBuilder` (the `wasm` target), `stz.wasm` / `stz.js`, `stzAppTopology`
> (the per-part app model) and `stzAppBackend` (live + REMOTE cross-part state, §9).
> Guards: `delivery_narrated`, `wasm_narrated`, `emulator_narrated`,
> `62_app_backend_narrated`, `63_app_backend_remote_narrated`.
> Tutorial: [stz-emulating-the-whole-solution-narration.md](../narrations/stz-emulating-the-whole-solution-narration.md).
> Part of the [Softanza delivery plane](SOFTANZA_DELIVERY_PLANE.md).

---

## 1. The problem: deployment is where confidence goes to die

A real product spans machines. A phone app ships to Android; a backend deploys to
a Linux server; firmware flashes to a microcontroller. During development you see
each part alone, in isolation, on your laptop — never the **whole system running
together**. You find out whether it actually works at the worst possible moment:
after you've built, cross-compiled, flashed, and provisioned it onto real
hardware.

Teams paper over this with **simulators** — but simulators *lie*. They mock the
database, stub the device, approximate the compute. "It runs in the simulator"
and "it runs on the device" are different claims, and the gap between them is
exactly where the expensive bugs live. A simulated pivot table is not the pivot
table that ships; a mocked solver tells you nothing about the real one.

So the emulation question is not "can we *show* the system?" It is: **can each
part run its *real* engine, before it leaves the editor?**

## 2. The thesis: emulate for real — *compile the engine, not the interpreter*

Softanza's answer is that the emulator does not mock. Every part runs the **same
compiled engine artifact that will ship to its target**. The phone's pivot table
in the emulator is the pivot table that ships; the MCU's pin logic is the pin
logic that flashes.

The enabling insight is **compile the engine, not the interpreter**. To run a
Softanza part in a browser, you do *not* ship a Ring VM and interpret the app in
the page. You ship the **engine's differential compute as WebAssembly**
(`stz.wasm`) — the *same Zig logic* that backs the native DLLs, recompiled for
`wasm32` — plus a thin `stz.js` bridge. The browser runs real engine code.

The payoff is a contract you can trust: **what works in emulation ships as-is**,
because emulation and production run the same artifact.

## 3. `Deploy()` is dual-phase — the deploy scope is the frame

Deployment is modeled Scope-Orientedly: the *phase* is a named scope, and one verb
serves both.

```ring
oDelivery.Deploy(:Emulated)     # the PROGRAMMING phase
oDelivery.Deploy(:Production)   # the COMMIT phase
```

- **`:Emulated`** — the programming-phase face. The whole solution becomes a
  web-based **mission-control** where each part runs its real engine and is
  debugged visually, part by part. This is where you *live* while building.
- **`:Production`** — the same parts cross the governed bridge to real targets.
  The plan the delivery planner rehearsed **is** the production spec that the
  lowering/platform path executes. Nothing is re-decided; emulation was the
  rehearsal, production is the commit.

## 4. What runs where: differential-value placement

Before a byte is built, the delivery planner (`stzDelivery`) **rehearses a placement &
scope plan**. For every capability a part uses, on that part's target, it picks a
*delivery vector* and states *why* — as inspectable data, not a heuristic buried
in code.

The governing rule is the **differential-value test**:

> The edge carries a capability only if it is *critical* **and**
> (*Softanza-unique* **or** *weak/absent on the target platform*).

A browser is industrial-strength at Unicode, dates, JSON, HTTP, and **regex** — so
Softanza uses the platform's own. A browser has no constraint solver, no pivot
engine, no sequence-pattern analysis — so *those* go on-device. The engine is
Softanza's **edge**, not a convenience layer that re-ships what the platform
already does well.

**Four delivery vectors**, inclusive across targets:

| Vector | Label on the edge | Meaning |
|---|---|---|
| `native` | `[target]` | the platform does it well — ship nothing (a browser's Unicode) |
| `engine` | `[stz.wasm]` / `[firmware]` / `[engine]` | Softanza-differential compute, in the target's on-device form |
| `construct` | `[stz.js]` | an ergonomic Softanza construct in the target's language |
| `server` | `[server]` | too heavy for the edge → runs on the backend |

The same capability lands differently per target — this is Scope-Oriented
Programming's third instance, with the **target platform** as the invisible frame
(see [SCOPE_ORIENTED_PROGRAMMING.md](SCOPE_ORIENTED_PROGRAMMING.md) §7). The plan
is legible; `Plan().Explain()` prints the whole rationale:

```
  Part 'phone' [superapp] -> android (mobile / edge)
     Unicode            [target]    Unicode: the target-platform is strong at it -> use its own
     DateTime           [target]    DateTime: the target-platform is strong at it -> use its own
     PivotTable         [stz.wasm]  PivotTable: Softanza-differential, mobile weak -> the on-device engine
     ConstraintSolver   [stz.wasm]  ConstraintSolver: Softanza-differential, mobile absent -> the on-device engine
     Collection         [stz.js]    Collection: ergonomic -> a Softanza construct in the target language
     Neural             [server]    Neural: heavy -> runs on the backend, not the edge
     Regex              [stz.js]    Regex: ergonomic -> a Softanza construct in the target language
     -> stz.wasm carries: [ "PivotTable", "ConstraintSolver" ]  (~27 KB, 2 of 7)
```

Note *Regex → `[stz.js]`*: its differential value on the web is its ergonomic API,
delivered as a construct over the platform's native `RegExp` — **never** PCRE2
compiled to wasm. The doctrine holds even for capabilities Softanza implements
richly.

## 5. Emit only the per-part engine subset

The engine artifact for a part carries **only the capabilities that part uses** —
not one fixed bundle. The `build.zig` `wasm` step is parameterized:

```
zig build wasm -Dwasm-groups=solver,aggregation
```

`stz_wasm_entry.zig` reads the group list at *comptime* and conditionally
`@import`s the source modules and `@export`s the wrappers, so an unused group's
code is **not in the compilation at all** — a true subset, not a gated surface.
The delivery planner drives it: a capability maps to an engine group
(`ConstraintSolver → solver`, `PivotTable → aggregation`, `BigNumber → numtheory`,
`Pattern → pattern`, `Graph → graph`), and each part's `[stz.wasm]` capabilities
become its build subset.

Measured (the same numeric edge, different subsets):

| subset | groups | size |
|---|---|---|
| full | solver + aggregation + numtheory + pattern + graph | 12.5 KB |
| phone | aggregation + solver | 9.6 KB |
| kiosk | aggregation | 8.6 KB |
| waiter | pattern | 10.6 KB |
| admin | aggregation + graph | 14.6 KB |

A part that only pivots never carries the solver. The solver *code* is not shipped
to it.

## 6. The emulator surface

`Deploy(:Emulated)` generates a self-contained web bundle — a calm, standard
**mission-control**, because deployment is a high-friction moment and the UI's job
is to make it legible:

- A **parts grid** (left) grouped by role — Frontends / Backends / Edge devices —
  with role filters; the selected part's **placement + fidelity** detail (right).
- One **maximized device window** per part: the device on the left (the phone runs
  the real app, the backend shows its endpoints, the board shows its pins), a
  **live log + query console** on the right.
- **The console runs the real engine.** Each frontend part loads *its own*
  `stz_<part>.wasm` subset; the console's verbs are backed by it, and a verb whose
  function is not in that part's subset says so instead of faking a result.
- One health-gated terminal action — **Deploy to production** — styled as the
  critical, irreversible act it is.

The device windows run real engine calls, not rehearsed values: type `solve 2 -8`
and the phone's `stz.wasm` returns `x = 4`; type `graph demo` and the admin's graph
subset runs a real BFS. See the tutorial for the full walk-through.

## 7. The fidelity contract — honest colour

Emulation is faithful, but not omniscient, so it says which is which. Each part
declares:

- **Faithful** — the logic (same engine artifacts), the capability rules, the
  protocol, the data.
- **Approximated** — *named*. An MCU flags that pump timing and sensor noise are
  approximated and must be validated on the bench.

The colour is calm and honest: healthy / live / needs-a-look. The emulator never
implies more certainty than it has.

## 8. Architecture

```
  stzDelivery              describe the solution: parts, targets, capabilities
        |  .Plan()
        v
  stzBuildPlan             the rehearsed placement & scope plan (per-part vectors,
        |                  reasons, the on-device engine subset) -- Explain()
        |  .Deploy(:Emulated)
        v
  stzEmulator              generate the web mission-control bundle:
        |                    index.html + emulator.css/js  (the surface)
        |                    stz_<part>.wasm               (per-part engine subset)
        |                    stz_parts.js + stz.js         (the plan map + bridge)
        |                    app_<part>.html               (each frontend's app)
        v
  stzBuilder (wasm target) `zig build wasm -Dwasm-groups=...` compiles the real
                           engine (numtheory/solver/pattern/graph .zig) to stz.wasm
```

The build system (`stzBuilder`) is the same one that cross-compiles C and Ring
parts for native targets; the web is simply a **composite target** — wasm + a
bridge + a shell — and the wasm is the engine, not the interpreter.

## 9. Live cross-part state — the parts stop being islands

Everything above makes each part run *its own* real app. But `stzAppTopology`
holds its datasets as **static in-memory lists**, so every part read a private,
frozen copy of the model: an order "created" on the phone never reached the
admin's dashboard. The solution was a set of islands, and the emulator could
only ever render a rehearsal.

**`stzAppBackend`** (`base/appserver/`) closes that. It is the solution's live
backend: it materialises the model's datasets as real **sqlite** tables, serves
them over a **real running `stzAppServer`**, and lets parts read and write over
**real HTTP**. What one part writes, another sees — because there is now exactly
one copy of the state and it lives outside them both.

```ring
oB = new stzAppBackend("restolean", oTopology)
oB.Start(0)                                                    # ephemeral port

oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
? oB.Dashboard(:admin)[2]      #--> 39 -- the admin SEES the phone's order
```

**The load-bearing proof.** The admin's dashboard total is computed by the engine
(`stzTable.SumCol` / `MaxColumn` — its declared `:PivotTable`, for real) and it
*changes because another part wrote*: 15 → 39 (15 + 12×2), and the top dish flips
to Couscous. Meanwhile the topology still holds the single order it was declared
with — the state has genuinely **left the model**.

**Why sqlite is the substrate** (the load-bearing design choice). Ring copies
objects on `=`, so shared state held in a Ring attribute fragments into private
copies — the trap that killed the `stzLog` object sink and forced
`stzSecretStore`'s by-reference reveal. A `stzDatabase` is immune: its sqlite
connection is an **engine handle**, so a copied wrapper still addresses the
*same* database. The **model** is copied on purpose (it is a static snapshot);
only the **state** has to be shared.

**One process, both ends.** A second `stzReactor` plays the parts' HTTP client:
`SubmitTcp` (non-blocking) → `ServeOne` → `AwaitTcp`. A round trip is genuinely
framed HTTP over the loopback, through the MBaaS floor, into real sqlite — with
no deadlock and no public network. Offline by construction.

**Governed like every other crossing.** A cross-part write is an effect, so it
obeys the library's one rule — *expression is free; admission is governed*.
`SetActorQ` binds the acting actor and only an effectful one may commit: an
`LLMActor` reads the whole solution and writes none of it, and the refusal is
**audited, not silent**. Every crossing lands in `Traffic()` with its real HTTP
status, so who-wrote-what-across-parts is inspectable the way `stzSecretStore`
audits reveals.

### 9b. The backend leaves the process — remote backends

The above is honest but incomplete: the server, the sqlite and the parts' client
all shared one Ring interpreter. A backend is something the parts do **not**
contain. So `stzAppBackend` has two modes behind **one API**:

```ring
oB.Start(0)                          # LOCAL  -- this process owns the state
oB.ConnectTo("127.0.0.1", 8531)      # REMOTE -- it lives somewhere else

oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
? oB.Dashboard(:admin)[2]            # ...identical from here on
```

**Location transparency is the point.** The remote guard and the local guard
assert *the same numbers through the same calls*. Part code never learns where
its backend lives.

The difference is confined to `_Roundtrip`. **Local** pumps its own server
between submit and await, because nothing else will. **Remote** must *not* pump
— the far process runs its own loop, so the client is a curl-backed
`SubmitHttp`/`AwaitHttp` that blocks on the wire. Pumping a server you do not
own is precisely the bug the seam exists to prevent. (Status likewise: the raw
status line locally; `HttpLastStatus` guarded by a **drain check** remotely,
since that global goes stale on a timeout and would otherwise report a previous
request's 200.)

**Hosting one.** `SpawnRemote(port, ttl)` serialises the model, generates a host
script — with an absolute `stzBase` load, so the child's working directory
cannot matter — and launches a real `ring` child that `Start()`s and `Serve()`s
the backend; `WaitReady()` polls `/health` until it answers. The guard is
therefore **two operating-system processes, one socket, one sqlite**: the phone
client POSTs an order, and a *separate* admin client object sees the count go
1 → 2 and the engine-computed total 15 → 39.

The model crosses with **type tags** (`n`/`s`) rather than being sniffed on the
way back in — a price must stay numeric for the revenue maths, and "looks
numeric" is how `"007"` silently becomes `7`. Fields are percent-escaped with
`%25` decoded **last**, so an escaped percent can never be re-read as an escape.

*Known limits, stated plainly:* the curl client submits GET and POST only, so
the remote surface is the part-facing API (`Create`/`Rows`/`RowCount`/
`Dashboard`), not the MBaaS `PUT`/`DELETE` item routes. A remote backend's
sqlite is reachable only through HTTP — which is the entire point.

## 10. How it is verified

- `delivery_narrated` — the placement doctrine (differential test; the
  per-part subset; regex defers to the platform).
- `wasm_narrated` — the `build.zig` wasm target builds; the entry exports the
  curated ABI; a subset is genuinely smaller than the full edge.
- `emulator_narrated` — the bundle is a clean web app; the plan map names each
  part's own subset; the console gates verbs by it.
- `62_app_backend_narrated` (28) — the live backend: the phone's write moves the
  admin's engine-computed total; the model stays untouched; the LLM actor is
  refused and audited; a non-ASCII dish name survives HTTP → sqlite → JSON.
- `63_app_backend_remote_narrated` (31) — the backend as a **separate OS
  process**: the model crosses intact (separator, newline, percent, numeric
  type), one client writes and another *sees* it over the socket, governance
  still refuses the LLM actor, and the final scenario asserts the identical
  numbers in local mode — location transparency, proven rather than claimed.
- **In-browser** — real computation proven: `gcd(48,36)=12`, `solve 2x−8=0 → x=4`,
  `mean([10,20,30,40])=25` through the marshalling ABI, a real graph BFS via the
  wasm allocator. The engine runs in the browser.

---

*The emulator is where the whole solution comes alive during programming — every
part running its real, differential engine — so that "it worked in emulation" and
"it works in production" are the same sentence.*
