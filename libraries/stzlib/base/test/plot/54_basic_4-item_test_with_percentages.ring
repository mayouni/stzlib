# Narrative
# --------
# Basic 4-item test with percentages
#
# Extracted from stzPlotTest.ring, block #54.

load "../../stzBase.ring"


pr()

oPlot = new stzSurfacePlot([
    :Sales = 45,
    :Marketing = 25, 
    :Dev = 20,
    :Support = 10
])

oPlot.AddPercent().AddLegend().AddValues().Show()
'
╭──────────────────────────┬───────────╮
│                          │           │
│          Sales           │   Dev     │
│        45 (45%)          │ 20 (20%)  │
│                          │           │
│                          │           │
│                          │           │
├──────────────────────────┼───────────┤
│        Marketing         │ Support   │
│        25 (25%)          │ 10 (10%)  │
│                          │           │
╰──────────────────────────┴───────────╯
'

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.10 second(s) in Ring 1.22
