# Narrative
# --------
# Single item test
#
# Extracted from stzPlotTest.ring, block #62.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oPlot10 = new stzSurfacePlot([
    :Total = 100
])
oPlot10.AddPercent().Show()
#-->
'
╭──────────────────────────────────────╮
│                                      │
│                                      │
│                                      │
│                                      │
│                Total                 │
│                 100%                 │
│                                      │
│                                      │
│                                      │
│                                      │
╰──────────────────────────────────────╯
'

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
