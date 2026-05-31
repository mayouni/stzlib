# Narrative
# --------
# #  Display variants              #
#
# Extracted from stzcalendartest.ring, block #42.

load "../../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    ? BoxRound("Short Display")
    ShowShort()
    
    ? nl + BoxRound("Default Display")
    Show()
}
#-->
'
╭───────────────╮
│ Short Display │
╰───────────────╯
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

╭─────────────────╮
│ Default Display │
╰─────────────────╯
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

╭───────────────────────┬─────────────────────╮
│        Metric         │        Value        │
├───────────────────────┼─────────────────────┤
│ Total Days            │                  31 │
│ Working Days          │                  23 │
│ Weekend Days          │                   7 │
│ Holidays              │                   1 │
│ Total Available Hours │                 184 │
│ Average Hours Per Day │                   8 │
│ First Working Day     │ 2024-10-01          │
│ Last Working Day      │ 2024-10-31          │
│ Business Hours        │ 09:00:00 - 17:00:00 │
│ Holidays Listed       │ Holiday             │
╰───────────────────────┴─────────────────────╯

Executed in 0.83 second(s) in Ring 1.24
'

pf()
# Executed in 0.83 second(s) in Ring 1.24
