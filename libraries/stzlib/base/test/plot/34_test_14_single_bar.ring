# Narrative
# --------
# Test 14: Single bar
#
# Extracted from stzPlotTest.ring, block #34.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :Single = 10 ])
oPlot.Show()
Shows(oPlot, '
       ▲                   
Single │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       ╰──────────────────►
')

pf()
# Executed in 0.01 second(s) in Ring 1.22
