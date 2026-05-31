# Narrative
# --------
# 3-item test with values and percentages
#
# Extracted from stzPlotTest.ring, block #56.

load "../../../stzBase.ring"


pr()

oPlot3 = new stzSurfacePlot([
    :Frontend = 60,
    :Backend = 30,
    :DevOps = 10
])
oPlot3.AddValues().AddPercent().Show()
#-->
'
╭──────────────────────┬───────────────╮
│                      │               │
│                      │               │
│                      │   Backend     │
│                      │   30 (30%)    │
│      Frontend        │               │
│      60 (60%)        │               │
│                      │               │
│                      ├───────────────┤
│                      │   10 (10%)    │
│                      │               │
╰──────────────────────┴───────────────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.09 second(s) in Ring 1.22
