# Narrative
# --------
# Test 5: Y-axis disabled
#
# Extracted from stzPlotTest.ring, block #26.

load "../../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetVAxis(FALSE)
oPlot.Show()
# Expected: Plot without the Y-axis (vertical line)
#-->
'
A ▇▇▇▇▇▇▇▇▇▇▇▇      
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇           
  ─────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
