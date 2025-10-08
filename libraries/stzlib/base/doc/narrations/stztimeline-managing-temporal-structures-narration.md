# Managing Temporal Structures with `stzTimeLine`

Time in real-world applications is more than a number on a clock — it is **structured**, **sequenced**, and **meaningful**.

A restaurant's daily shifts, a project's phases, or a student's academic year all unfold **over time**, often overlapping, aligning, or depending on each other.

While `stzDate`, `stzTime`, `stzDuration`, and `stzDateTime` each specialize in handling different aspects of time, **`stzTimeLine`** turns time into a programmable structure you can navigate, analyze, and visualize. Together, they form a complete language for expressing time — from *"how long"* to *"when"* to *"what happens during"*.

## The Concept of `TimeLine`

A Timeline as defined in the `stzTimeLine` class defines a **bounded period** and arranges within it two types of temporal entities:

* **Points** — instantaneous events (like deliveries, releases, or meetings).
* **Spans** — intervals with start and end times (like projects, seasons, or campaigns).

Each item has a *label* to describe what it represents.
Labels don't have to be unique — several events can share the same label if they represent similar occurrences.

## Creating a Timeline

A timeline always begins with explicit temporal limits:

```ring
oTimeLine = new stzTimeLine(
    :Start = "2024-01-01 00:00:00",
    :End   = "2024-12-31 23:59:59"
)
```

All subsequent items must remain within these boundaries.
Adding a span outside them raises an exception, ensuring structural consistency.

### Simplified Date Input

Date-only timestamps are automatically normalized to midnight:

```ring
oTimeLine.AddPoint("MEETING", "2024-03-15")  # → 2024-03-15 00:00:00
oTimeLine.AddSpan("WEEK", "2024-03-01", "2024-03-07")
```

This makes timeline construction more intuitive for day-level planning.

## Adding Points and Spans


### Adding Points — Single Moments

A point defines an instantaneous event.

```ring
oTimeLine.AddPoint("MEETING", "2024-03-15 10:00:00")
```

As introduced above, points can share labels. This flexibility allows us to tag different moments in time with similar labels — for example, when we define three meetings all related to evaluating employees:

```ring
oTimeLine {
	AddPoints([
		["HR-EVAL-MEETING", "2024-03-15 10:00:00"],
		["HR-EVAL-MEETING", "2024-05-16 14:30:00"],
		["HR-EVAL-MEETING", "2024-08-17 09:00:00"]
	])
}

? oTimeLine.CountPoints()  #--> 3
? oTimeLine.PointNames()   #--> ["HR-EVAL-MEETING"]  # Unique names only
? oTimeLine.PointNamesXT() #--> [["HR-EVAL-MEETING", 3]]  # With counts
```

This will be useful when querying our timeline for all moments that share the same `"HR-EVAL-MEETING"` tag, using the `FindPoints()` method (also called `FindMoment()`) like this:

```ring
? FindPoint("HR-EVAL-MEETING")
#--> [ "2024-03-15 10:00:00", "2024-05-16 14:30:00", "2024-08-17 09:00:00" ]
```

Effectively, our evaluation meeting occurs exactly at these three datetimes!

>**NOTE:** Later, in the _Querying the Timeline_ section, we will discover how to search the timeline by datetime using the `WhatAt()` method — not by label as we’ve done here with `FindPoint()`.


### Adding Spans — Continuous Periods

Spans represent intervals between two datetimes:

```ring
oTimeLine {
	AddSpan("PROJECT",  "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}
```

**Enhanced Validation**: Invalid spans (where start ≥ end) raise descriptive errors:

```ring
try
    oTimeLine.AddSpan("INVALID", "2024-03-15 10:00:00", "2024-03-15 10:00:00")
catch
    ? "Error: Span 'INVALID' has invalid dates..."
done
```

## Querying the Timeline

### Finding What Happens at a Given Time

Sometimes, we need to know what’s going on at a particular moment in our timeline — not by label, but by **time itself**.\
That’s exactly what the `WhatsAt()` method is for. It lists every element that is active at the given instant, returning results in the **\[ label, type ]** format:

```ring
? @@NL( oTimeLine.WhatsAt("2024-03-15 10:00:00") )
#--> [
#    ["MEETING", :Point],
#    ["PROJECT", :Span],
#    ["CAMPAIGN", :Span]
# ]
```

In this example, three different elements overlap at that exact moment: a meeting point, a running project, and an ongoing campaign. This makes `WhatsAt()` particularly useful for detecting **concurrent activities** or understanding **context around an event**.

**Flexible Matching:**
Depending on what you provide as input, `WhatsAt()` automatically adapts the scope of its search:

- **Date-only search:** `WhatsAt("2024-03-15")` → returns all events occurring on that date
-  **Time-only search:** `WhatsAt("10:00:00")` → finds everything happening at that time across all dates
-  **Exact search:** providing a full datetime triggers a precise match

This flexibility allows you to explore your timeline from any perspective — whether you’re reviewing a whole day’s schedule or pinpointing what was active at a single moment in time.

### Finding What Happens Between Two Instants

`WhatsBetween()` lets you check all timeline elements that overlap a given **time range**. For example, to find what is active between `"2024-03-01"` and `"2024-03-15"`:

```
? @@NL( oTimeLine.WhatsBetween("2024-03-01", "2024-03-15") )
#--> [
#    ["PROJECT", :Span],
#    ["CAMPAIGN", :Span],
#    ["HR-EVAL-MEETING", :Point]
# ]
```

This is particularly useful for planning or analyzing **coverage across a period**, not just a single instant.

### Counting and Listing Elements

Once your timeline is populated, you may want to get an overview of its contents — how many points and spans it includes, and how they’re distributed.

```ring
? oTimeLine.CountPoints()    #--> 3
? oTimeLine.PointNames()     #--> ["EVENT1"]  # Deduplicated
? oTimeLine.PointNamesXT()   #--> [["EVENT1", 3]]  # With occurrence counts

? oTimeLine.CountSpans()     #--> 3
? oTimeLine.SpanNames()      #--> ["Q1", "Q2", "Q3"]
? oTimeLine.SpanNamesXT()    #--> [["Q1", 1], ["Q2", 1], ["Q3", 1]]
```

Here, we can see that the timeline contains three points and three spans. While `CountPoints()` and `CountSpans()` give us totals, the `Names()` and `NamesXT()` methods go further — listing all distinct names and their occurrence counts. This is especially useful when several elements share the same label, helping you verify data consistency at a glance.


### Existence and Validation

Before performing actions on timeline items, it’s a good habit to check if they actually exist. The following methods make that easy:

```ring
? oTimeLine.HasPoint("SUMMER")  #--> TRUE
? oTimeLine.HasSpan("Q3")       #--> TRUE
```

These quick checks prevent runtime errors and ensure your code behaves safely when manipulating user-provided data.

## Editing and Validation

### Removing Items

When you need to clean up or modify your timeline, you can remove elements just as easily:

```ring
oTimeLine.RemoveSpan("PHASE2")
? oTimeLine.CountSpans()  #--> 2
```

Here, we delete the span named `"PHASE2"`. The count immediately reflects the change, confirming the removal worked as expected.

### Boundary Enforcement

Every point and span must fit within the timeline’s defined boundaries. If you attempt to add something that extends beyond, the system automatically prevents it and raises an error:

```ring
try
    oTimeLine.AddSpan("OVERFLOW", "2024-11-01", "2025-02-28")
catch
    ? "Error: Span outside timeline boundaries"
done
```

This kind of validation keeps your timeline coherent and ensures the integrity of all operations.

## Detecting Overlaps and Gaps

### Overlap Analysis

When two spans share a common time window, it’s considered an overlap — and the timeline can detect it instantly:

```ring
? oTimeLine.HasOverlaps()
#--> TRUE

? @@( oTimeLine.OverlappingSpans() )
#--> [
#    ["PROJECT", "CAMPAIGN", 950400]  # Duration in seconds
# ]
```

This output shows that the `"PROJECT"` and `"CAMPAIGN"` spans overlap for 950,400 seconds. Overlap detection is crucial for scheduling tasks, resource management, or detecting conflicting activities.

### Gap Detection

In contrast, gaps represent **idle or uncovered** periods between spans. Detecting them helps identify free time slots or missing coverage.

```ring
? @@NL( oTimeLine.Gaps() )
#--> [
#    [:After = "Q1", :Before = "Q2", :Duration = 86400]
# ]

? @@NL( oTimeLine.UncoveredPeriods() )
#--> Periods between timeline boundaries and spans
```

With this insight, you can easily plan what to fill next, or confirm that your timeline achieves full coverage from start to end.

## Visualizing the Timeline

### Basic Display with `Show()`

Visual feedback is often the most intuitive way to understand your data. Calling `Show()` draws an ASCII representation of your timeline directly in the console:

```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-15 23:59:59")
	AddSpan("PHASE2", "2024-03-01 00:00:00", "2024-04-15 23:59:59")
	AddSpan("PHASE3", "2024-05-01 00:00:00", "2024-06-30 23:59:59")
}

oTimeLine.Show()
```

Output:

```
╞PHASE1╡ ╞═════╡ ╞PHASE3═╡                          
●──────●─●─────●─●───────●───────────────────────────►
1      2 3     4 5       6                          

╭────┬─────────────────────┬───────────┬────────────────────╮
│ No │      Timepoint      │   Label   │    Description     │
├────┼─────────────────────┼───────────┼────────────────────┤
│  1 │ 2024-01-01 00:00:00 │ PHASE1 │ Start of PHASE1 │
│  2 │ 2024-02-15 23:59:59 │ PHASE1 │ End of PHASE1 │
...
```

**Visual Elements**:

- `|` — Timeline origin
- `─` — Axis line
- `●` — Points/timepoints
- `╞═╡` — Span bars
- `──►` — Direction arrow

And these that we will present later in the article:
- `█` — Highlighted items (searches)
- `/` — Uncovered regions
- `x`  — Blocked regions 

### Enhanced Display Options

Need more control over how things look? The `ShowShort()` and `ToStringXT()` methods give you flexibility in what to display.

**Show visual only** (no table):

```ring
? oTimeLine.ShowShort()
```

**Control table display:**

```ring
? oTimeLine.ToStringXT([
    :Width = 80,
    :ShowTable = FALSE
])
```

**Statistical summary:**

A statistical table can be displayed instead of the normal table we saw earlier, providing a concise, quantitative overview of the timeline — ideal for reports, debugging, or analytical reviews.

```ring
? oTimeLine.ToStringXT([:TableType = :Statistical])
```

Output:

```
╭──────────────────────┬────────────────────╮
│       Metric         │       Value        │
├──────────────────────┼────────────────────┤
│ Total Points         │ 5                  │
│ Total Spans          │ 3                  │
│ Timeline Duration    │ 365 days           │
│ Coverage             │ 82%                │
│ Longest Span         │ Q3 (92 days)       │
│ Gaps Between Spans   │ 2                  │
│ Overlapping Spans    │ 1                  │
╰──────────────────────┴────────────────────╯
```

To get the statistics in a Ring list you can call the `Stats()`method directly, like this:

```ring
oTimeLine.Stats()
#--> [
	[ "metric", "value" ],

	[ "Total Points", 2 ],
	[ "Total Spans", 1 ],
	[ "Timeline Duration", "1 year" ],
	[ "Coverage", "25%" ],
	[ "Longest Span", "PREP (92 days)" ],
	[ "Gaps Between Spans", 0 ],
	[ "Overlapping Spans", 0 ]
]
```

### Highlighting Specific Elements

Highlighting is a quick way to focus on a particular point or span:

**Find and highlight points:**

```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddMoments([
		[ "EVENT_1", "2024-02-15 10:00:00" ],
		[ "EVENT_2", "2024-05-15 10:00:00" ],
		[ "EVENT_1", "2024-08-15 10:00:00" ]
	])
}

? oTimeLine.vizFindMoment("EVENT_1")
```
Output:
```

    EVENT_1     EVENT_2      EVENT_1                
│──────█───────────●────────────█────────────────────►
       1           2            3                  
```

**Find and highlight spans** (highlights axis, not label):

The output visually emphasizes the corresponding regions using `█` symbols along the axis, making it easy to locate key events:
```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPeriods([
		[ "SUCCESS", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "FAILURE", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "SUCCESS", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])
}

? oTimeLine.vizFindSpan("SUCCESS")
```
Output:
```

             ╞══FAILURE══╡                          
╞══SUCCESS═══╡           ╞══SUCCESS═══╡             
●████████████●───────────●████████████●──────────────►
1            3           5            6             
```

### Visualizing Uncovered Periods

When you call `ShowUncovered()`, the timeline explicitly displays the gaps using a `/` pattern — giving an instant view of idle intervals. Let's see it by example.

```ring
oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("BUSY", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}
```
Before visualizing the uncovered periods, let’s first retrieve them as data:
```
? oTimeLine.UncoveredPeriods()
```
Output:
```
[
	[
		[ "start", "2024-01-01 00:00:00" ],
		[ "end", "2024-03-01 00:00:00" ],
	[
		[ "start", "2024-05-31 23:59:59" ],
		[ "end", "2024-12-31 23:59:59" ],
		[ "duration", 18489600 ]
	]
]
```
This provides two periods, each defined by a start and end datetime, along with the duration in seconds. The duration can be easily converted into any time unit (days, months, years…) using a `stzDuration` object, for example:
```ring
? StzDurationQ(18489600).Days
#--> 214
```

However, this information becomes even more intuitive when visualized on the timeline itself:
```
oTimeLine.ShowUncovered()
#-->

         ╞═══BUSY════╡                              
|////////●───────────●///////////////////////////○─►
         1           2                              
╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│  1 │ 2024-03-01 00:00:00 │ BUSY  │ Start of BUSY  │
│  2 │ 2024-05-31 23:59:59 │ BUSY  │ End of BUSY    │
│    │ 2024-12-31 23:59:59 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
```

This clear visualization makes it easy to identify periods of inactivity or gaps in coverage at a glance.


### Dynamic Height Adjustment

The visualization engine automatically adjusts the timeline’s height to accommodate overlapping spans. No more clipped bars or confusing overlaps — every element remains clear and readable.

```ring
oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_B", "2024-04-01 00:00:00", "2024-07-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-09-30 23:59:59")

	AddPoint("MILESTONE1", "2024-03-15 00:00:00")
	AddPoint("MILESTONE2", "2024-08-15 00:00:00")
}

oTimeLine.Show()
```

Output:

```
             
                     ╞═══PROJECT_C════╡             
             ╞═══PROJECT_B════╡                     
     ╞MILESTONE1_A═══╡     MILESTONE2               
│────●─────●─●───────●────────●─●─────●──────────────►
     1     2 3       5        6 7     8             
```
## Distance and Duration Calculations

Timelines are about time, after all — so measuring durations is key.\
The `Distance()` methods help compute intervals between points, spans, or any labeled elements.

```ring
? oTimeLine.Distance(:From = "MEETING", :To = "LAUNCH")
#--> Duration in seconds

? oTimeLine.DistanceBetweenQ("Q1", "Q2").ToHuman()
#--> "15 days"
```

These calculations make it easy to build analytics, compare project phases, or display user-friendly durations like _“2 months and 3 days.”_

## Error Handling and Safety Patterns

Softanza’s design philosophy emphasizes **reliability through clarity**.\
Follow these best practices to keep your timeline robust and error-free:

- Wrap `AddSpan()` and `AddPoint()` calls in `try/catch` when dealing with user input
- Use `HasPoint()` or `HasSpan()` before attempting removals
- Compare counts before and after operations to validate expected results
- Use `Show()` frequently to visualize and confirm structural changes
- Rely on built-in boundary validation to prevent silent data corruption

Together, these habits create safer, more predictable code — exactly what Softanza aims for.

## End-to-End Example: Planning and Analysis

Let’s wrap up with a complete example that demonstrates the core features in action.

```ring
oTimeLine = new stzTimeLine([
    :Start = "2024-01-01",
    :End   = "2024-12-31"
])

oTimeLine {
    AddPoint("MEETING", "2024-03-15 10:00:00")
    AddSpan("PROJECT",  "2024-03-01", "2024-05-31")
    AddSpan("CAMPAIGN", "2024-03-10", "2024-03-20")
}

? @@NL( oTimeLine.WhatsAt("2024-03-15") )
#--> All events on that date

? oTimeLine.HasOverlaps()   #--> TRUE

? oTimeLine.ToStringXT([:TableType = :Statistical])
#--> Complete statistical overview

oTimeLine.ShowUncovered()
#--> Visual gap analysis
```

This small scenario covers everything: defining points and spans, detecting overlaps, checking coverage, and visualizing results — a full planning and analysis workflow in just a few lines of code.


## Comparative Analysis: `stzTimeLine` vs. Other Ecosystems

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

> **Takeaway**: `stzTimeLine` uniquely combines **temporal modeling**, **validation**, **statistical analysis**, **flexible querying**, and **rich console visualization** in a single, dependency-free class — ideal for scripting, testing, and backend logic in Ring.

## Conclusion

`stzTimeLine` transforms time management from a low-level operation into a **semantic narrative**.
Built atop the precise engines of `stzTime`, `stzDate`, `stzDuration`, and `stzDateTime`,
it gives structure, insight, and context to your temporal data.

With features like automatic date normalization, flexible time matching, statistical analytics, dynamic visualization adjustment, and comprehensive gap analysis, it provides enterprise-grade timeline management without external dependencies.