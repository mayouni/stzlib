# Time Capacity Planning in Softanza: Mastering Constraints with `stzCalendar`

Traditional scheduling tools force manual tracking of holidays, breaks, and business hours. Softanza's `stzCalendar` changes that by embedding constraints as first-class features, letting you reason about *usable time* declaratively. Define constraints once, query unlimited scenarios instantly. This article walks through real examples from the test suite, building a mental model of how time compounds through layers of constraints.

---

## The Layered Constraint Model

Time availability isn't binary—it's layered. Start with a month, peel away weekends, remove holidays, subtract breaks, then apply custom maintenance windows. Each layer reduces capacity; all layers compound into your final, auditable answer.

**Layer 1: The Calendar Boundary**

```ring
oCal = new stzCalendar([2024, 10])

oCal {
    ? Start()
    #--> 2024-10-01
    ? StartQ().DayName()
    #--> Tuesday

    ? End_()
    #--> 2024-10-31
    ? EndQ().DayName()
    #--> Thursday

    ? Year()
    #--> 2024
    
    ? MonthName()
    #--> October
}
```

October 2024 spans 31 days, Tuesday to Thursday. This *fences* your scope—you can't accidentally leak into September or November. All queries stay within this boundary.

**Layer 2: Working Days**

```ring
oCal.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal {
    ? IsWorkingDay("2024-10-03")  #--> 1 (TRUE, Thursday)
    ? IsWorkingDay("2024-10-05")  #--> 0 (FALSE, Saturday)
    ? HowManWorkingDays()         #--> 23
}
```

October 2024 has 31 days, but only **23 are working days** (Mon-Fri). Weekends (Oct 5-6, 12-13, 19-20, 26-27 = 8 days) are auto-filtered. All downstream calculations skip weekends automatically.

**Layer 3: Holidays**

```ring
oCal {
    AddHoliday("2024-10-05", "Independence Day")
    AddHoliday("2024-10-15", "National Day")
    
    ? IsHoliday("2024-10-05")     #--> 1 (TRUE)
    ? HolidayName("2024-10-05")   #--> Independence Day
    ? HowManyHolidays()           #--> 2
}
```

Oct 5 is a Saturday (already excluded as a weekend), so adding it as a holiday doesn't further reduce working days—it's logged for context. Oct 15 is a Tuesday, which would reduce working days to **22** if it fell mid-week. Holidays layer on top of weekends.

**Layer 4: Business Hours and Breaks**

```ring
oCal {
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? AvailableHoursN()  #--> 161
    ? AvailableDaysN()   #--> 23
}
```

With 8-hour days (9-17) minus 1-hour lunch breaks:
- 23 working days × 7 hours/day = **161 total available hours**

Each working day yields 7 usable hours. This compounds through layers: start with 31 calendar days → filter to 23 working → multiply by 7 hours per day = 161.

**Layer 5: Custom Constraints**

```ring
oCal {
    AddConstraint("MaintWindow", [:Every, :Wednesday, :From, "14:00", :To, "16:00"])
    
    ? ApplyConstraints("2024-10-09")  #--> 5 (not 7)
}
```

Oct 9 is a Wednesday. Normally 7 hours (9-17, minus lunch). But the maintenance window (2-4pm, 2 hours) further reduces it to **5 usable hours**. Constraints layer recursively.

**Synthesis: Query Usable Time Across Ranges**

```ring
oCal {
    ? AvailableHoursOn("2024-10-10")              #--> 7 (Thursday, no constraints)
    ? AvailableHoursBetween("2024-10-01", "2024-10-15")  #--> 77
}
```

Oct 1-15 spans 15 calendar days, but only 11 are working days (excluding 4 weekends), yielding 11 × 7 = **77 available hours**. Every number is justified by the constraint stack.

---

## Task Fitting: Making Decisions

With capacity quantified, fit tasks objectively:

```ring
oCal {
    ? CanFit("2024-10-10", "5")   #--> TRUE (7 hours available)
    ? CanFit("2024-10-10", "10")  #--> FALSE (only 7 available)
    ? @@NL(FirstAvailableSlot("4"))
    #--> [ "2024-10-01 09:00:00", "2024-10-01 13:00:00" ]
}
```

A 5-hour task fits on Oct 10 (7 hours available). A 10-hour task doesn't. A 4-hour task starts Oct 1 at 9am, ends at 1pm (after lunch break). Decisions are transparent and auditable.

---

## Visualization: Making Time Tangible

Three views help spot bottlenecks and communicate constraints to teams.

**Grid View**

```ring
oCal.Show()
#-->
                October 2024
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│        1     2     3     4    [5]   ░░  │
│  7     8     9     10    11   ░░    ░░  │
│  14    15    16    17    18   ░░    ░░  │
│  21    22    23    24    25   ░░    ░░  │
│  28    29    30    31                   │
╰─────────────────────────────────────────╯

Legend:
  [D] = Holiday
  ░ = Weekend
```

The grid shows at a glance: weekends (â–') form a repeating pattern, Oct 5 is marked [D] (holiday on weekend). Working days are clean. Easy to spot the rhythm.

**Heatmap: Weekly Capacity**

```ring
October 2024 - Capacity Heat Map

Week 1:  ▓▓▓▓▓ (5/5 days available)
Week 2:  ▓▓▓▓▓ (5/5 days available)
Week 3:  ▓▓▓▓▓ (5/5 days available)
Week 4:  ▓▓▓▓▓ (5/5 days available)
Week 5:  ▓▓▓░░ (3/5 days available)

Legend:
  ▓ = Available working day
  ░ = Weekend or holiday
```

Week 5 dips to 3/5 days (Oct 28-31: Mon-Thu), ideal for light tasks or buffers.

**Detailed Table: Day-by-Day**

```ring
oCal.ShowTable()
#-->
October 2024 - Detailed View

╭────────────┬───────────┬───────────────────┬───────────────────┬───────────╮
│    Date    │    Day    │     Business      │      Breaks       │ Available │
├────────────┼───────────┼───────────────────┼───────────────────┼───────────┤
│ 2024-10-01 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-02 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-03 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-04 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-05 │ Saturday  │ HOLIDAY           │                   │ 0h        │
│ 2024-10-06 │ Sunday    │ WEEKEND           │                   │ 0h        │
     ...          ...            ...                  ...          ...
│ 2024-10-28 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-29 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-30 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-31 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
╰────────────┴───────────┴───────────────────┴───────────────────┴───────────╯

Summary:
  Total Days: 31
  Working Days: 23
  Available Hours: 161
```

Each row shows exactly why hours are available (or zero). HOLIDAY and WEEKEND labels make exclusions explicit.

---

## Comparison and Navigation

**What If: Compare Two Periods**

```ring
oCal1 = new stzCalendar([2024, 10])
oCal1.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal2 = oCal1.Copy()
oCal2.GotoNextMonth()

? oCal1.Current()  #--> October 2024
? oCal2.Current()  #--> November 2024

? @@NL(oCal1.CompareWith(oCal2))
#-->
# [
#     [ "Metric", "This Calendar", "Other Calendar", "Difference" ],
#     [ "Total Days", 31, 30, 1 ],
#     [ "Working Days", 23, 21, 2 ],
#     [ "Available Hours", 184, 168, 16 ],
#     [ "Holidays", 0, 0, 0 ],
#     [ "Total Weeks", 5, 5, 0 ]
# ]
```

October has 31 days (23 working), November has 30 (21 working). That's a 16-hour gap (2 fewer working days × 8 hours). Use this for sprint planning: tighter capacity in November means fewer stories.

---

## Timeline Integration: Events Meet Constraints

Overlay events to detect conflicts against constraints:

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
}

oTimeline = new stzTimeLine("2024-10-01", "2024-10-31")
oTimeline.AddPoint("STANDUP", "2024-10-10 09:00:00")
oTimeline.AddSpan("PROJECT", "2024-10-15", "2024-10-20")

oCal.MarkTimeline(oTimeline)
oCal.Show()
#-->
'
                October 2024
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│        1     2     3     4    ░░    ░░  │
│  7     8     9    ●10    11   ░░    ░░  │
│  14   ▬15   ▬16   ▬17   ▬18   ▬░░   ▬░░ │
│  21    22    23    24    25   ░░    ░░  │
│  28    29    30    31                   │
╰─────────────────────────────────────────╯

Legend:
  ░ = Weekend
  ● = Timeline-event
  ▬ = Timeline-span

╭───────────────────────┬─────────────────────╮
│        Metric         │        Value        │
├───────────────────────┼─────────────────────┤
│ Total Days            │                  31 │
│ Working Days          │                  23 │
│ Weekend Days          │                   8 │
│ Holidays              │                   0 │
│ Total Available Hours │                 184 │
│ Average Hours Per Day │                   8 │
│ First Working Day     │ 2024-10-01          │
│ Last Working Day      │ 2024-10-31          │
│ Business Hours        │ 09:00:00 - 17:00:00 │
╰───────────────────────┴─────────────────────╯
```

The STANDUP event (●) lands on Oct 10, a Thursday (working day). The PROJECT span (▬) runs Oct 15-20, crossing into weekend days (19-20, marked ▬░░). The visualization immediately shows the conflict—the project touches non-working days, requiring awareness.

```ring
? oCal.ConflictsWith(oTimeline)          #--> TRUE
? @@NL(oCal.TimelineEvents())
#-->
# [
#     [ "points", [ [ "STANDUP", "2024-10-10 09:00:00" ] ] ],
#     [ "spans", [ [ "PROJECT", "2024-10-15 00:00:00", "2024-10-20 00:00:00" ] ] ]
# ]
```

No silent failures—if a milestone touches a weekend or holiday, `ConflictsWith()` flags it explicitly.

---

## Real-World Scenario: Sprint Feasibility

Combine layers to validate sprints:

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
}

aTasks = [
    ["Design", 40],
    ["Development", 80],
    ["Testing", 32]
]

nRequired = 0
for aTask in aTasks
    nRequired += aTask[2]
next

nAvailable = oCal.AvailableHoursN()

if nRequired <= nAvailable
    ? "âœ" Sprint fits: " + nRequired + "h needed, " + nAvailable + "h available"
    #--> âœ" Sprint fits: 152h needed, 161h available
else
    ? "âœ— Capacity exceeded by " + (nRequired - nAvailable) + " hours"
ok
```

152 hours required; 161 available (23 working days × 7 hours). Sprint fits with 9-hour buffer. This calculation is bulletproof: every hour is justified by the constraint stack.

---

## Querying Details: Drilling Deeper

**Single Date Info**

```ring
oCal {
    ? @@NL(DateInfo("2024-10-03"))
    #-->
    # [
    #     [ "date", "2024-10-03" ],
    #     [ "isWorkingDay", 1 ],
    #     [ "isHoliday", 0 ],
    #     [ "availableHours", 7 ]
    # ]
}
```

Oct 3 is Thursday (working day, 7 hours). Use this for scheduling individual tasks.

**Range Summary**

```ring
? @@NL(RangeInfo("2024-10-01", "2024-10-15"))
#-->
# [
#     [ "startDate", "2024-10-01" ],
#     [ "endDate", "2024-10-15" ],
#     [ "totalDays", 15 ],
#     [ "workingDays", 11 ],
#     [ "weekendDays", 4 ],
#     [ "holidays", 0 ],
#     [ "availableHours", 77 ],
#     [ "overlappingEvents", [ ] ]
# ]
```

First half of October: 15 days span, but only 11 are working (4 weekend days excluded), yielding 77 hours. Events field shows conflicts if timeline is marked.

---

## Data Export and Integration

**Hash Export**

```ring
? @@NL(oCal.ToHash())
#-->
# [
#     [ "startdate", "2024-10-01" ],
#     [ "enddate", "2024-10-31" ],
#     [ "year", 2024 ],
#     [ "month", 10 ],
#     [ "totaldays", 31 ],
#     [ "workingdays", 23 ],
#     [ "availablehours", 184 ],
#     [ "workingdayslist", [ 1, 2, 3, 4, 5 ] ],
#     [ "holidays", [ [ "2024-10-05", "Independence Day" ] ] ],
#     [ "breaks", [ [ "12:00:00", "13:00:00", "Lunch" ] ] ],
#     [ "businessstart", "09:00:00" ],
#     [ "businessend", "17:00:00" ]
# ]
```

Full config exported as a hash—load into reports, APIs, or databases.

**Statistics**

```ring
? @@NL(oCal.Stats())
#-->
# [
#     [ "metric", "value" ],
#     [ "Total Days", 31 ],
#     [ "Working Days", 23 ],
#     [ "Weekend Days", 7 ],
#     [ "Holidays", 1 ],
#     [ "Total Available Hours", 161 ],
#     [ "Average Hours Per Day", 7 ],
#     [ "First Working Day", "2024-10-01" ],
#     [ "Last Working Day", "2024-10-31" ]
# ]
```

One-line stats for dashboards or reports.

---

## Natural Language Orientation: Intuitive API Design

Softanza prioritizes methods that read like English, with consistent naming conventions.

**Pattern: Base, Count, Existence**

For collections (days, holidays, breaks):
- Base method (e.g., `WorkingDays()`) returns a **list**
- Suffixed variant (e.g., `WorkingDaysN()`) returns the **count**
- Prefixed variant (e.g., `ContainsWorkingDays()` or alias `HasWorkingDays()`) returns a **boolean**

```ring
oCal {
    aWorkingDays = WorkingDays()                  # List of dates
    nWorkingDays = WorkingDaysN()                 # Count: 23
    bHasWorking = ContainsWorkingDays()           # Boolean: 1 (TRUE)
}
```

This is **consistent** across the API:

| Collection | List | Count | Boolean |
|-----------|------|-------|---------|
| Working Days | `WorkingDays()` | `WorkingDaysN()` | `ContainsWorkingDays()` |
| Holidays | `Holidays()` | `HolidaysN()` | `ContainsHolidays()` |
| Breaks | `Breaks()` | `BreaksN()` | `ContainsBreaks()` |
| Available Days | `AvailableDays()` | `AvailableDaysN()` | `ContainsAvailableDays()` |
| Weekends | `Weekends()` | `WeekendsN()` | `ContainsWeekends()` / `HasWeekends()` |

**Power of Consistency**: Your code reads naturally. No guessing whether a method returns a number or a list. If you see the N suffix, you know it's a count. If you see `Contains` or `Has`, you know it's a boolean check.

---

## Comparative Analysis: stzCalendar vs. Other Ecosystems

| Feature                    | Softanza (stzCalendar)            | Python (calendar + pandas)    | JavaScript (Luxon + FullCalendar) | Java (Joda-Time)           | Ruby (ActiveSupport) |
|----------------------------|-----------------------------------|-------------------------------|-----------------------------------|----------------------------|----------------------|
| **Calendar Boundaries**    | ✅ Validated scopes                | ◯ Manual ranges               | ✅ Luxon intervals                 | ✅ JodaTime intervals       | ✅ Date ranges        |
| **Working Days Config**    | ✅ Declarative, recalculates auto  | ◯ Custom loops                | ✅ FullCalendar business hours     | ◯ Custom code              | ◯ Extensions         |
| **Holiday Management**     | ✅ Add, query, name                | ◯ External libs (holidays)    | ◯ Event overlays                  | ◯ Custom code              | ✅ holidays gem       |
| **Business Hours/Breaks**  | ✅ Granular, auto-subtracted       | ◯ timedeltas (manual)         | ✅FullCalendar constraints         | ◯ Durations only           | ◯ Manual math        |
| **Capacity Calculations**  | ✅ Hours/days/ranges, task fitting | ◯ Custom scripts              | ◯ Event durations only            | ✅ Basic arithmetic         | ◯ Manual time math   |
| **Visualizations**         | ✅ Grid + heatmap + table (ASCII)  | ◯ Matplotlib plots            | ✅FullCalendar UI                  | ✅ Text dump only           | ✅ CLI text           |
| **Timeline Integration**   | ✅ Mark events, detect conflicts   | ◯ Pandas timelines (post-hoc) | ✅FullCalendar events              | ◯ Intervals (no conflicts) | ◯ Ranges only        |
| **Multi-Calendar Compare** | ✅ Side-by-side metrics            | ◯ DataFrame diffs             | ◯ Not standard                    | ◯ Not standard             | ◯ Not standard       |
| **Export Formats**         | ✅ Hash/JSON/CSV                   | ✅CSV/JSON                     | ◯ JSON only                       | ◯ String serialization     | ✅ JSON               |
| **Planning-First Design**  | ✅ Built-in reasoning engine       | ◯ Requires assembly           | ◯ UI-centric, not code-centric    | ✅ Low-level primitives     | ◯ Extension-based    |

**Key Differences**:

- **Softanza**: Constraints are first-class, baked into every query. Capacity is computed on demand, not manually. Visualizations are integrated. Timeline conflicts are detected automatically.
- **Python**: Powerful data manipulation, but requires glue code to tie calendar, holidays, and business hours together. `pandas` excels at analysis but has no capacity-planning primitives.
- **JavaScript**: FullCalendar dominates UI-based scheduling. Luxon handles date math well. But reasoning about constraints is delegated to application code; no built-in capacity engine.
- **Java/Joda-Time**: Low-level, precise, but verbose. You build calendars from primitives—no opinions, no shortcuts.
- **Ruby**: ActiveSupport provides helpers, but capacity planning requires external gems or custom code.

**Verdict**: Softanza excels when you need to *reason* about time in code. Python and JS win at visualization and data analysis. Java and Ruby are sufficient for simple date handling but require assembly for planning.

---

## Conclusion

`stzCalendar` transforms time from an abstract liability into a concrete, queryable resource. Layers of constraints (boundaries → working days → holidays → business hours → breaks → custom rules) compound predictably, ensuring no hidden time is lost. Visualizations make patterns visible, comparisons reveal trade-offs, and exports feed reports. For Ring developers in capacity-constrained domains—Agile teams, ops, resource planning—it's the foundation for honest, auditable scheduling.