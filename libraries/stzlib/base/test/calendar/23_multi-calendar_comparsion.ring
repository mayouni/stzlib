# Narrative
# --------
# #  Multi-calendar Comparsion  #
#
# Extracted from stzcalendartest.ring, block #23.

load "../../stzBase.ring"

#-----------------------------#

pr()

oCal1 = new stzCalendar([ 2024, 2 ])
oCal2 = new stzCalendar([ 2029, 2 ])

? oCal1.CompareToQR(oCal2, :stzTable).Show()
#-->
'
╭─────────────────┬───────────────┬───────────────┬────────────╮
│     Metric      │ February 2024 │ February 2029 │ Difference │
├─────────────────┼───────────────┼───────────────┼────────────┤
│ Total Days      │            29 │            28 │          1 │
│ Working Days    │            21 │            20 │          1 │
│ Available Hours │           168 │           160 │          8 │
│ Holidays        │             0 │             0 │          0 │
│ Total Weeks     │             5 │             4 │          1 │
╰─────────────────┴───────────────┴───────────────┴────────────╯
'

pf()
# Executed in 0.28 second(s) in Ring 1.24
