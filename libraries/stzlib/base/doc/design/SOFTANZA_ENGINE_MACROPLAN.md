# Softanza Engine -- Macro Plan

> **Living document.** Updated at every progress milestone.
> Cross-reference: `base/doc/internals/SESSION_CONTINUITY.md`
> for per-session details.

---

## Status Summary

| Metric            | Value                    |
|-------------------|--------------------------|
| Modules designed  | 88                       |
| Modules built     | 11                       |
| Design principles | 19                       |
| Engine tests      | 40 passing               |
| DLLs shipping     | 8 (4 Core + 4 Base)      |
| Qt dependencies   | 0 (fully purged)         |
| Last updated      | 2026-05-15 (Session 4b)  |

---

## ACHIEVED

### Phase 1 -- Layer Audit & Architecture (Session 1)

- Three-layer audit (Core/Base/Max/Future) completed
- Fixed Max loader (10 duplicate loads removed)
- Layer architecture contract established
- Engine design doc created

### Phase 2 -- Engine Bootstrap: 11 modules DONE (Sessions 1-2)

| Module       | Functions | Replaces              |
|--------------|----------:|-----------------------|
| stz_string   |        20 | QString2              |
| stz_char     |         6 | QChar                 |
| stz_bytes    |         — | Binary data           |
| stz_datetime |        50 | QDate/QTime/QDateTime |
| stz_file     |        17 | QFile/QDir/QFileInfo  |
| stz_locale   |        10 | QLocale               |
| stz_regex    |         — | QRegularExpression    |
| stz_json     |         — | QJsonDocument         |
| stz_url      |         — | URL parsing           |
| stz_system   |         — | System info           |

8 DLLs built (Core + Base tiers). 40 tests passing.

### Phase 3 -- Qt Purge (Session 2)

- ALL Qt code paths removed from Core and Base
- Engine-only: no fallback, no feature flags, no Qt dependency
- Ring FFI bridges wired per domain

### Phase 4 -- Modular DLLs + CLI (Session 3)

- Split monolithic Engine into per-domain DLLs
- Layered DLLs: stk_* (Core) / stz_* (Base) / stx_* (Max, future)
- Softanza CLI: `version`, `doctor`, `help`, `run`, `test`, `build`

### Phase 5 -- Deep Design: 86 -> 88 modules (Sessions 4, 4b)

- Full audit of 60+ paradigm documents + 10 source implementations
- Layer 5: 12 Paradigm Engines designed with full C ABI
- Layer 6: 14 Universal Computation modules designed with full C ABI
- 3 Value Propositions codified: Testability, Usability, Learnability
- 2 VP modules added: stz_interact, stz_skill
- 19 design principles in Architecture doc

---

## MILESTONES AHEAD

### M-E1: Foundation Types [ ]

> Build `stz_value` (StzValue tagged union) + `stz_number`
> (BigInt, Decimal, 64-bit).

**Why first:** Every module above Layer 0 depends on StzValue.
This kills the Stringify trick and unlocks heterogeneous
collections.

**Deliverables:**
- `engine/src/value.zig` with tagged union + C ABI
- `engine/src/number.zig` with BigInt + Decimal
- Ring FFI bridges for both
- Tests at all 4 layers

### M-E2: Core Collections [ ]

> `stz_list` (heterogeneous dynamic array), `stz_hashmap`,
> `stz_set`.

**Why:** Lists are Softanza's most-used structure. HashMap
enables named-parameter dispatch. Set enables unique-element
operations.

**Depends on:** M-E1 (StzValue)

### M-E3: Extended Collections [ ]

> `stz_table`, `stz_graph`, `stz_matrix`, `stz_tree`.

**Why:** Targets for the universal operations paradigm
(Find/Replace/Contains work on ALL structures).

**Depends on:** M-E2 (List, HashMap)

### M-E4: Algorithms [ ]

> `stz_stats`, `stz_text`, `stz_walker`, `stz_checker`,
> `stz_yielder`, `stz_performer`.

**Why:** Walker replaces all index-based loops. Text and stats
are high-frequency. Checker/Yielder/Performer complete Ring
workaround elimination.

**Depends on:** M-E2 (collections)

### M-E5: Infrastructure Services [ ]

> 25 modules: crypto, codec, compress, stream, watch, process,
> async, uuid, html, rng, solver, geo, bits, expr, embed,
> registry, smallfn, execmodel, cache, log, profiler, callstack.

**Why:** Plumbing that signature features and paradigm engines
build on. Stream and async are prerequisites for Reaxis.

**Depends on:** M-E1 (StzValue), partially M-E2

### M-E6: Signature Features [ ]

> 11 modules: pattern, numtheory, natlang, ccode, constraint,
> reactive, knowgraph, splitter, stringart, display, univops.

**Why:** What makes Softanza unique at the feature level --
PatternEx family, natural language bridge, universal operations,
display engine.

**Depends on:** M-E4 (algorithms), M-E5 (infrastructure)

### M-E7: Paradigm Engines [ ]

> 12 modules: reaxis, softanzuter, truth, quantifier, polyglot,
> polycode, adverb, timeline, gridnav, sectmerge, deepops,
> namedvars.

**Why:** The innovations. Reaxis replaces reactive programming.
Softanzuter is the agent substrate. Truth is domain-configurable.
Each one is a concept rethought from first principles.

**Depends on:** M-E6 (signature features)

### M-E8: Universal Computation [ ]

> 14 modules: provenance, confidence, explain, similarity,
> context, resource, validator, schema, intent, embedding,
> sequence, topology, relations, statemachine.

**Why:** General-purpose concerns every programmer needs. These
make AI natural without AI-specific modules.

**Depends on:** M-E5 (infrastructure), M-E7 (paradigm engines)

### M-E9: Value Proposition Modules [ ]

> `stz_interact` (Interaction Engine), `stz_skill` (Skill Engine).

**Why:** Testability is enforced by the build system from M-E1
onward. Interaction and Skill modules complete the Engine's
three promises.

**Depends on:** M-E8 (universal computation)

### M-E10: CLI Polish + Ring Bridge Completion [ ]

> `softanza build` (per-module), `softanza test` (narrated test
> runner), `softanza doctor` (full diagnostic), `softanza skills`
> (assessment). Ring FFI bridges for all 88 modules.

**Depends on:** M-E9

### M-E11: Repository Split [ ]

> Extract `softanza-engine` as standalone repo. stzlib becomes
> one client. Ship C headers, CLI, and language-neutral docs.

**Deferred** until API surface is stable and battle-tested.

---

## Dependency Graph

```
M-E1 (StzValue + Number)
  |
  v
M-E2 (List + HashMap + Set)
  |
  v
M-E3 (Table + Graph + Matrix + Tree)
  |          \
  v           v
M-E4         M-E5
(Algorithms) (Infrastructure)
  |           |
  +-----+-----+
        |
        v
M-E6 (Signature Features)
        |
        v
M-E7 (Paradigm Engines)
        |
        v
M-E8 (Universal Computation)
        |
        v
M-E9 (VP Modules)
        |
        v
M-E10 (CLI + Bridges)
        |
        v
M-E11 (Repo Split)
```

---

## Progress Log

| Date       | Session | Milestone | What changed                     |
|------------|---------|-----------|----------------------------------|
| 2026-05-13 | 1       | Phase 1-2 | Audit + bootstrap 11 modules     |
| 2026-05-13 | 2       | Phase 3   | Qt purge + Tier 2-3 modules      |
| 2026-05-14 | 3       | Phase 4   | Modular DLLs + layered tiers + CLI|
| 2026-05-15 | 4       | Phase 5   | 86 modules designed, 16 principles|
| 2026-05-15 | 4b      | Phase 5+  | 88 modules, 19 principles, 3 VPs |
