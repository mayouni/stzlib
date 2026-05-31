# Narrative
# --------
# #  Test 8: Display options                #
#
# Extracted from stzcalendartest.ring, block #9.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    Show()
}
#-->
'
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

╭───────────────────────┬──────────────────────────╮
│        Metric         │          Value           │
├───────────────────────┼──────────────────────────┤
│ Total Days            │                       31 │
│ Working Days          │                       23 │
│ Weekend Days          │                        7 │
│ Holidays              │                        1 │
│ Total Available Hours │                      161 │
│ Average Hours Per Day │                        7 │
│ First Working Day     │ 2024-10-01               │
│ Last Working Day      │ 2024-10-31               │
│ Business Hours        │ 09:00:00 - 17:00:00      │
│ Holidays Listed       │ Independence Day         │
│ Breaks                │ Lunch: 12:00:00-13:00:00 │
╰───────────────────────┴──────────────────────────╯
'

pf()
# Executed in 0.34 second(s) in Ring 1.24
