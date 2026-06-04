# Narrative
# --------
# Custom size test
#
# Extracted from stzPlotTest.ring, block #60.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"


pr()

oPlot7 = new stzSurfacePlot([
    :Red = 50,
    :Blue = 30,
    :Green = 20
])
oPlot7.SetSize(60, 16).AddPercent().Show()
#-->
'
╭─────────────────────────────┬────────────────────────────╮
│                             │                            │
│                             │                            │
│                             │           Blue             │
│                             │            30%             │
│                             │                            │
│                             │                            │
│            Red              │                            │
│            50%              │                            │
│                             ├────────────────────────────┤
│                             │                            │
│                             │           Green            │
│                             │            20%             │
│                             │                            │
│                             │                            │
╰─────────────────────────────┴────────────────────────────╯
'
pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22
