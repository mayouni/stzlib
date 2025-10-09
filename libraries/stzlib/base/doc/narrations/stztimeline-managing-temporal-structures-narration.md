# **Time Modeling in Softanza using `stzTimeLine`**

> *Time isn’t a line you scroll through — it’s a canvas you shape.*

Imagine you’re planning a product launch. You’ve got milestones, sprints, blackout dates for holidays, and three HR reviews scattered across the year. In most systems, that’s a spreadsheet or a calendar invite.  
In **Softanza**, it’s a **living timeline** you can **see**, **query**, and **refactor** — all from the console.

Let’s build one together — step by step, visually, interactively.


## Starting with Boundaries

Every meaningful story has a beginning and an end. So does every `stzTimeLine`.

```ring
load "../stzbase.ring"

oTimeLine = new stzTimeLine(
    :Start = "2024-01-01 00:00:00",
    :End   = "2024-12-31 23:59:59"
)
```

This isn’t just metadata — it’s a **contract**. Try adding an event in 2025, and Softanza stops you cold:

```ring
oTimeLine.AddPoint("FUTURE", "2025-01-15")
#--> ERROR: Point 'FUTURE' is outside timeline boundaries
```

> Boundaries enforce **temporal integrity**. No rogue datetimes. No silent bugs.

And don’t worry about format quirks — Softanza **normalizes intelligently**:

```ring
o1 = new stzTimeLine("2024-10-10", "2024-10-22 16:40:00")
? @@NL(o1.Content())
#--> [
#     [ "start", "2024-10-10 00:00:00" ],
#     [ "end",   "2024-10-22 16:40:00" ],
#     [ "points", [] ],
#     [ "spans",  [] ]
# ]
```

Missing time? It becomes `00:00:00`. Clean, predictable, safe.


##  Adding Moments — Even When They Repeat

Let’s say your team does **quarterly HR evaluations**. Same label, different dates. That’s not a bug — it’s a **feature**.

```ring
oTimeLine = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeLine.AddMoments([
    ["HR-EVAL", "2024-03-15 10:00:00"],
    ["HR-EVAL", "2024-05-16 14:30:00"],
    ["HR-EVAL", "2024-08-17 09:00:00"]
])
```

Now ask: *“How many HR-EVALs do we have?”*

```ring
? oTimeLine.PointNamesXT()
#--> [["HR-EVAL", 3]]
```

> **Same-label grouping** enables powerful analytics: count occurrences, find all instances, highlight them together — all without extra code.

And yes — labels are **case-insensitive internally**:

```ring
? oTimeLine.HasPoint("hr-eval")  # TRUE
? oTimeLine.HasPoint("Hr-EvAl")  # TRUE
```

Even **empty labels** are allowed (useful for anonymous markers):

```ring
oTimeLine.AddMoment("", "2024-06-01")
```

## Defining Periods — With Overlap Awareness

Now add a project and a marketing campaign:

```ring
oTimeLine.AddPeriod("PROJECT", "2024-03-01", "2024-05-31")
oTimeLine.AddPeriod("CAMPAIGN", "2024-03-10", "2024-03-20")
```

Notice: `AddPeriod()` is just an alias for `AddSpan()` — same with `AddMoment()` vs `AddPoint()`. Choose the word that fits your domain.

But here’s where Softanza shines: **it sees overlaps**.

```ring
? oTimeLine.HasOverlaps()
#--> TRUE

? @@(oTimeLine.OverlappingSpans())
#--> [["PROJECT", "CAMPAIGN", 864000]]  # 10 days of overlap
```

No hidden conflicts. No manual date math. Just **truth**.

## Seeing Is Believing — Three Views, One Engine

### First: `.ShowShort()` — The Sketch

```ring
oTimeLine.ShowShort()
```

**Output:**
```
╞PROJECT══╡  ╞═CAMPAIGN═╡                           

│───────────●────────────●──────────────────────────►
            1            2                          
```

- `●` = moments  
- `╞══╡` = periods  
- Numbers = event order

Clean. Immediate. Perfect for quick checks.

### Next: `.Show()` — The Full Story

```ring
oTimeLine.Show()
```

**Output:**
```
╞PROJECT══╡  ╞═CAMPAIGN═╡                           

│───────────●────────────●──────────────────────────►
            1            2                          

╭────┬─────────────────────┬───────────┬────────────────────╮
│ No │      Timepoint      │   Label   │    Description     │
├────┼─────────────────────┼───────────┼────────────────────┤
│    │ 2024-01-01 00:00:00 │           │ Timeline start     │
│  1 │ 2024-03-01 00:00:00 │ PROJECT   │ Start of PROJECT   │
│  2 │ 2024-03-10 00:00:00 │ CAMPAIGN  │ Start of CAMPAIGN  │
│  3 │ 2024-03-15 10:00:00 │ HR-EVAL   │ HR-EVAL event      │
│  4 │ 2024-03-20 00:00:00 │ CAMPAIGN  │ End of CAMPAIGN    │
│  5 │ 2024-05-16 14:30:00 │ HR-EVAL   │ HR-EVAL event      │
│  6 │ 2024-05-31 00:00:00 │ PROJECT   │ End of PROJECT     │
│  7 │ 2024-08-17 09:00:00 │ HR-EVAL   │ HR-EVAL event      │
│    │ 2024-12-31 23:59:59 │           │ Timeline end       │
╰────┴─────────────────────┴───────────┴────────────────────╯
```

Every boundary, every event — **chronologically ordered**, **human-readable**.

### Finally: `.ShowXT()` — The Unified Visual Engine

Behind both `.Show()` and `.ShowShort()` lies **one powerful renderer**: `.ShowXT()`.

Want stats instead of a table?

```ring
oTimeLine.ShowXT([:TableType = :Statistical])
```

**Output:**
```
╞PROJECT══╡  ╞═CAMPAIGN═╡                           

│───────────●────────────●──────────────────────────►
            1            2                          

╭────────────────────┬────────────────╮
│       Metric       │     Value      │
├────────────────────┼────────────────┤
│ Total Points       │              3 │
│ Total Spans        │              2 │
│ Timeline Duration  │ 1 year         │
│ Coverage           │ 25%            │
│ Longest Span       │ PROJECT (92 days) │
│ Gaps Between Spans │              0 │
│ Overlapping Spans  │              1 │
╰────────────────────┴────────────────╯
```

Or get the data directly:

```ring
? @@NL(oTimeLine.Stats())
#--> [
#     ["metric", "value"],
#     ["Total Points", 3],
#     ["Total Spans", 2],
#     ["Timeline Duration", "1 year"],
#     ["Coverage", "25%"],
#     ["Longest Span", "PROJECT (92 days)"],
#     ["Gaps Between Spans", 0],
#     ["Overlapping Spans", 1]
# ]
```

> This is your **temporal dashboard** — in one call.


## Querying Time Like a Human

What’s happening **right now**?

```ring
? @@NL(oTimeLine.WhatsAt("2024-03-15 10:00:00"))
#--> [
#     ["HR-EVAL", "point"],
#     ["PROJECT", "span"],
#     ["CAMPAIGN", "span"]
# ]
```

What’s active **this month**?

```ring
? oTimeLine.MomentsBetween("2024-03-01", :And = "2024-03-31")
#--> ["HR-EVAL"]
```

Even **partial inputs** work intuitively:

```ring
? @@NL(oTimeLine.WhatsAt("2024-03-15"))   # All events on that date
? @@NL(oTimeLine.WhatsAt("10:00:00"))     # All events at that time
```

Softanza **infers context** — so you don’t have to.


## Blocking Forbidden Time

Some days, the system is down for maintenance. Others, leadership is on retreat. Mark those as **blocked**:

```ring
oTimeLine.AddBlockedSpan("MAINTENANCE", "2024-07-01", "2024-07-15")
oTimeLine.AddBlockedPoint("2024-10-05 09:00:00")
```

### Blocking Existing Spans and Moments

You can also block an existing span or moment by its label, converting it to a blocked item:

```ring
oTimeLine.BlockSpan("PROJECT")
oTimeLine.BlockPoint("HR-EVAL")
```

Note that for points with the same label, `BlockPoint()` blocks one occurrence at a time, similar to removal behavior.

Now try to schedule something inside a blocked time:

```ring
oTimeLine.AddPoint("MEETING", "2024-07-10")
#--> ERROR: Point 'MEETING' falls within a blocked span or blocked point
```

Check proactively using the unified `IsBlocked()` method, which handles both single times and ranges:

```ring
? oTimeLine.IsBlocked("2024-07-10")  # TRUE (single datetime)
? oTimeLine.IsBlocked(["2024-07-14", "2024-07-16"])  # TRUE (range with partial overlap)
? oTimeLine.IsBlocked("HR-EVAL")  # TRUE (if blocked by label)
```

`IsBlocked()` intelligently handles datetimes, ranges as lists, or labels for flexibility.

And **see it visually**:

```ring
oTimeLine.Show()
```

**Output snippet:**
```
|───────●──────XXXXX─────●───────X──────────────────○─►
        1                2               
```

- `x` = blocked span  
- `X` = blocked point  

No guesswork. No calendar drift.


## Highlighting What Matters

Got three `"HR-EVAL"` events? Highlight them:

```ring
oTimeLine.VizFindMoment("HR-EVAL")
```

**Output:**
```
    HR-EVAL                HR-EVAL                HR-EVAL
│──────█─────────────────────█──────────────────────█────○─►
       1                     2                      3     
```

- `█` = highlighted moment

Same for spans:

```ring
oTimeLine.VizFindSpan("PROJECT")
# Fills the PROJECT span with █
```

> Focus your attention **without filtering data** — just visual emphasis.


## Stacking Overlaps — Automatically

When spans overlap, Softanza **stacks them vertically** so nothing hides:

```ring
oTimeLine = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeLine {
    AddSpan("A", "2024-02-01", "2024-05-31")
    AddSpan("B", "2024-04-01", "2024-07-31")
    AddSpan("C", "2024-06-01", "2024-09-30")
}
oTimeLine.Show()
```

**Output:**
```
                 ╞══C══╡
            ╞══B══╡
╞══A══╡
●─────●────────●──────────────►
```

No configuration. No z-index. Just **automatic clarity**.


## Revealing Idle Time with `ShowUncovered()`

What if you want to know **when nothing is happening**? That’s **uncovered time** — crucial for capacity planning or identifying scheduling opportunities.

```ring
oTimeLine = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeLine {
    AddSpan("BUSY", "2024-03-01", "2024-05-31")
    AddSpan("BUSY", "2024-08-01", "2024-09-20")
    AddMoment("MMM", "2024-08-01")
}
oTimeLine.ShowUncovered()
```

**Output:**
```
              ╞===BUSY====╡                          
          ╞===BUSY====╡        ╞=BUSY=╡              
|////////●───●───────●───●////◉──────●///////////○─►
         1   2       3   4   5-6     7                     
```

- `/` = **uncovered (idle) time**  
- `◉` = boundary where uncovered meets a defined event

This isn’t just visual — you can **query it programmatically**:

```ring
? @@NL(oTimeLine.UncoveredPeriods())
#--> [
#  [ [ "start", "2024-01-01 00:00:00" ], [ "end", "2024-03-01 00:00:00" ], [ "duration", 5184000 ] ],
#  [ [ "start", "2024-05-31 23:59:59" ], [ "end", "2024-08-01 00:00:00" ], [ "duration", 5270401 ] ],
#  [ [ "start", "2024-09-20 23:59:59" ], [ "end", "2024-12-31 23:59:59" ], [ "duration", 8035200 ] ]
# ]
```

> **Uncovered ≠ Gaps**:  
> - **Gaps** are only *between spans* (`Gaps()` returns `[:After, :Before, :Duration]`)  
> - **Uncovered** is *total idle time* across the entire timeline — including before the first and after the last event.

##  Measuring Time — Naturally

How far apart are two events?

```ring
oTimeLine.AddPoint("START", "2024-01-15")
oTimeLine.AddPoint("END", "2024-03-15")
? oTimeLine.DistanceQ("START", "END").ToHuman()
#--> "60 days"
```

From span to point?

```ring
? oTimeLine.TimeBetween("PROJECT", "HR-EVAL")
#--> 1296000 seconds (15 days)
```

> 📏 `.Distance()` and `.TimeBetween()` are **context-aware**: they use the closest boundaries.


## Maintenance & Safety

Timelines are **mutable**:

```ring
oCopy = oTimeLine.Copy()
oTimeLine.Clear()
? oTimeLine.CountPoints()  # 0
? oCopy.CountPoints()      # 3
```

You can also remove specific points and spans. Note that for points with the same label, `RemovePoint()` removes one occurrence at a time.

### Removing Points

```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoints([ 
		[ "EVENT1", "2024-03-15 10:00:00" ],
		[ "EVENT1", "2024-05-16 14:30:00" ],
		[ "EVENT1", "2024-08-17 09:00:00" ]
	])
}

oTimeLine.Show()
```

**Output:**
```
        EVENT1  EVENT1       EVENT1                 
|──────────●───────●────────────●────────────────○─►
           1       2            3                 

╭────┬─────────────────────┬────────┬────────────────╮
│ No │      Timepoint      │ Label  │  Description   │
├────┼─────────────────────┼────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │        │ Timeline start │
│  1 │ 2024-03-15 10:00:00 │ EVENT1 │ EVENT1 event   │
│  2 │ 2024-05-16 14:30:00 │ EVENT1 │ EVENT1 event   │
│  3 │ 2024-08-17 09:00:00 │ EVENT1 │ EVENT1 event   │
│    │ 2024-12-31 23:59:59 │        │ Timeline end   │
╰────┴─────────────────────┴────────┴────────────────╯
```

```ring
? oTimeLine.CountPoints()
#--> 3

oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")

? oTimeLine.CountPoints()
#--> 0

? oTimeLine.HasPoint("EVENT2")
#--> FALSE

oTimeLine.Show()
```

**Output:**
```
|────────────────────────────────────────────────○─►

╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│    │ 2024-12-31 23:59:59 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
```

### Removing Spans

```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpans([
		[ "PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])

	? CountSpans()
	#--> 3

	RemoveSpan("PHASE2")

	? CountSpans()
	#--> 2

	? SpanNames()
	#--> [ "PHASE1", "PHASE3" ]

}
```

You can also rename labels for points and spans. This affects all occurrences of the label, whether for points or spans.

### Renaming Labels

To rename all the occurerrences of a given label in the timeline (beeing a moment or a period label), use `RenameLabel()`:
```ring
# replacing the 3 moments with "HR-EVAL" label:

oTimeLine.RenameLabel("HR-EVAL", "PERF-REVIEW")
# Checking the change made:
? oTimeLine.PointNamesXT()
#--> [["PERF-REVIEW", 3]]

# Replacing the span with label "PROJECT"
oTimeLine.RenameLabel("PROJECT", "INITIATIVE")
# Checking the change made:
? oTimeLine.SpanNames()
#--> ["INITIATIVE"]
```

And if you want to more precise you can use `RenamePointLabel()` and `RenameSpanLabel()` directly.


## The Full Picture — One Final Example

```ring
oTimeLine = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeLine {
    AddMoments([
        ["HR-EVAL", "2024-03-15"],
        ["HR-EVAL", "2024-08-17"]
    ])
    AddPeriod("PROJECT", "2024-03-01", "2024-05-31")
    AddBlockedSpan("MAINTENANCE", "2024-07-01", "2024-07-15")
    AddBlockedPoint("2024-10-05 09:00:00")
}
oTimeLine.ShowXT()
```

**Output:**
```
╞PROJECT══╡                                           

│──────█────●────────────█──────XXXXX──────X────────○─►
       1    2            3                4          
```

Events, spans, blocks — all **coexisting**, **visible**, **queryable**.


## 🌟 Softanza Advantage: `stzTimeLine` vs. Other Ecosystems

Most time libraries stop at **parsing and formatting**. A few go further with intervals or durations. But none offer what `stzTimeLine` delivers: a **complete, visual, analytical model of time itself** — all in one dependency-free Ring class.

Here’s how it stacks up:

| Feature / Capability               | `stzTimeLine` (Ring)         | Python (`datetime` + libs)     | Java (`java.time` + extras)    | JavaScript (Luxon/Moment)      | Specialized (e.g., TimelineJS) |
|----------------------------------|------------------------------|--------------------------------|--------------------------------|--------------------------------|-------------------------------|
| **Native timeline object**       | ✅ Yes                       |  ⚪ No (requires custom class)  |  ⚪ No (`Interval` is basic)    |  ⚪ No                          | ✅ Yes (UI-focused)           |
| **Add points/spans by label**    | ✅ Yes                       |  ⚪ Manual dict/list mgmt       |  ⚪ Manual                      |  ⚪ Manual                      | ⚠️ Via data config            |
| **Date-only input normalization**| ✅ Automatic                 |  ⚪ Manual                      | ⚠️ Possible                    |  ⚪ Manual                      | ⚠️ Config-based               |
| **Flexible time matching**       | ✅ Date/Time/Exact modes     |  ⚪ Custom logic                |  ⚪ Custom                      |  ⚪ Custom                      |  ⚪                            |
| **Overlap detection**            | ✅ `.HasOverlaps()`, `.OverlappingSpans()` |  ⚪ Custom logic needed     | ⚠️ With ThreeTen-Extra         | ✅ `Interval.overlaps()`       |  ⚪ Not analytical             |
| **Gap analysis**                 | ✅ `.Gaps()`, `.UncoveredPeriods()` |  ⚪ Custom                 |  ⚪ Custom                      |  ⚪ Custom                      |  ⚪                            |
| **Boundary enforcement**         | ✅ Built-in (descriptive errors) |  ⚪ Optional                |  ⚪ Optional                    |  ⚪ Optional                    | ⚠️ UI clipping only           |
| **Text-based visualization**     | ✅ `.Show()` (ASCII timeline + table) |  ⚪ External lib needed    |  ⚪ Console print only          |  ⚪                            |  ⚪ (Web UI only)              |
| **Statistical analytics**        | ✅ `.ToStringXT(:Statistical)` |  ⚪ Manual calculation        |  ⚪ Manual                      |  ⚪ Manual                      | ⚠️ Limited metrics            |
| **Uncovered region visualization**| ✅ `.ShowUncovered()`       |  ⚪                             |  ⚪                             |  ⚪                             |  ⚪                            |
| **Dynamic height adjustment**    | ✅ Auto-calculated           |  ⚪                             |  ⚪                             |  ⚪                             | ⚠️ Fixed UI layout            |
| **Label-based querying**         | ✅ `.Point("X")`, `.Span("Y")` |  ⚪ Loop/filter                |  ⚪ Loop/filter                 |  ⚪ Loop/filter                | ⚠️ Via ID                     |
| **Occurrence counting**          | ✅ `.PointNamesXT()`, `.SpanNamesXT()` |  ⚪ Custom                |  ⚪ Custom                      |  ⚪ Custom                      |  ⚪                            |
| **Blocked time regions**         | ✅ Spans **and** points      |  ⚪ Custom                      |  ⚪ Custom                      |  ⚪ Custom                      | ⚠️ Visual only                |
| **Case-insensitive labels**      | ✅ Yes                       |  ⚪ Manual                      |  ⚪ Manual                      |  ⚪ Manual                      | ⚪                             |
| **Empty-label support**          | ✅ Yes                       |  ⚪ Possible                    |  ⚪ Possible                    |  ⚪ Possible                    | ⚪                             |

> **Takeaway**: `stzTimeLine` uniquely combines **temporal modeling**, **validation**, **statistical analysis**, **flexible querying**, and **rich console visualization** in a single, dependency-free class — ideal for scripting, testing, and backend logic in Ring.  
> While other ecosystems require stitching together parsers, interval logic, and custom renderers, Softanza gives you a **cohesive, visual, and safe time workspace** out of the box.


## Conclusion: Time as a First-Class Citizen

In Softanza, time isn’t stored — it’s **modeled**.  
With `stzTimeLine`, you get:

- **Visual integrity** (what you see is what you have)
- **Grouped analytics** (same labels → powerful queries)
- **Automatic layout** (overlaps, gaps, blocks — handled)
- **Humanized output** (durations in “60 days”, not seconds)
- **Safety by design** (boundaries, blocks, validation)
- **Idle-time awareness** via `ShowUncovered()` and `UncoveredPeriods()`

You don’t just **manage** time — you **reason** with it.