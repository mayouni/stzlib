# Alignment — stzlib / StzEngine against the Softanza reference design

**Reference**: `softanza/REFERENCE_DESIGN.md` **v1.1** — ratified as v1.0 on
2026-08-08, amended 2026-08-10.
**Status**: obligations in force. **C1 delivered** (2026-08-10, v1.0) — see item 1.

## What stzlib owns in the reference design

The foundation's contracts: the **World Contract (C1)** — the highest-leverage piece of
the whole program — the engine's **C ABI statement**, and the host half of the **Actor
Contract (C5)**.

## What changes here

1. **C1 — define `world.json` and make stzGraph its engine.** One derived,
   language-neutral symbol artifact per project: symbol kind, name, type, declaring
   artifact + span, references out. stzGraph loads it as a knowledge graph; the same
   graph carries the read side (reference §5: ledger → graph → questions, with
   stzGraphQuery as the query surface). This gives the graph machinery its central,
   family-wide role.

   **✅ Delivered 2026-08-10 as v1.0**: [`contracts/world-contract.md`](contracts/world-contract.md)
   with [`contracts/world.schema.json`](contracts/world.schema.json) beside it, governed
   by the versioning discipline C2 uses — a version denotes one pair of files, and the
   substance test decides which component moves. The artifact is **two flat tables**,
   `symbols[]` and `refs[]`: the multiplicity of reference *sites* needs somewhere to
   live, and a nodes-table plus an edges-table is what a graph loads.

   The loader is [`libraries/stzlib/base/graph/stzWorldGraph.ring`](libraries/stzlib/base/graph/stzWorldGraph.ring)
   — it reads, refuses in the **C2 v1.0 envelope** (`language: "world"`), and hands back
   an ordinary `stzGraph`. It does not emit (emitting is each court's job) and does not
   query (`stzGraphQuery` already does). The read-side doctrine is one page,
   [`contracts/read-side.md`](contracts/read-side.md). Guard:
   [`libraries/stzlib/base/test/world/world_contract_narrated.ring`](libraries/stzlib/base/test/world/world_contract_narrated.ring),
   run from its own directory — a 13-symbol world across three artifacts, with every
   refusal asserted beside a sibling that must *not* fire.

   **Two divergences from the reference sketch**, to be carried back to
   `REFERENCE_DESIGN.md` in its own session:
   - *"declaring artifact + span" became one field.* C2's `span` already carries `file`;
     two spellings of one fact drift.
   - *Two symbol kinds added — `element` and `state`.* StzZui's `zui` verifier is the
     family's only shipped consumer of a symbol table, and its Level-3 checks read
     `entities`, `actors`, `state`, `elements`. A world artifact that cannot feed it
     would be a contract about nothing.

   **Two findings against this repository's own code**, recorded rather than worked
   around:
   - `stzGraph` is a **simple graph** — one edge per node pair, deliberately so per its
     own comment. A world hits this at once (one flow enforcing one norm at two steps).
     Resolved by grouping `refs` rows per pair into a single edge that carries every row:
     `world.json` is the truth, the graph is an index, and an index answers reachability,
     which is a property of the pair. **No change to stzGraph is proposed.**
   - The **engine's JSON bridge is flat** — `stz_json_get_string` reads scalar keys off a
     root object with no way to descend into an array of objects — so the house's
     engine-first rule could not be kept here and Ring's `JsonToList` is used. The
     artifact was kept flat so that one engine function (array-element-as-handle) closes
     the gap without touching the schema.
2. **The C ABI, stated as a contract.** One document naming the engine's public C ABI as
   its consumption surface for any language — the structural proof of "Ring-first, never
   Ring-only" at the foundation layer.
3. **C5, host half.** `stzAppServer` already mounts auth and OIDC; the addition is
   issuing **signed principal assertions** that runtimes bind to `ACTOR:` and Bedrock
   records carry. Format co-authored with Zing and RingServ; a decision doc, then code.
4. **Courts-consume-contracts (doctrine 4).** RingFlex's analyzer currently requires
   this repository's working directory. Export what it needs as a standalone artifact so
   a court consumes a contract, not a checkout.

## What must not change

The delivery plane's independence (D1 stands, sharpened as language posture: stzPlatform
is the Ring-native world envelope; Zing is the polyglot door). The no-dependency
doctrine ("engine + stzlib, nothing beyond"). stzlib decisions stay stzlib's.

## Order and gates

Item 1 was step 2 of the family sequence and four contracts lean on it — **done
2026-08-10**, which unblocks C3 (the Placement Contract) and, with C6, RingFace's
Phase 1. Items 2 and 4 are cheap and independent. Item 3 follows the Placement
Contract, since hosts are placements.

## Honest boundaries

The world schema is now this repository's, and it moved: the two divergences under item 1
are the owner exercising the reference design's own rule that the owner wins and the
reference follows. They are recorded here and are not yet carried back.

**No court emits `world.json` today.** stzlib defined the artifact and shipped a reader;
every writer is somebody else's work in somebody else's repository, and until the first
one lands the contract is proven only against a hand-written fixture. The loader's symbol
lookup is a linear scan — fine at thirteen symbols, wrong at ten thousand — and no world
of real size has been loaded.

Nothing in this file touches the engine's own roadmap or the open review question about
the MBaaS floor (`Expose()` vs the closed verb set), which stands separately.
