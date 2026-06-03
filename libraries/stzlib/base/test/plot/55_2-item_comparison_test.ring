# Narrative
# --------
# 2-item comparison test
#
# Extracted from stzPlotTest.ring, block #55.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oPlot = new stzSurfacePlot([
    :Desktop = 75,
    :Mobile = 25
])
oPlot.AddPercent().Show()
#-->
'
╭────────────────────────────┬─────────╮
│                            │         │
│                            │         │
│                            │         │
│                            │         │
│          Desktop           │ Mobile  │
│            75%             │  25%    │
│                            │         │
│                            │         │
│                            │         │
│                            │         │
╰────────────────────────────┴─────────╯
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
