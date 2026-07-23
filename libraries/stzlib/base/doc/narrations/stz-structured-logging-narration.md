# Structured Logging with stzLog
### A log you can query while the program is still running

Most logging ends the same way: a wall of text, and a `grep` the next morning. The
trouble is that the moment you format an entry into a line, you throw away its
structure — the level, the category, the fields — and spend the rest of its life
trying to parse it back. `stzLog` keeps the structure. A log is a stream of
**records**, and while your program runs you *query* it: "how many errors?", "every
entry about `part=api`". This narration walks that. Every code block is real, and
every output block is its actual output.

---

## A log is a stream of leveled entries

```ring
oLog = new stzLog("deploy")
oLog.Info("build started")
oLog.Warn("low disk")
oLog.Record(:error, "compile failed", [ [ :part, "api" ], [ :code, 2 ] ])

? oLog.AsText()
```

```
1784766158766 INFO deploy: build started
1784766158766 WARN deploy: low disk
1784766158766 ERROR deploy: compile failed  {part=api, code=2}
```

`Info` / `Warn` / `Error` (and `Trace` / `Debug` / `Fatal`) are the everyday
shortcuts. `Record(level, msg, fields)` is the general form — it carries **fields**,
the structured context that turns a message into a queryable record. Every entry is
timestamped (epoch ms) and tagged with the log's category (`deploy`). Writes return
the log, so they chain: `oLog.Info("a").Warn("b")`.

## The structure is the point — query it

Because each entry is a record, the log answers questions directly, in the same
program, with no parsing:

```ring
? "errors: " + oLog.CountOfLevel(:error)
? "about the api part: " + len(oLog.Where(:part, "api"))
```

```
errors: 1
about the api part: 1
```

`CountOfLevel` / `EntriesOfLevel` count and filter by level; `Where(key, value)`
finds every entry carrying a field; `Since(ms)` slices by time; `LastEntry()` gives
the most recent. This is the difference from a text log: you interrogate it *as it
stands*, not after shipping strings somewhere and rebuilding the structure.

## A level threshold keeps production quiet

Levels are ordered — `trace < debug < info < warn < error < fatal` — and a
threshold (default `info`) drops anything below it:

```ring
oLog.Debug("verbose detail")     # dropped at the default info threshold -- nothing recorded
oLog.SetLevelQ(:trace)           # now trace/debug are recorded too
oLog.Debug("now visible")
```

So the same code logs `debug` freely; a production run at `info` ignores it, a
diagnostic run at `trace` keeps it — no call sites change.

## Render for humans, or for a pipeline

The text form is for reading. The JSON form is for shipping — fields become
**top-level keys**, so it drops straight into any log stack:

```ring
? oLog.AsJson()
```

```json
[
  { "ts": 1784766158766, "level": "info",  "category": "deploy", "message": "build started" },
  { "ts": 1784766158766, "level": "warn",  "category": "deploy", "message": "low disk" },
  { "ts": 1784766158766, "level": "error", "category": "deploy", "message": "compile failed", "part": "api", "code": "2" }
]
```

`WriteToFile` / `WriteJsonToFile` persist it; `SetEchoQ(TRUE)` also mirrors each
recorded entry to the console; `SetCapQ(n)` bounds memory with FIFO eviction.

## Where it earns its keep: the delivery plane

You don't have to reach for `stzLog` by hand to benefit — the delivery envelopes
keep their own structured logs. A production deploy is then an inspectable record,
not a flat list:

```ring
oDep = oDelivery.Deploy(:Production)      # drives the deployment, logging each step

oDep.Log().EntriesOfLevel(:error)         # what failed
oDep.Log().Where(:part, "api")            # the api part's whole story -- store, launch, verify
? oDep.Log().AsJson()                     # ship the run to your pipeline
```

A committed run logs each step `done` and ends `run complete`; a failed run logs the
failing step as an **error**, each rollback as a warning, and the whole thing stays
queryable by the failing part. The same holds for `stzDelivery.Deploy` (the phases),
`stzDeployment.Run` (the steps), and `stzPlatform.Build`/`Deploy` (build-by-language
and the governance refusals) — each exposes `Log()`.

---

*The log stopped being something you read after the fact and became something you
query during. "Every error about part=api" is a method call, not a regex over
yesterday's file.*

Runnable guard: `libraries/stzlib/base/test/common/log_narrated.ring` (20/20).
Design: [SOFTANZA_LOGGING.md](../design/SOFTANZA_LOGGING.md).
