# Softanza Logging
### Logs as inspectable data — structured-first, queryable, leveled

> Status: built. `stzLog` in `base/common/` (alongside `stzCounter` /
> `stzLatencyHistogram` / `stzRateLimiter`). Wired into the delivery plane:
> `stzDelivery`, `stzDeployment`, and `stzPlatform` each expose `Log()`.
> Guard: `log_narrated` (20). Tutorial:
> [structured logging](../narrations/stz-structured-logging-narration.md).

---

## The thesis

Most logging is a stream of strings you later `grep`. Softanza's position is that a
log is **data**: a stream of timestamped, leveled, **structured** entries you write,
filter by level, **query by field**, and render as text *or* JSON. The question a
modern system actually asks is not "grep the file" but

> *give me every `error` in the `deploy` category where `part=api`.*

`stzLog` answers that directly, because every entry is a record — not a formatted
line — and the log is queryable while it's still in the process.

## The entry

Every entry is `[ :seq, :ts, :level, :category, :message, :fields ]`:

- **`:ts`** — epoch milliseconds (`StzEngineTimeNowMs`).
- **`:level`** — one of `trace < debug < info < warn < error < fatal`.
- **`:category`** — the log's name (e.g. `deploy`, `auth`).
- **`:message`** — the human line.
- **`:fields`** — the structured context, `[ [key, value], … ]`. This is what makes
  the entry queryable and the JSON useful.

## Writing

```ring
oLog = new stzLog("deploy")
oLog.Info("build started").Warn("low disk")               # leveled shortcuts, chainable
oLog.Record(:error, "compile failed", [ [:part,"api"], [:code,2] ])   # the structured form
```

`Trace` / `Debug` / `Info` / `Warn` / `Error` / `Fatal(msg)` are the no-field
shortcuts; `Record(level, msg, fields)` is the general structured write. Writes
return `This`, so they chain.

## The threshold

Levels are ordered, and a **threshold** (default `info`) drops anything below it:

```ring
oLog.Debug("verbose")          # dropped at the default info threshold
oLog.SetLevelQ(:trace)         # now debug/trace are recorded too
```

So production runs quiet at `info`/`warn` and a diagnostic run opens up to `trace`
— without touching a single call site.

## Query — the distinctive

Because entries are records, the log is a small queryable store:

```ring
oLog.CountOfLevel(:error)        # how many errors
oLog.EntriesOfLevel(:warn)       # just the warnings
oLog.Where(:part, "api")         # every entry tagged part=api
oLog.Since(nEpochMs)             # everything at/after a time
oLog.LastEntry()                 # the most recent
```

This is the whole point: you interrogate the log *as it stands*, in the same
program, rather than shipping strings elsewhere and reconstructing structure.

## Render — text for humans, JSON for pipelines

```
1784762967516 INFO deploy: build started
1784762967516 ERROR deploy: compile failed  {part=api, code=2}
```

```ring
? oLog.AsJson()
```
```json
[
  { "ts": 1784762967516, "level": "info",  "category": "deploy", "message": "build started" },
  { "ts": 1784762967516, "level": "error", "category": "deploy", "message": "compile failed", "part": "api", "code": "2" }
]
```

Fields are **inlined as top-level JSON keys**, so the output drops straight into any
log pipeline (ELK, Loki, a SIEM). `WriteToFile` / `WriteJsonToFile` persist it;
`SetEchoQ(TRUE)` also mirrors each recorded entry to the console; `SetCapQ(n)` bounds
retention with FIFO eviction.

## Wired into the delivery plane

Logs earn their keep: the envelopes keep their own structured logs, so a run is an
inspectable record instead of a flat list.

| Envelope | `Log()` records |
|---|---|
| `stzDelivery` | the deploy phases — `:emulated` build, `:production` start, commit-vs-rehearsal, outcome |
| `stzDeployment` | every plan step (`done`/`skipped`/`rehearsed`/**`FAILED`**), each rollback, the outcome — fields `[step, op, part]` |
| `stzPlatform` | build per part (by language), deploy per part, and the governance **refusals** as errors |

```ring
oDep = oDelivery.Deploy(:Production)
oDep.Log().EntriesOfLevel(:error)     # what failed
oDep.Log().Where(:part, "api")        # the api part's whole story
? oDep.Log().AsJson()                 # ship the run
```

## Two design decisions worth knowing

- **The core write is `Record`, not `Log`.** `log` is Ring's natural-logarithm
  builtin, and a method named `Log` shadows it (→ R20 at cold call sites). `Record`
  sidesteps the collision entirely.
- **No pluggable object sink.** A stored sink would be *copied* on assignment (Ring
  copies objects on attribute store), so an in-memory sink would accumulate writes
  on a copy the caller never sees. Rather than ship a subtly-broken hook, output is
  the log's own retention plus `AsJson` / `WriteToFile` — correct, and enough. (A
  file/network sink, whose state is external, could return as a copy-safe follow-on.)

## What modern logging needs — and where stzLog stands

| Requirement | stzLog |
|---|---|
| Levels + runtime filtering | ✅ six levels, `SetLevelQ` threshold |
| Structured / key-value logging | ✅ `:fields`, queried by `Where` |
| Machine-readable output (JSON) | ✅ `AsJson`, fields as keys |
| Query without leaving the process | ✅ the distinctive — `Where` / `EntriesOfLevel` / `Since` |
| Named categories | ✅ the log's name |
| Bounded memory | ✅ `SetCapQ` (FIFO) |
| Timestamps | ✅ epoch ms |
| Async / high-throughput sinks | ◐ retention + file output; a streaming sink is a follow-on |
| Correlation / trace ids | ◐ carry them as a field today (`[:trace_id, …]`); first-class is future |

---

*A log you can only read is half a tool. Here the log is a queryable record while
the program still runs — "every error about part=api" is a method call, not a
regex over yesterday's file.*
