# Alignment — stzlib / StzEngine against the Softanza reference design

**Reference**: `softanza/REFERENCE_DESIGN.md` v0.1 (draft, unratified) · 2026-08-08
**Status**: obligations-if-ratified. Written from outside; this repository's own
process decides.

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

Item 1 is step 2 of the family sequence and four contracts lean on it — it is this
repository's priority after ratification. Items 2 and 4 are cheap and independent.
Item 3 follows the Placement Contract, since hosts are placements.

## Honest boundaries

The world schema sketch is the reference design's, not yet this repository's; defining
it here may change it, and the reference design follows the owner. Nothing in this file
touches the engine's own roadmap or the open review question about the MBaaS floor
(`Expose()` vs the closed verb set), which stands separately.
