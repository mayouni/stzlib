# Time Capacity Planning in Softanza: Mastering Constraints with `stzCalendar`

> *Time isn't infinite—it's shaped by weekends, holidays, breaks, and real-world chaos. What if your code could model that chaos and turn it into actionable insights? Enter `stzCalendar` from SoftanzaLib, a powerhouse for reasoning about time in Ring programming.*

In project management, software development, or even personal scheduling, a calendar is more than a grid of dates—it's a dynamic constraint engine. Traditional tools like spreadsheets force you to manually track holidays, calculate available hours, and spot conflicts. Mistakes creep in, deadlines slip. Softanza's `stzCalendar` changes that by letting you *build* a calendar as code: configure it, query it, visualize it, and integrate it with timelines. It's not just data—it's intelligent, validated time.


---

## Getting Started: Defining Your Time Boundaries

Start by instantiating a calendar with a year/month, full year, quarter, or custom range. Softanza validates inputs automatically—no invalid dates slip through.

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

*Practicality*: This sets a "fenced" time scope. Query outside it? Error. It's perfect for sprint planning where you focus on one month without accidental spillover.

---

## Configuring the Rhythm: Working Days and Weekends

Real calendars respect weekends. Define working days to filter out non-productive time.

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

*Power Move*: This auto-excludes weekends from capacity calcs. In a global team? Customize per region (e.g., exclude Friday for some cultures).

---

## Handling Exceptions: Holidays and Custom Blocks

Holidays disrupt flow—`stzCalendar` lets you add them singly or in bulk, with names for context.

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

*Practicality*: Holidays reduce available days dynamically. Query `HolidaysBetween()` for ranges to plan around events like national shutdowns.

---

## Granular Time: Business Hours, Breaks, and Constraints

Go beyond days—model hours. Set office times and subtract breaks or custom constraints (e.g., weekly maintenance).

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

Add constraints for recurring blocks:

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

*Power Move*: Constraints auto-adjust capacity. Ideal for IT ops where servers go down weekly—prevent scheduling conflicts.

---

## Core Strength: Capacity Calculations and Task Fitting

The killer feature: Quantify *usable* time. Combine all constraints for instant answers.

```ring
oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? AvailableHours()                      #--> 161 (total usable hours)
    ? AvailableDays()                       #--> 23 (working days minus holidays)
    ? AvailableHoursOn("2024-10-10")        #--> 7 (single day, post-breaks)
    ? AvailableHoursBetween("2024-10-01", "2024-10-15")  #--> 77 (range total)
}
```

Fit tasks intelligently:

```ring
oCal {
    ? CanFit("2024-10-10", "5")             #--> TRUE
    ? CanFit("2024-10-10", "10")            #--> FALSE
    ? @@NL(FirstAvailableSlot("4"))         #--> [ "2024-10-01 09:00:00", "2024-10-01 13:00:00" ] (start/end of slot)
}
```

*Practicality*: For Agile teams, check if a 40-hour task fits a sprint. No manual math—Softanza computes it.

---

## Intelligent Queries: Date and Range Insights

Drill down with contextual info.

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

*Power Move*: Use for reporting—e.g., "How many hours in Q4 after holidays?"

---

## Visualization: See Your Constraints

Three views make abstract time tangible.

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

*Practicality*: Visuals spot overloads fast—e.g., heatmap for "Which week is slammed?"

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

Copy and compare:

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
#     ... (full metrics: working days, hours, etc.)
# ]
```

*Power Move*: Simulate "what if" scenarios, like comparing Q3 vs. Q4 capacity.

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

Merge with `stzTimeLine` for event-aware calendars.

```ring
oCal = new stzCalendar([2024, 10])
oTimeline = new stzTimeLine("2024-10-01", "2024-10-31")
oTimeline.AddPoint("STANDUP", "2024-10-10 09:00:00")
oTimeline.AddSpan("PROJECT", "2024-10-15", "2024-10-20")

oCal.MarkTimeline(oTimeline)
oCal.Show()  # Grid now shows ● (points) and ▬ (spans)

? oCal.ConflictsWith(oTimeline)          #--> TRUE (if overlaps holidays/weekends)
? @@NL(oCal.TimelineEventsSummary())     #--> Event counts, durations, conflicts
```

*Practicality*: Detect if a project span hits a holiday—prevent scheduling fails.

---

## Real-World Power: Sprint Planning Example

Tie it together for a sprint:

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

*Power Move*: Automate feasibility checks—scale to teams with varying constraints.


## How `stzCalendar` Compares to Other Languages/Frameworks

While many languages have date utilities, few offer integrated capacity planning with visualizations and constraints. Softanza's `stzCalendar` excels in modeling *usable time* for planning. Here's a comparative grid based on common libraries (e.g., Python's `calendar` + `pandas`, JavaScript's Luxon + FullCalendar, Java's Joda-Time, Ruby's ActiveSupport).

| Feature                  | Softanza (Ring/stzCalendar) | Python (calendar + pandas) | JavaScript (Luxon + FullCalendar) | Java (Joda-Time) | Ruby (ActiveSupport) |
|--------------------------|-----------------------------|-----------------------------|-----------------------------------|------------------|-----------------------|
| **Basic Date Boundaries**| Yes (validated scopes)     | Partial (manual ranges)    | Yes (ranges in Luxon)            | Yes (intervals) | Yes (date ranges)    |
| **Working Days Config**  | Yes (customizable)         | Partial (need custom logic)| Yes (FullCalendar work hours)   | Partial (custom) | Partial (extensions) |
| **Holidays Management**  | Yes (add/query with names) | Partial (external libs like holidays-py) | Partial (event overlays) | Partial (custom) | Yes (holidays gem)   |
| **Business Hours/Breaks**| Yes (granular, auto-subtract) | Partial (pandas timedeltas) | Yes (FullCalendar constraints)  | Partial (durations) | Partial (time calc)  |
| **Capacity Calculations**| Yes (hours/days/ranges, task fitting) | Partial (custom scripts) | Partial (event duration calcs)   | No (basic durations) | Partial (time math)  |
| **Visualizations**       | Yes (grid, heatmap, table) | Partial (matplotlib plots) | Yes (UI calendar views)         | No (text only)   | No (text/CLI)        |
| **Timeline Integration** | Yes (mark events, detect conflicts) | Partial (pandas timelines) | Yes (FullCalendar events)       | Partial (intervals) | Partial (ranges)     |
| **Multi-Calendar Compare**| Yes (side-by-side metrics) | Partial (pandas diffs)     | No                               | No              | No                   |
| **Data Export**          | Yes (hash/JSON/CSV)        | Yes (CSV/JSON via pandas)  | Partial (JSON export)            | Partial (strings)| Yes (JSON)           |
| **Practicality for Planning** | High (built-in reasoning) | Medium (requires glue code)| High (UI-focused)               | Low (low-level)  | Medium (extensions needed) |

*Insights*: Softanza shines in *declarative planning*—code your constraints once, query forever. Python needs assembly; JS is UI-heavy; Java/Ruby are more primitive. For devs in Ring, it's a no-brainer for time-bound apps.

---

## Conclusion: Reason with Time, Don't Fight It

`stzCalendar` transforms time from a liability into an asset. By embedding constraints, calculations, and visuals in code, Softanza empowers precise planning—whether for sprints, ops, or personal use. It's fast (most ops in <0.1s), expressive, and integrated. Dive in: Load SoftanzaLib and build your first calendar today. Your deadlines will thank you.