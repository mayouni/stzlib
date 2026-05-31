# Narrative
# --------
# Large dataset (6 items)
#
# Extracted from stzPlotTest.ring, block #58.

load "../../../stzBase.ring"


pr()

oPlot5 = new stzSurfacePlot([
    :North = 35,
    :South = 30,
    :East = 28,
    :West = 18,
    :Center = 30,
    :Remote = 10
])
oPlot5.AddPercent().Show()
#-->
'
╭────────┬──────────────┬──────┬───────╮
│        │              │      │       │
│        │   South      │      │ West  │
│        │   19.9%      │      │11.9%  │
│        │              │      │       │
│ North  │              │East  │       │
│ 23.2%  ├──────────────┤8.5%  │       │
│        │   Center     │      ├───────┤
│        │   19.9%      │      │Remote │
│        │              │      │ 6.6%  │
│        │              │      │       │
╰────────┴──────────────┴──────┴───────╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.23
# Executed in 0.14 second(s) in Ring 1.22
