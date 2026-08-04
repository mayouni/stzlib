# Narrative
# --------
# Test 5: Y-axis disabled
#
# Extracted from stzPlotTest.ring, block #26.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetVAxis(FALSE)
oPlot.Show()
Shows(oPlot, '
A ▇▇▇▇▇▇▇▇▇▇▇▇      
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇           
───────────────────►
')
# Expected: Plot without the Y-axis (vertical line)

pf()
# Executed in 0.01 second(s) in Ring 1.22
