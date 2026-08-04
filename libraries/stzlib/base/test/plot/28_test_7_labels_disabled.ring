# Narrative
# --------
# Test 7: Labels disabled
#
# Extracted from stzPlotTest.ring, block #28.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetLabels(FALSE)
oPlot.Show()
Shows(oPlot, '
▲                   
│ ▇▇▇▇▇▇▇▇▇▇▇▇      
│ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
│ ▇▇▇▇▇▇▇           
╰──────────────────►
')
# Expected: Plot without labels on the left side

pf()
# Executed in 0.01 second(s) in Ring 1.22
