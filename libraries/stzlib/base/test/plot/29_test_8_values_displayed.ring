# Narrative
# --------
# Test 8: Values displayed
#
# Extracted from stzPlotTest.ring, block #29.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetValues(TRUE)
oPlot.Show()
Shows(oPlot, '
  ▲                     
A │ ▇▇▇▇▇▇▇▇▇▇▇▇ 5      
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 8
C │ ▇▇▇▇▇▇▇ 3           
  ╰────────────────────►
')
# Expected: Plot with numerical values (5, 8, 3) next to each bar

pf()
# Executed in 0.01 second(s) in Ring 1.22
