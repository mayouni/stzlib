# stzTimex: A Pattern Language for Time in Softanza

## Introduction

Working with time in code is often a tangle of arithmetic and conditions — subtracting timestamps, looping through events, comparing durations, checking overlaps. The logic sprawls, becomes brittle, and hides intent.

Softanza, through **stzTimex** changes that. Instead of writing procedural logic, you _describe_ what should happen using a simple regex-like _pattern_ language. The system does the rest.

For example, a meeting followed by a 30-minute break can be written as:

```
{@Event(Meeting) -> @Duration(30m) -> @Event(Break)}
```

No loops. No variables. Just intent.

This declarative approach feels different at first — less control, more trust — but it brings shorter code, clearer meaning, and far greater flexibility.

Below, you’ll see how `stzTimex` expresses every form of temporal logic using simple patterns.

---

## Temporal Objects at the Core

`stzTimex` doesn’t live in isolation. It works hand-in-hand with three Softanza classes that represent time:

* **stzDateTime** — an exact moment (e.g. `"2025-10-22 14:30:00"`).
* **stzDuration** — a span of time (e.g. `"1 hour 30 minutes"`).
* **stzTimeLine** — a sequence of events or spans, built with `.AddInstant()` and `.AddSpan()`.

You build your temporal data using these classes, then hand it to `stzTimex`.
The engine normalizes it internally — turning dates into instants, spans into durations, and timelines into ordered sequences — so you never worry about conversions or boundaries.


## The Pattern Language of Time

A stzTimex pattern is a string enclosed in braces:

```
{@Instant}
{@Duration(1h..2h)}
{@Event(Meeting) -> @Duration(30m) -> @Event(Break)}
```

Each token describes what to find:

* `@Instant` an exact timestamp
* `@Duration` a time span or interval
* `@Event` a labeled occurrence within a timeline

And a few simple operators express structure:

* `->` “followed by”
* `*` “zero or more gaps”
* `|` “or” (alternative sequences)

Two matching modes exist:

* **`Match()`** The data must fit the pattern *exactly*.
* **`MatchPartial()`** The pattern may appear *anywhere* inside the data.


## Single Instants: Recognizing a Moment

A basic use case is to match one precise point in time.

```ring
Tx = Tx("{@Instant}")
? Tx.Match(StzDateTimeQ("2025-10-22 14:30:00"))     #--> TRUE
? Tx.MatchPartial(StzDateTimeQ("2025-10-22 14:30:00")) #--> TRUE
```

Both calls succeed — confirming the timestamp’s existence.
This is ideal for checking logs, deadlines, or single-event triggers.


## Duration Rules: Validating Time Spans

Durations can carry constraints — minimum, maximum, and step.

```ring
oDur1 = new stzDuration("1 hour 30 minutes")
oDur2 = new stzDuration("1 hour 20 minutes")

Tx = new stzTimex("{@Duration(1h..2h:15min)}")

? Tx.Match(oDur1)  #--> TRUE
? Tx.Match(oDur2)  #--> FALSE
```

Here, 90 minutes fits perfectly (between 1h and 2h, in 15-minute steps),
whereas 80 minutes violates the rule.
Great for reservation systems or scheduling grids.


## Event Sequences: Detecting Order in a Timeline

Timelines represent a day’s or process’s flow of events.
You can express expected sequences directly.

```ring
oTimeline = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline.AddPoint("Meeting", "2025-10-22 09:00:00")
oTimeline.AddSpan("Break", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline.AddPoint("Lunch", "2025-10-22 12:00:00")

Tx = new stzTimex("{@Event(Meeting) -> @Duration* -> @Event(Break)}")

? Tx.Match(oTimeline)        #--> FALSE
? Tx.MatchPartial(oTimeline) #--> TRUE
```

`Match()` fails because extra elements (“Lunch”) exist.
`MatchPartial()` succeeds, identifying the required subsequence.
Perfect for log verification and workflow auditing.


## Full-Day Validation: Matching the Whole Flow

You can also verify an entire day or process from start to end.

```ring
oTimeline2 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline2.AddPoint("Start", "2025-10-22 09:00:00")
oTimeline2.AddSpan("Work", "2025-10-22 09:00:00", "2025-10-22 17:00:00")
oTimeline2.AddPoint("End", "2025-10-22 17:00:00")

Tx = new stzTimex("{@Event(Start) -> @Duration* -> @Event(Work) -> @Duration* -> @Event(End)}")

? Tx.Match(oTimeline2)  #--> TRUE
```

The asterisk (`*`) allows unspecified gaps — making this pattern useful for validating full shifts, work cycles, or process continuity.


## Exact Gaps: Enforcing Specific Intervals

When precise timing matters, durations can act as strict separators.

```ring
oTimeline3 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline3.AddPoint("A", "2025-10-22 09:00:00")
oTimeline3.AddPoint("B", "2025-10-22 09:30:00")

Tx = new stzTimex("{@Event(A) -> @Duration(30m) -> @Event(B)}")

? Tx.MatchPartial(oTimeline3)  #--> TRUE
```

Change `30m` to `1h`, and the match fails.
Useful for mandatory cooldowns, inspection gaps, or process delays.


## Event Durations: Controlling How Long an Event Lasts

Each event can include its expected duration directly in the pattern.

```ring
oTimeline5 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline5.AddSpan("Session", "2025-10-22 09:00:00", "2025-10-22 10:00:00")

Tx = new stzTimex("{@Event(Session:30m)}")

? Tx.Match(oTimeline5)  #--> FALSE
```

The session lasted 60 minutes, not 30 — a violation.
This helps detect overruns in meetings, productions, or timed operations.


## Flexible Gaps: Allowing Any Interval

Sometimes, the presence of a delay matters less than its duration.

```ring
oTimeline6 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline6.AddPoint("Start", "2025-10-22 09:00:00")
oTimeline6.AddPoint("End", "2025-10-22 17:00:00")

Tx = new stzTimex("{@Event(Start) -> @Duration* -> @Event(End)}")

? Tx.Match(oTimeline6)  #--> TRUE
```

This pattern remains true whether the gap is minutes or hours — ideal for loose or asynchronous timelines.


## Adjacent Events: Ensuring Continuity

When two tasks should follow immediately, you omit the duration.

```ring
oTimeline7 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline7.AddSpan("Session1", "2025-10-22 09:00:00", "2025-10-22 10:00:00")
oTimeline7.AddSpan("Session2", "2025-10-22 10:00:00", "2025-10-22 11:00:00")

Tx = new stzTimex("{@Event(Session1) -> @Event(Session2)}")

? Tx.Match(oTimeline7)  #--> TRUE
```

This ensures back-to-back execution — valuable for continuous operations or handovers.


## Debugging: Understanding Pattern Behavior

`EnableDebug()` provides a live trace of how each token is processed.

```ring
Tx = new stzTimex("{@Event(A) -> @Duration* -> @Event(C)}")
Tx.EnableDebug()

? Tx.MatchPartial(oTimeline8)  #--> TRUE  (detailed trace)
```

The trace reveals step-by-step checks — a powerful aid for debugging complex temporal rules.


## Real-World Scenario: Validating a Daily Schedule

```ring
oSchedule = new stzTimeLine("2025-10-22", "2025-10-22")
oSchedule.AddPoint("DayStart", "2025-10-22 08:00:00")
oSchedule.AddSpan("Standup", "2025-10-22 09:00:00", "2025-10-22 09:15:00")
oSchedule.AddSpan("DeepWork", "2025-10-22 09:30:00", "2025-10-22 12:00:00")

Tx1 = new stzTimex("{@Event(DayStart) -> @Duration* -> @Event(Standup)}")
Tx2 = new stzTimex("{@Event(DeepWork:2h..4h)}")

? Tx1.MatchPartial(oSchedule)  #--> TRUE
? Tx2.MatchPartial(oSchedule)  #--> TRUE
```

Two checks, no loops, no iteration — just plain intent verification.


## Searching for a Specific Event

```ring
Tx = new stzTimex("{@Event(Target)}")
? Tx.MatchPartial(oTimeline9)  #--> TRUE
```

Simple and efficient: confirm whether a labeled event exists anywhere in the timeline.


## Explaining Your Pattern

To understand what your pattern means internally:

```ring
Tx = new stzTimex("{@Event(Meeting) -> @Duration(30m..1h) -> @Event(Break)}")
? @@(Tx.Explain())
```

`Explain()` reveals the token structure, duration rules, and logical flow — making your patterns self-documenting.


## Comparative Analysis: stzTimex vs. Other Time Frameworks

| Feature                          | **Softanza (stzTimex)**                           | **Python (datetime + re/pandas)** | **JavaScript (Luxon + Moment)** | **Java (Joda-Time)**  | **Ruby (ActiveSupport::Time)** |
| -------------------------------- | ------------------------------------------------- | --------------------------------- | ------------------------------- | --------------------- | ------------------------------ |
| **Declarative Time Patterns**    | ✅ Native pattern syntax (`{@Event -> @Duration}`) | ◯ Manual logic + loops            | ◯ Imperative checks             | ◯ Custom comparators  | ◯ Procedural methods           |
| **Partial vs. Full Matching**    | ✅ Built-in `MatchPartial()`                       | ◯ Requires slicing/filtering      | ◯ Manual search                 | ◯ Range tests only    | ◯ Not native                   |
| **Temporal Normalization**       | ✅ Automatic (DateTime, Duration, Timeline)        | ◯ Manual conversions              | ◯ Manual parsing                | ◯ Type-dependent      | ◯ Partial                      |
| **Sequence Detection**           | ✅ Declarative operator `->`                       | ◯ Loops / groupby logic           | ◯ Manual reduce/filter          | ◯ Iterator logic      | ◯ Range chaining               |
| **Duration Constraints**         | ✅ Compact range syntax `(1h..2h:15min)`           | ◯ Conditional math                | ◯ Imperative conditions         | ✅ Duration class only | ◯ Manual comparisons           |
| **Pattern Explanation**          | ✅ `Explain()` readable structure                  | ◯ No built-in introspection       | ◯ Debug logs only               | ◯ Stack trace         | ◯ None                         |
| **Timeline Abstraction**         | ✅ Native `stzTimeLine` object                     | ◯ pandas timeline (custom)        | ◯ Event arrays only             | ◯ Interval sets       | ◯ No dedicated type            |
| **Debug Mode**                   | ✅ Trace of match flow                             | ◯ Manual print/debug              | ◯ Console only                  | ◯ Limited             | ◯ None                         |
| **Integration with Logic Layer** | ✅ Unified with Softanza pattern system            | ◯ Separate frameworks             | ◯ UI-centric                    | ✅ Compatible          | ◯ Mixed                        |


## Conclusion

`stzTimex` lets you *declare* how time should behave — not compute it.
Whether you’re checking a timestamp, validating a sequence, or describing a whole day, it transforms time from a set of calculations into a language you can read.

Start simple:

```
{@Instant}
{@Duration(1h)}
{@Event(A) -> @Duration(30m) -> @Event(B)}
```

Feed in your `stzDateTime`, `stzDuration`, or `stzTimeLine`.
Then watch as time logic becomes *clear, declarative, and alive.*