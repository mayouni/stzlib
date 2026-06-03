# Narrative
# --------
# Test 4: X-axis disabled
#
# Extracted from stzPlotTest.ring, block #25.

load "../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetHAxis(FALSE)
oPlot.Show()
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
