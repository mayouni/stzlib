# Time Capacity Planning in Softanza: Mastering Constraints with `stzCalendar`

> *Time isn't infinite—it's shaped by weekends, holidays, breaks, and real-world chaos. What if your code could model that chaos and turn it into actionable insights? Enter `stzCalendar` from SoftanzaLib, a powerhouse for reasoning about time in Ring programming.*

In the world of project management, software development, or even personal scheduling, a calendar is more than a grid of dates—it's a dynamic constraint engine. Traditional tools like spreadsheets force you to manually track holidays, calculate available hours, and spot conflicts. Mistakes creep in, deadlines slip. Softanza's `stzCalendar` changes that by letting you *build* a calendar as code: configure it, query it, visualize it, and integrate it with timelines. It's not just data—it's intelligent, validated time.

Drawing from real-world tests in Softanza's implementation (as seen in `stzCalendarTest.ring`), we'll walk through its features step-by-step. Each example includes code, output, and practical insights, with explanations of *why* the results make sense based on layered constraints. By the end, you'll see why `stzCalendar` stands out for capacity planning—and how it stacks up against counterparts in other languages.

---

## Getting Started: Defining Your Time Boundaries

Start by instantiating a calendar with a year/month, full year, quarter, or custom range. Softanza validates inputs automatically—no invalid dates slip through, preventing silent errors like date overflows.

```ring
load "../stzbase.ring"

oCal = new stzCalendar([2024, 10])
```

Key queries reveal the basics:

```ring
oCal {
    ? Start()      #--> 2024-10-01
    ? End_()       #--> 2024-10-31
    ? Year()       #--> 2024
    ? MonthName()  #--> October
    ? TotalDays()  #--> 31
}
```

*Practicality*: This sets a "fenced" time scope—October 2024 spans 31 days, starting on a Tuesday and ending on a Thursday. Query outside it? Error. It's perfect for sprint planning where you focus on one month without accidental spillover.

---

## Configuring the Rhythm: Working Days and Weekends

Real calendars respect weekends. Define working days to filter out non-productive time automatically.

```ring
oCal = new stzCalendar([2024, 10])
oCal.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
```

Now, interrogate it:

```ring
oCal {
    ? IsWorkingDay("2024-10-03")  #--> 1 (TRUE, Thursday)
    ? IsWorkingDay("2024-10-05")  #--> 0 (FALSE, Saturday)
    ? FirstWorkingDay()           #--> 2024-10-01
    ? len(WorkingDays())          #--> 23 (all working dates listed)
}
```

*Power Move*: October 2024 has 31 days, but with Mon-Fri as working days, only 23 are available (31 total minus 8 weekends: Oct 5-6, 12-13, 19-20, 26-27). This auto-excludes weekends from all downstream capacity calculations. In a global team? Customize per region (e.g., exclude Friday for some cultures).

---

## Handling Exceptions: Holidays and Custom Blocks

Holidays disrupt flow—`stzCalendar` lets you add them singly or in bulk, with names for context. They layer on top of working days, blocking even if they fall on weekends (for accurate tracking).

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    AddHoliday("2024-10-05", "Independence Day")
    AddHoliday("2024-10-15", "National Day")
    
    ? IsHoliday("2024-10-05")      #--> 1 (TRUE)
    ? HolidayName("2024-10-05")    #--> Independence Day
    ? len(Holidays())              #--> 2
}
```

*Practicality*: Holidays reduce usable time dynamically. Here, Oct 5 (a Saturday, already non-working) is marked, but it doesn't further reduce working days since weekends are excluded. Oct 15 (Tuesday) would drop working days by 1 if added. Query `HolidaysBetween()` for ranges to plan around events like national shutdowns.

---

## Granular Time: Business Hours, Breaks, and Constraints

Go beyond days—model hours. Set office times and subtract breaks or custom constraints (e.g., weekly maintenance) for precise capacity.

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? @@NL(BusinessHours())
    #-->
    # [
    #     [ "from", "09:00:00" ],
    #     [ "to", "17:00:00" ]
    # ]
    
    ? @@NL(Breaks())
    #-->
    # [
    #     [ "12:00:00", "13:00:00", "Lunch" ]
    # ]
}
```

Add recurring constraints:

```ring
oCal.AddConstraint("MaintWindow", [:Every, :Wednesday, :From, "14:00", :To, "16:00"])
? "Hours on Wednesday 2024-10-09: " + oCal.ApplyConstraints("2024-10-09")  #--> 5
? @@NL(oCal.Constraints())
#-->
# [
#     [
#         "MaintWindow",
#         [
#             "every",
#             "wednesday",
#             "from",
#             "14:00",
#             "to",
#             "16:00"
#         ]
#     ]
# ]
```

*Power Move*: Each working day starts with 8 hours (9-17), minus 1 for lunch = 7. On Wednesdays, subtract another 2 for maintenance = 5. Constraints auto-adjust capacity across matching days. Ideal for IT ops where servers go down weekly—prevent scheduling conflicts.

---

## Core Strength: Capacity Calculations and Task Fitting

The killer feature: Quantify *usable* time. Combine all constraints for instant, auditable answers.

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? AvailableHours()                      #--> 161 (total usable hours)
    ? AvailableDays()                       #--> 23 (working days, holiday on weekend doesn't reduce)
    ? AvailableHoursOn("2024-10-10")        #--> 7 (single day, post-breaks)
    ? AvailableHoursBetween("2024-10-01", "2024-10-15")  #--> 77 (range total)
}
```

These numbers are defensible: 23 working days × 7 hours/day (8 - 1 lunch) = 161 total. The range (Oct 1-15) covers 11 working days × 7 = 77 hours. No guesswork—constraints justify every figure.

Fit tasks intelligently:

```ring
oCal {
    ? CanFit("2024-10-10", "5")             #--> TRUE
    ? CanFit("2024-10-10", "10")            #--> FALSE
    ? @@NL(FirstAvailableSlot("4"))         #--> [ "2024-10-01 09:00:00", "2024-10-01 13:00:00" ] (start/end of slot)
}
```

*Practicality*: For Agile teams, check if a 40-hour task fits a sprint. Objective math replaces hunches.

---

## Intelligent Queries: Date and Range Insights

Drill down with contextual info for any date or period.

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
}
```

*Power Move*: Use for reporting—e.g., "How many hours in the first half of October after constraints?" The range breakdown shows exactly why: 15 total days include 4 weekends, leaving 11 working × 7 hours = 77.

---

## Visualization: See Your Constraints

Three views make abstract time tangible, helping spot bottlenecks at a glance.

1. **Grid View** (with holidays/weekends marked):

```ring
oCal.Show()
#-->
#                 October 2024
# ╭─────────────────────────────────────────╮
# │ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
# ├─────────────────────────────────────────┤
# │        1     2     3     4    [5]   ░░  │
# │  7     8     9     10    11   ░░    ░░  │
# │  14    15    16    17    18   ░░    ░░  │
# │  21    22    23    24    25   ░░    ░░  │
# │  28    29    30    31                   │
# ╰─────────────────────────────────────────╯
# Legend:
#   [D] = Holiday
#   ░░  = Weekend
# 
# ╭───────────────────────┬──────────────────────────╮
# │        Metric         │          Value           │
# ├───────────────────────┼──────────────────────────┤
# │ Total Days            │                       31 │
# │ Working Days          │                       23 │
# │ Weekend Days          │                        7 │
# │ Holidays              │                        1 │
# │ Total Available Hours │                      161 │
# │ Average Hours Per Day │                        7 │
# │ First Working Day     │ 2024-10-01               │
# │ Last Working Day      │ 2024-10-31               │
# │ Business Hours        │ 09:00:00 - 17:00:00      │
# │ Holidays Listed       │ Independence Day         │
# │ Breaks                │ Lunch: 12:00:00-13:00:00 │
# ╰───────────────────────┴──────────────────────────╯
```

The grid visualizes the month, with [5] marking the holiday on a weekend (░░). The summary ties back to calculations: 23 days × 7 hours = 161.

2. **Heatmap** (weekly density):

```ring
oCal.ShowHeatMap()
#-->
# October 2024 - Capacity Heat Map
# 
# Week 1:  ▓▓▓▓▓ (5/5 days available)
# Week 2:  ▓▓▓▓▓ (5/5 days available)
# Week 3:  ▓▓▓▓▓ (5/5 days available)
# Week 4:  ▓▓▓▓▓ (5/5 days available)
# Week 5:  ▓▓▓░░ (3/5 days available)
# 
# Legend:
#   ▓ = Available working day
#   ░ = Weekend or holiday
```

Week 5 has only 3 available days (Oct 28-31: Mon-Thu, but 31 is Thu), highlighting lighter capacity for buffer planning.

3. **Detailed Table** (day-by-day):

```ring
oCal.ShowTable()
#-->
# October 2024 - Detailed View
# 
# ╭────────────┬───────────┬───────────────────┬───────────────────┬───────────╮
# │    Date    │    Day    │     Business      │      Breaks       │ Available │
# ├────────────┼───────────┼───────────────────┼───────────────────┼───────────┤
# │ 2024-10-01 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
# ... (truncated for brevity; full 31 days shown with holidays as "HOLIDAY", weekends as "WEEKEND")
# ╰────────────┴───────────┴───────────────────┴───────────────────┴───────────╯
# Summary:
#   Total Days: 31
#   Working Days: 23
#   Available Hours: 161
```

*Practicality*: Visuals make constraints tangible—e.g., the heatmap spots "light weeks" for low-priority tasks.

---

## Navigation and Copying: Fluid Time Travel

Jump months/years or copy for scenarios.

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    ? Current()         #--> October 2024
    GotoNextMonth()
    ? Current()         #--> November 2024
    GoToPreviousMonth()
    ? Current()         #--> October 2024
    GoTo("2024-09-10")  # Jumps to September (updates scope)
}
```

Copy and compare for "what-if" analysis:

```ring
oCal1 = new stzCalendar([2024, 10])
oCal1.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal2 = oCal1.Copy()
oCal2.GotoNextMonth()

? "Original: " + oCal1.Current()  #--> October 2024
? "Copy: " + oCal2.Current()      #--> November 2024

? @@NL(oCal1.CompareWith(oCal2))
#-->
# [
#     [
#         "Metric",
#         "This Calendar",
#         "Other Calendar",
#         "Difference"
#     ],
#     [
#         "Total Days",
#         31,
#         30,
#         1
#     ],
#     [
#         "Working Days",
#         23,
#         21,
#         2
#     ],
#     [
#         "Available Hours",
#         184,
#         168,
#         16
#     ],
#     [
#         "Holidays",
#         0,
#         0,
#         0
#     ],
#     [
#         "Total Weeks",
#         5,
#         5,
#         0
#     ]
# ]
```

*Power Move*: October (31 days) vs. November (30 days) shows differences like 2 fewer working days, leading to 16 fewer hours (assuming 8h/day here, no breaks). Use for seasonal planning.

---

## Data Export and Stats: From Code to Reports

Export for integration:

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
    SetBusinessHours("09:00:00", "17:00:00")
}

? @@NL(oCal.ToHash())
#-->
# [
#     [ "startdate", "2024-10-01" ],
#     [ "enddate", "2024-10-31" ],
#     ... (full config: working days, holidays, etc.)
# ]
```

Quick stats:

```ring
? @@NL(oCal.Stats())
#-->
# [
#     [ "metric", "value" ],
#     [ "Total Days", 31 ],
#     ... (working days, hours, etc.)
# ]
```

---

## Timeline Integration: Overlaying Events

Merge with `stzTimeLine` for event-aware calendars, detecting conflicts against constraints.

```ring
oCal = new stzCalendar([ 2024, 10 ])
oCal.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
oCal.AddHoliday("2024-10-05", "Independence Day")

oTimeline = new stzTimeLine("2024-10-01", "2024-10-31")
oTimeline.AddPoint("STANDUP", "2024-10-10 09:00:00")
oTimeline.AddSpan("PROJECT", "2024-10-15", "2024-10-20")

oCal.MarkTimeline(oTimeline)
oCal.Show()  # Grid now shows ● (points) and ▬ (spans)
#-->
#                 October 2024
# ╭─────────────────────────────────────────╮
# │ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
# ├─────────────────────────────────────────┤
# │        1     2     3     4    ░░    ░░  │
# │  7     8     9    ●10    11   ░░    ░░  │
# │  14   ▬15   ▬16   ▬17   ▬18   ▬░░   ▬░░ │
# │  21    22    23    24    25   ░░    ░░  │
# │  28    29    30    31                   │
# ╰─────────────────────────────────────────╯
# Legend:
#   [D] = Holiday
#   ░░  = Weekend
#   ● = Timeline event
# 
# ╭───────────────────────┬─────────────────────╮
# │        Metric         │        Value        │
# ├───────────────────────┼─────────────────────┤
# │ Total Days            │                  31 │
# │ Working Days          │                  23 │
# │ Weekend Days          │                   8 │
# │ Holidays              │                   0 │
# │ Total Available Hours │                 184 │
# │ Average Hours Per Day │                   8 │
# │ First Working Day     │ 2024-10-01          │
# │ Last Working Day      │ 2024-10-31          │
# │ Business Hours        │ 09:00:00 - 17:00:00 │
# ╰───────────────────────┴─────────────────────╯

? oCal.ConflictsWith(oTimeline)          #--> TRUE (if overlaps holidays/weekends; here, project span hits weekend days)
? @@NL(oCal.TimelineEventsSummary())     #--> Event counts, durations, conflicts
#-->
# [
#     [
#         "label",
#         "count",
#         "duration",
#         "conflicts"
#     ],
#     [
#         "Points",
#         1,
#         "—",
#         0
#     ],
#     [
#         "Spans",
#         1,
#         "—",
#         0
#     ]
# ]
```

*Practicality*: The project span (Oct 15-20) crosses a weekend (19-20), triggering conflicts. No silent scheduling fails—ideal for validating milestones.

---

## Real-World Power: Sprint Planning Example

Tie it together for a sprint feasibility check:

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

nAvailable = oCal.AvailableHours()

if nRequired <= nAvailable
    ? "✓ Sprint fits: " + nRequired + "h needed, " + nAvailable + "h available"
    #--> ✓ Sprint fits: 152h needed, 161h available
else
    ? "✗ Capacity exceeded by " + (nRequired - nAvailable) + " hours"
ok
```

*Power Move*: 152 required fits into 161 available (23 days × 7h). If tasks grew to 170? "✗ Exceeded by 9 hours." Automate for teams with varying constraints.

---

## Natural Language Orientation: Enhancing Programmer Experience

One of `stzCalendar`'s standout design principles is its *natural language orientation*, which prioritizes intuitive, readable code that mirrors how developers think and speak about time. This is achieved through thoughtful method naming conventions that disambiguate results without verbosity, improving flow and reducing cognitive load.

For collection-based queries (e.g., days, holidays, breaks), the base method like `AvailableDays()` returns a *list* of items (e.g., dates as strings), while the suffixed `AvailableDaysN()` returns the *number* (count). This lets you chain naturally: get the list for iteration or the count for quick checks. Similarly, `ContainsAvailableDays()` (or alias `HasAvailableDays()`) returns a boolean for existence, allowing safe guards before operations.

Consistency check across similar methods:
- **WorkingDays()**: Returns list of working dates; `WorkingDaysN()`: count; `ContainsWorkingDays()`: bool (>0). *Consistent*.
- **Holidays()**: List of holiday pairs [date, name]; `HolidaysN()`: count; `ContainsHolidays()`: bool. *Consistent*.
- **Breaks()**: List of break triples [start, end, label]; `BreaksN()`: count; `ContainsBreaks()`: bool. *Consistent*.
- **AvailableDays()**: List of available dates; `AvailableDaysN()`: count; `ContainsAvailableDays()`: bool. *Consistent*.
- Range variants (e.g., `AvailableDaysBetween()`: list; `AvailableDaysBetweenN()`: count; `ContainsAvailableDaysBetween()`: bool) extend the pattern. *Consistent*.

> Even exceptions to this rule follow natural semantics. For instance, when working with aggregates like minutes — which have no natural list form — `AvailableMinutes()` returns the number directly, without requiring an **N** suffix. However, you may still use `AvailableMinutesN()` for consistency if you prefer.

This design shines in programmer experience:
- **Readability**: Code reads like English—`if oCal.ContainsAvailableDays() { for date in oCal.AvailableDays() { ... } }` flows naturally, avoiding awkward `if len(oCal.AvailableDays()) > 0`.
- **Safety**: `Contains...()` encourages checks, preventing errors on empty results (e.g., no working days in a weekend-only range).
- **Flexibility**: Need a count? Use N-suffix for quick math (`total = oCal.WorkingDaysN() + oCal.HolidaysN()`). Need details? Base method gives the list.
- **Discovery**: Intuitive aliases like `HowManyAvailableDays()` (= `AvailableDaysN()`) and `CountHolidays()` enhance discoverability without docs.

In practice, this reduces bugs (e.g., assuming a method returns a list when it doesn't) and speeds development—your code *thinks* like you do. Compared to rigid APIs in other libs, Softanza's approach feels human-centered, boosting productivity in time-sensitive apps.

---

## API Reference

| Category | Key Methods | Purpose |
|----------|-------------|---------|
| **Basics** | `Start()`, `End_()`, `TotalDays()`, `Current()` | Scope and metadata |
| **Config** | `SetWorkingDays()`, `AddHoliday()`, `SetBusinessHours()`, `AddBreak()`, `AddConstraint()` | Define rhythms and blocks |
| **Capacity** | `AvailableHours()`, `AvailableDays()`, `CanFit()`, `FirstAvailableSlot()` | Quantify and fit tasks |
| **Queries** | `DateInfo()`, `RangeInfo()`, `IsWorkingDay()`, `IsHoliday()` | Temporal insights |
| **Viz** | `Show()`, `ShowHeatMap()`, `ShowTable()` | Visual outputs |
| **Nav/Compare** | `GotoNextMonth()`, `Copy()`, `CompareWith()` | Time travel and diffs |
| **Export** | `ToHash()`, `ToJSON()`, `ToCSV()`, `Stats()` | Data out |
| **Integration** | `MarkTimeline()`, `ConflictsWith()`, `TimelineEventsSummary()` | Event overlays |

---

## How `stzCalendar` Compares to Other Languages/Frameworks

While many languages have date utilities, few offer integrated capacity planning with visualizations and constraints. Softanza's `stzCalendar` excels in modeling *usable time* for planning. Here's a comparative grid based on common libraries (e.g., Python's `calendar` + `pandas`, JavaScript's Luxon + FullCalendar, Java's Joda-Time, Ruby's ActiveSupport).

| Feature                  | Softanza (Ring/stzCalendar) | Python (calendar + pandas) | JavaScript (Luxon + FullCalendar) | Java (Joda-Time) | Ruby (ActiveSupport) |
|--------------------------|-----------------------------|-----------------------------|-----------------------------------|------------------|-----------------------|
| **Basic Date Boundaries**| ✓ Validated scopes         | ◐ Manual ranges            | ✓ Luxon ranges                   | ✓ Intervals     | ✓ Date ranges        |
| **Working Days Config**  | ✓ Customizable              | ◐ Custom logic             | ✓ FullCalendar hours             | ◐ Custom        | ◐ Extensions         |
| **Holidays Management**  | ✓ Add/query with names      | ◐ External libs            | ◐ Event overlays                 | ◐ Custom        | ✓ Holidays gem       |
| **Business Hours/Breaks**| ✓ Granular auto-subtract    | ◐ Pandas timedeltas        | ✓ Constraints                    | ◐ Durations     | ◐ Time math          |
| **Capacity Calculations**| ✓ Hours/days/ranges, task fitting | ◐ Custom scripts    | ◐ Event durations                | ✗ Basic only    | ◐ Time math          |
| **Visualizations**       | ✓ Grid/heatmap/table        | ◐ Matplotlib plots         | ✓ UI calendar                    | ✗ Text only     | ✗ Text/CLI           |
| **Timeline Integration** | ✓ Mark events, detect conflicts | ◐ Pandas timelines     | ✓ FullCalendar events            | ◐ Intervals     | ◐ Ranges             |
| **Multi-Calendar Compare**| ✓ Side-by-side metrics     | ◐ Pandas diffs             | ✗                                | ✗               | ✗                    |
| **Data Export**          | ✓ Hash/JSON/CSV             | ✓ CSV/JSON                 | ◐ JSON export                    | ◐ Strings       | ✓ JSON               |
| **Planning-First Design**| ✓ Built-in reasoning        | ◐ Glue code needed         | ◐ UI-focused                     | ✗ Low-level     | ◐ Extensions needed  |

**Legend**: ✓ Native, ◐ Partial/workaround, ✗ Not available

*Insights*: Softanza shines in *declarative planning*—code your constraints once, query forever. Python needs assembly; JS is UI-heavy; Java/Ruby are more primitive. For devs in Ring, it's a no-brainer for time-bound apps.

---

## Conclusion: Reason with Time, Don't Fight It

`stzCalendar` transforms time from a liability into an asset. By embedding constraints, calculations, and visuals in code, Softanza empowers precise planning—whether for sprints, ops, or personal use. It's fast (most ops in <0.1s), expressive, and integrated. Dive in: Load SoftanzaLib and build your first calendar today. Your deadlines will thank you.