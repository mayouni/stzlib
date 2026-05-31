# Narrative
# --------
# pr()
#
# Extracted from stzcalendartest.ring, block #1.

load "../../../stzBase.ring"


#TODO // This is a special case we should manage
StzCalendarQ([1528, 10 ]).Show()
#-->
'
                October 1528
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│  1     2     3     4     5    ░░    ░░  │
│  8     9     10    11    12   ░░    ░░  │
│  15    16    17    18    19   ░░    ░░  │
│  22    23    24    25    26   ░░    ░░  │
│  29    30    31                         │
╰─────────────────────────────────────────╯

Legend:
  ░ = Weekend

╭───────────────────────┬─────────────────────╮
│        Metric         │        Value        │
├───────────────────────┼─────────────────────┤
│ Total Days            │                  31 │
│ Working Days          │                  23 │
│ Weekend Days          │                   8 │
│ Holidays              │                   0 │
│ Total Available Hours │                 184 │
│ Average Hours Per Day │                   8 │
│ First Working Day     │ 1528-10-01          │
│ Last Working Day      │ 1528-10-31          │
│ Business Hours        │ 09:00:00 - 17:00:00 │
╰───────────────────────┴─────────────────────╯
'

pf()
# Executed in 0.38 second(s) in Ring 1.26
