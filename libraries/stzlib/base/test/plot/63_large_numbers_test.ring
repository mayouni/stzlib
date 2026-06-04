# Narrative
# --------
# Large numbers test
#
# Extracted from stzPlotTest.ring, block #63.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"


pr()

oPlot11 = new stzSurfacePlot([
    :Revenue = 2500000,
    :Costs = 1800000,
    :Profit = 700000
])
oPlot11.AddValues().AddPercent().Show()
#-->
'
╭───────────────────┬──────────────────╮
│                   │                  │
│                   │                  │
│                   │      Costs       │
│                   │  1800000 (36%)   │
│     Revenue       │                  │
│  2500000 (50%)    │                  │
│                   │                  │
│                   ├──────────────────┤
│                   │  700000 (14%)    │
│                   │                  │
╰───────────────────┴──────────────────╯
'

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.09 second(s) in Ring 1.22
