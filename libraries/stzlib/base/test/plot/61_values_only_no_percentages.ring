# Narrative
# --------
# Values only (no percentages)
#
# Extracted from stzPlotTest.ring, block #61.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oPlot9 = new stzSurfacePlot([
    :Server1 = 120,
    :Server2 = 80,
    :Server3 = 45,
    :Server4 = 35
])
oPlot9.AddValues().Show()
#-->
'
╭───────────────────────────┬──────────╮
│                           │          │
│         Server1           │ Server3  │
│           120             │   45     │
│                           │          │
│                           │          │
│                           ├──────────┤
├───────────────────────────│ Server4  │
│         Server2           │   35     │
│            80             │          │
│                           │          │
╰───────────────────────────┴──────────╯
'

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.06 second(s) in Ring 1.22
