# Narrative
# --------
# 5-item test (recursive division)
#
# Extracted from stzPlotTest.ring, block #57.
#Error (R14) : Calling Method without definition: removedfromend
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"


pr()

oPlot4 = new stzSurfacePlot([
    :A = 40,
    :B = 25,
    :C = 15,
    :D = 12,
    :E = 8
])
oPlot4.AddPercent().Show()
#--> 
'
╭──────────────┬─────────┬─────┬───────╮
│              │         │     │       │
│              │         │     │  D    │
│              │         │     │ 12%   │
│              │         │     │       │
│      A       │   B     │ C   │       │
│     40%      │  25%    │15%  │       │
│              │         │     ├───────┤
│              │         │     │  E    │
│              │         │     │  8%   │
│              │         │     │       │
╰──────────────┴─────────┴─────┴───────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.22
