# Narrative
# --------
# Equal values test
#
# Extracted from stzPlotTest.ring, block #59.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"


pr()

oPlot6 = new stzSurfacePlot([
    :Q1 = 25,
    :Q2 = 25,
    :Q3 = 25,
    :Q4 = 25
])
oPlot6 {
	AddPercent()
	Show()
}
#-->
'
╭───────────────────┬──────────────────╮
│                   │                  │
│        Q1         │       Q3         │
│       25%         │       25%        │
│                   │                  │
│                   │                  │
├───────────────────┼──────────────────┤
│        Q2         │       Q4         │
│       25%         │       25%        │
│                   │                  │
│                   │                  │
╰───────────────────┴──────────────────╯
'

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.06 second(s) in Ring 1.22
