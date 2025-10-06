# Managing Temporal Structures with `stzTimeLine`

Time in real-world applications is more than a number on a clock —
it is **structured**, **sequenced**, and **meaningful**.

A restaurant’s daily shifts, a project’s phases, or a student’s academic year all unfold **over time**, often overlapping, aligning, or depending on each other.

While `stzDate`, `stzTime`, `stzDuration`, and `stzDateTime` each specialize in handling different aspects of time, **`stzTimeLine`** turns time into a programmable structure you can navigate, analyze, and visualize. Together, they form a complete language for expressing time — from *“how long”* to *“when”* to *“what happens during”*.

## The Concept of `TimeLine`

A Timeline as defined in the `stzTimeLine` class defines a **bounded period** and arranges within it two types of temporal entities:

* **Points** — instantaneous events (like deliveries, releases, or meetings).
* **Spans** — intervals with start and end times (like projects, seasons, or campaigns).

Each item has a *label* to describe what it represents.
Labels don’t have to be unique — several events can share the same label if they represent similar occurrences.

This design mirrors real life: multiple “deliveries” or “EVENT1” entries can exist along a single timeline.

## Creating a Timeline

A timeline always begins with explicit temporal limits:

```ring
oTimeLine = new stzTimeLine([
    :Start = "2024-01-01 00:00:00",
    :End   = "2024-12-31 23:59:59"
])
```

All subsequent items must remain within these boundaries.
Adding a span outside them raises an exception, ensuring structural consistency.

## Adding Points and Spans

### Adding Points — Single Moments

A point defines an instantaneous event.

```ring
oTimeLine.AddPoint("MEETING", "2024-03-15 10:00:00")
```

Points can share labels, as the following test-based example shows:

```ring
oTimeLine {
	AddPoints([
		["EVENT1", "2024-03-15 10:00:00"],
		["EVENT1", "2024-05-16 14:30:00"],
		["EVENT1", "2024-08-17 09:00:00"]
	])
}

? oTimeLine.CountPoints()
#--> 3

oTimeLine.RemovePoint("EVENT1") # removes first
oTimeLine.RemovePoint("EVENT1") # removes second
oTimeLine.RemovePoint("EVENT1") # removes third
```

Each call removes the first occurrence of the label —
which means points are identified internally by their **position** rather than by name.

### Adding Spans — Continuous Periods

Spans represent intervals between two datetimes:

```ring
oTimeLine {
	AddSpan("PROJECT",  "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}
```

Spans can overlap or nest.
Here, the `CAMPAIGN` span is contained entirely within `PROJECT`.

## Querying the Timeline

### Finding What Happens at a Given Time

The `WhatsAt()` method lists all elements active at a specific instant:

```ring
? @@NL( oTimeLine.WhatsAt("2024-03-15 10:00:00") )
#--> [
#    [:Point, "MEETING"],
#    [:Span,  "PROJECT"],
#    [:Span,  "CAMPAIGN"]
# ]
```

This query is central to `stzTimeLine`:
it merges *instant* and *interval* logic, showing every relevant activity in context.

### Counting and Listing Elements

```ring
? oTimeLine.CountPoints()  #--> 3
? oTimeLine.PointNames()   #--> ["EVENT1", "EVENT1", "EVENT1"]

? oTimeLine.CountSpans()   #--> 3
? oTimeLine.SpanNames()    #--> ["Q1", "Q2", "Q3"]
```

The API maintains a natural symmetry between points and spans, making iteration intuitive.

### Existence and Validation

```ring
? oTimeLine.HasPoint("SUMMER")  #--> TRUE
? oTimeLine.HasPoint("WINTER")  #--> FALSE
? oTimeLine.HasSpan("Q3")       #--> TRUE
```

Use these checks to verify data or avoid exceptions when manipulating timelines dynamically.

## Editing and Validation

### Removing Items

```ring
oTimeLine.RemoveSpan("PHASE2")
? oTimeLine.CountSpans()
#--> 2
```

Removal functions delete the first matching label occurrence —
ideal for progressive event processing or cleanup workflows.

### Boundary Enforcement

`stzTimeLine` guarantees that no span can exceed its boundaries.

```ring
try
    oTimeLine.AddSpan("OVERFLOW", "2024-11-01 00:00:00", "2025-02-28 23:59:59")
catch
    ? "Error: Span outside timeline boundaries"
done
```

This behavior ensures consistency between all related `stzDateTime` objects and prevents silent data corruption.

The tests also mention a future validation for invalid spans (`start >= end`),
confirming the class’s focus on correctness.

## Detecting Overlaps

Use these methods to manage concurrent intervals:

```ring
? oTimeLine.HasOverlaps()
#--> FALSE

? @@( oTimeLine.OverlappingSpans() )
#--> []
```

If overlaps exist, `OverlappingSpans()` returns a list of groups showing which spans intersect
and for how long (in seconds).
This makes it trivial to detect scheduling conflicts or workload collisions.

## Visualizing the Timeline

### Text-Based Display with `Show()`

`stzTimeLine` can render its structure directly as an ASCII timeline:

```
     ╞═PROJECT_B═╡                              
╞═PROJECT_A═╡   ╞═PROJECT_C══╡
│────●───●───────●───●────────────●──────────────►
     1   2       3   5            6

╭────┬─────────────────────┬───────────┬────────────────────╮
│ No │      Timepoint      │   Label   │    Description     │
├────┼─────────────────────┼───────────┼────────────────────┤
│  1 │ 2024-02-01 00:00:00 │ PROJECT_A │ Start of PROJECT_A │
│  2 │ 2024-03-01 00:00:00 │ PROJECT_B │ Start of PROJECT_B │
│  3 │ 2024-04-30 23:59:59 │ PROJECT_A │ End of PROJECT_A   │
...
```

Features:

* Horizontal axis shows chronological order.
* Bars (`╞══╡`) represent spans.
* Dots (`●`) mark timepoints.
* The table underneath lists all timestamps and labels clearly.

This is especially useful in console-based applications, tests, or log reviews.

## Error Handling and Safety Patterns

Softanza’s design philosophy prioritizes reliability through readability.
Here are some recommended practices drawn from the tests:

* Wrap all `AddSpan()` and `AddPoint()` calls in `try/catch` when user input is involved.
* Use `HasPoint()` or `HasSpan()` before removal.
* Compare counts before and after operations to assert expected outcomes.
* Use `Show()` to visualize and verify changes interactively.

## End-to-End Example: Planning and Analysis

```ring
oTimeLine = new stzTimeLine([
    :Start = "2024-01-01 00:00:00",
    :End   = "2024-12-31 23:59:59"
])

oTimeLine {
    AddPoint("MEETING", "2024-03-15 10:00:00")
    AddSpan("PROJECT",  "2024-03-01 00:00:00", "2024-05-31 23:59:59")
    AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}

? @@( oTimeLine.WhatsAt("2024-03-15 10:00:00") )
#--> [:Point "MEETING"], [:Span "PROJECT"], [:Span "CAMPAIGN"]

? oTimeLine.HasOverlaps()   #--> TRUE

oTimeLine.Show()
```

This compact example shows how the same API supports **temporal logic**, **data integrity**, and **visual clarity**
in a single, cohesive tool.

## Comparative Analysis: `stzTimeLine` vs. Other Ecosystems

| Feature / Capability               | `stzTimeLine` (Ring)         | Python (`datetime` + libs)     | Java (`java.time` + extras)    | JavaScript (Luxon/Moment)      | Specialized (e.g., TimelineJS) |
|----------------------------------|------------------------------|--------------------------------|--------------------------------|--------------------------------|-------------------------------|
| **Native timeline object**       | ✅ Yes                       | ❌ No (requires custom class)  | ❌ No (`Interval` is basic)    | ❌ No                          | ✅ Yes (UI-focused)           |
| **Add points/spans by label**    | ✅ Yes                       | ❌ Manual dict/list mgmt       | ❌ Manual                      | ❌ Manual                      | ⚠️ Via data config            |
| **Overlap detection**            | ✅ `.HasOverlaps()`, `.OverlappingSpans()` | ❌ Custom logic needed     | ⚠️ With ThreeTen-Extra         | ✅ `Interval.overlaps()`       | ❌ Not analytical             |
| **Gap analysis**                 | ✅ `.Gaps()`, `.UncoveredPeriods()` | ❌ Custom                 | ❌ Custom                      | ❌ Custom                      | ❌                            |
| **Boundary enforcement**         | ✅ Built-in (throws error)   | ❌ Optional                    | ❌ Optional                    | ❌ Optional                    | ⚠️ UI clipping only           |
| **Text-based visualization**     | ✅ `.Show()` (ASCII timeline + table) | ❌ External lib needed    | ❌ Console print only          | ❌                            | ❌ (Web UI only)              |
| **Duration in overlap results**  | ✅ Yes (seconds)             | ❌ Must compute                | ❌ Must compute                | ⚠️ Possible                   | ❌                            |
| **Label-based querying**         | ✅ `.Point("X")`, `.Span("Y")` | ❌ Loop/filter                | ❌ Loop/filter                 | ❌ Loop/filter                | ⚠️ Via ID                     |

> **Takeaway**: `stzTimeLine` uniquely combines **temporal modeling**, **validation**, **analysis**, and **console visualization** in a single, dependency-free class — ideal for scripting, testing, and backend logic in Ring.---

## Conclusion

`stzTimeLine` transforms time management from a low-level operation into a **semantic narrative**.
Built atop the precise engines of `stzTime`, `stzDate`, `stzDuration`, and `stzDateTime`,
it gives structure, insight, and context to your temporal data.

Where other systems just *measure* time, Softanza — through `stzTimeLine` — helps your applications **understand** it.
