# Narrative
# --------
# Test 11: Long labels
#
# Extracted from stzPlotTest.ring, block #31.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :ThisIsALongLabel = 15, :Short = 5 ])
oPlot.Show()
Shows(oPlot, '
             ▲                   
Thisisalon.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       Short │ ▇▇▇▇▇▇            
             ╰──────────────────►
')

pf()
# Executed in 0.01 second(s) in Ring 1.22
