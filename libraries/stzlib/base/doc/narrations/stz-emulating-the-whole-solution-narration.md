# Emulating the Whole Solution
### How Softanza runs every part of a multi-target product — for real — in a browser, before you deploy

Most stacks let you *run* a part in isolation and *simulate* the rest. You boot
the phone app in an emulator that talks to a mocked backend; you flash firmware to
a dev board wired to a fake sensor. Each simulation is a small lie, and the lies
compound: the mocked pivot table is not the one that ships, the stubbed solver
tells you nothing about the real one. You learn whether the *system* works only
after you've built, cross-compiled, flashed, and provisioned it onto real
hardware — the worst possible moment to find out.

Softanza takes a different position: **the emulator does not mock.** Every part
runs the *same compiled engine artifact that will ship to its target*. The phone's
pivot table in the browser is the pivot table that ships. The way it manages this
is a single idea — **compile the engine, not the interpreter** — and this
narration walks the whole thing end to end. Every code block is real, and every
output block is its actual output.

---

## One product, three kinds of machine

Meet *restolean*: a restaurant platform. A phone super-app for diners, a backend
that holds the menu and orders, and an ESP32 node in the kitchen driving a pump
and reading a moisture sensor. Three parts, three worlds — Android, a Linux
server, a microcontroller.

You describe the solution in one vocabulary — its parts, their targets, and the
Softanza capabilities each part's code uses:

```ring
oBrain = new stzBuilderBrain("restolean")
oBrain.WithSuperApp(:phone, :Android)
oBrain.WithBackend(:api, :LinuxServer)
oBrain.WithFirmware(:node, :ESP32)

oBrain.NeedsIn(:phone, [ :Unicode, :DateTime, :PivotTable, :ConstraintSolver, :Collection, :Neural, :Regex ])
oBrain.NeedsIn(:api,   [ :PivotTable, :Neural ])
oBrain.NeedsIn(:node,  [ :GPIO, :Pattern ])
```

Nothing is built yet. You have only *said what is true*.

## The brain rehearses — what runs where, and why

Before a byte is compiled, the brain **rehearses a placement plan**. For every
capability, on that part's target, it chooses how to deliver it and states the
reason — as inspectable text, not a decision hidden in code:

```ring
? oBrain.Plan().Explain()
```

```
Solution 'restolean' -- placement & scope plan (rehearsal; nothing built yet)
==============================================================================

  Part 'phone' [superapp] -> android (mobile / edge)
     Unicode            [target]    Unicode: the target-platform is strong at it -> use its own
     DateTime           [target]    DateTime: the target-platform is strong at it -> use its own
     PivotTable         [stz.wasm]  PivotTable: Softanza-differential, mobile weak -> the on-device engine
     ConstraintSolver   [stz.wasm]  ConstraintSolver: Softanza-differential, mobile absent -> the on-device engine
     Collection         [stz.js]    Collection: ergonomic -> a Softanza construct in the target language
     Neural             [server]    Neural: heavy -> runs on the backend, not the edge
     Regex              [stz.js]    Regex: ergonomic -> a Softanza construct in the target language
     -> stz.wasm carries: [ "PivotTable", "ConstraintSolver" ]  (~27 KB, 2 of 7)

  Part 'api' [backend] -> linuxserver (server)
     PivotTable         [engine]    PivotTable: the server hosts the native engine
     Neural             [engine]    Neural: the server hosts the native engine
     -> runs on the full native engine (server has everything)

  Part 'node' [firmware] -> esp32 (mcu / edge)
     GPIO               [firmware]  GPIO: Softanza-differential, mcu strong -> the on-device engine
     Pattern            [firmware]  Pattern: Softanza-differential, mcu weak -> the on-device engine
     -> firmware carries: [ "GPIO", "Pattern" ]  (~6 KB, 2 of 2)

  Summary: 11 capabilities across 3 parts -> target 2, engine 6, construct 2, server 1.
  Build() will compile exactly this scope; Deploy() will commit it.
```

Read the phone's block closely, because it *is* the doctrine:

- **Unicode, DateTime → `[target]`.** A browser is industrial-strength at these.
  Softanza ships *nothing*; it uses the platform's own. Re-shipping them would make
  the engine a convenience layer, and it is not one.
- **Regex → `[stz.js]`.** Same logic: JavaScript's `RegExp` is strong, so we do not
  compile PCRE2 to wasm. Softanza's differential value here is its *ergonomic API*,
  delivered as a construct over the platform's native regex.
- **PivotTable, ConstraintSolver → `[stz.wasm]`.** A browser has *no* pivot engine
  and *no* constraint solver. These are Softanza's edge — so they go on-device, as
  real compiled engine code.
- **Neural → `[server]`.** Too heavy for the edge; it runs on the backend.

The rule underneath is the **differential-value test**: the edge carries a
capability only if it is critical *and* (Softanza-unique *or* weak/absent on the
target). And notice the last line of the phone's block: `stz.wasm carries only 2
of 7` capabilities. The edge is *scoped*, not the whole engine.

## The edge carries only what the part uses

That scoping is literal. The phone's on-device engine is compiled to contain
*exactly* the two capabilities it places there — nothing else:

```ring
oPlan = oBrain.Plan()
? "engine caps: " + @@( oPlan.EngineCapsFor(:phone) )
? "wasm groups: " + @@( StzWasmGroupsFor( oPlan.EngineCapsFor(:phone) ) )
```

```
engine caps: [ "pivottable", "constraintsolver" ]
wasm groups: [ "aggregation", "solver" ]
```

Those two groups — and no others — are what `zig build wasm` compiles for the
phone. The engine's `build.zig` takes the subset as a build option:

```
zig build wasm -Dwasm-groups=solver,aggregation   ->  stz_phone.wasm  (9.6 KB)
```

A different part with different needs gets a different, smaller module. In the full
restolean, the frontends fan out — a kiosk that only pivots, a waiter tablet that
detects order patterns, an admin browser that walks a supplier graph — and each
ships its own subset:

| part | its `[stz.wasm]` capabilities | subset shipped | size |
|---|---|---|---|
| phone | PivotTable, ConstraintSolver | aggregation + solver | 9.6 KB |
| kiosk | PivotTable | aggregation | 8.6 KB |
| waiter | Pattern | pattern | 10.6 KB |
| admin | PivotTable, Graph | aggregation + graph | 14.6 KB |

The kiosk never carries the solver. The solver *code* is not in its module.

## Deploy to the emulator — the whole solution, alive

Now you run it — not on a device, in your browser:

```ring
oBrain.Deploy(:Emulated)
```

This generates a self-contained web **mission-control**: a parts grid grouped by
role (Frontends / Backends / Edge devices), each part's placement + fidelity
detail beside it, and one maximized *device window* per part. The bundle ships
each frontend's own `stz_<part>.wasm` subset, a small `stz.js` bridge, and a plan
map (`stz_parts.js`) that tells each window which subset to load.

Open the phone's window and you get the real app — a diner ordering couscous and
mint tea — with a live log and a **console that runs the phone's real engine**:

```
> solve 2 -8
  stz.wasm . solve 2x + (-8) = 0  ->  x = 4
> mean 12 19 6 3 5
  stz.wasm . mean([12, 19, 6, 3, 5]) = 9
```

That `x = 4` came out of the *same solver Zig code that backs the native DLL*,
compiled to wasm, running in the page. Not a mock. Not a stub. The engine.

## The subset is visible — a part can only do what it carries

Open the **kiosk** window. Its subset is `aggregation` only — it pivots, but it
does not solve. The console proves it:

```
> mean 10 20 30
  stz.wasm . mean([10, 20, 30]) = 20
> solve 1 -5
  solve is not in this part's engine subset (aggregation)
```

The kiosk *cannot* solve, because the solver was never shipped to it — and the
emulator tells you so plainly rather than faking a number. Emit only what the part
uses, and the part can only do what it was given.

## Real pattern, real graph — the edge is the actual engine

The **waiter** tablet carries the `pattern` subset. Its console detects real
sequence structure — is a run of order counts arithmetic? a run of prices
geometric? is a code a palindrome? — all in wasm:

```
> arith 2 4 6 8
  stz.wasm . arith([2, 4, 6, 8]) = yes, diff 2
> palindrome level
  stz.wasm . is_palindrome("level") = yes
> geo 3 9 27
  stz.wasm . geo([3, 9, 27]) = yes, ratio 3
```

The **admin** browser carries `aggregation + graph`. Its console builds a real
directed graph and walks it — nodes, edges, reachability — via the engine's graph
module running on a wasm allocator:

```
> graph demo
  stz.wasm . graph a->b->c: 3 nodes, 2 edges, path a->c = yes
```

Three different frontends, three different real engines, each exactly the size of
what it needs.

## From emulation to production — the same parts, committed

When it works in the emulator, it works — because emulation and production run the
same artifact. The second phase of the same verb commits it:

```ring
oBrain.Deploy(:Production)
```

The plan the brain rehearsed *is* the production spec. The phone's
`aggregation + solver` wasm crosses the governed bridge to the real Android app;
the node's `GPIO + Pattern` firmware flashes to the ESP32; the backend runs the
full native engine. Nothing is re-decided. "It worked in emulation" and "it works
in production" are the same sentence, because they were always the same code.

---

That is the whole point of the emulator: the entire multi-target solution comes
alive *during programming* — every part running its real, differential engine, at
exactly its own scope — so the gap where "it worked on my machine" is born simply
never opens.
