# Narrative
# --------
# Test 6: Both axes disabled
#
# Extracted from stzPlotTest.ring, block #27.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetHVAxis(FALSE, FALSE)
oPlot.SetAxisLabels(TRUE)

oPlot.Show()
Shows(oPlot, '
A ▇▇▇▇▇▇▇▇▇▇▇▇      
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇           
')
# Expected: Plot with no axes

pf()
# Executed in 0.01 second(s) in Ring 1.22
