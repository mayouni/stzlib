# Narrative
# --------
# 8-item complex test
#
# Extracted from stzPlotTest.ring, block #64.

load "../../../stzBase.ring"


pr()

oPlot12 = new stzSurfacePlot([
    :Chrome = 65,
    :Safari = 19,
    :Edge = 8,
    :Firefox = 4,
    :Opera = 2,
    :Samsung = 1,
    :UCBrowser = 0.5,
    :Others = 0.5
])
oPlot12.AddPercent().SetSize(80, 20).Show()
#-->
'
╭────────────────────────────────────────────────────────────────┬─────────┬─┬─╮
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │ Edge    │ │ │
│                            Chrome                              │  8%     │ │ │
│                              65%                               │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                ├─────────┤ │ │
├────────────────────────────────────────────────────────────────┤         ├─┼─┤
│                            Safari                              │Firefox  │ │ │
│                              19%                               │  4%     │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
╰────────────────────────────────────────────────────────────────┴─────────┴─┴─╯
'
pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.09 second(s) in Ring 1.22


#---------------------------------#
# Test Suite for stzScatterPlot   #
#---------------------------------#
