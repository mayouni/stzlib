# Narrative
# --------
# Test 12: Multiple bars with varying values
#
# Extracted from stzPlotTest.ring, block #32.

load "../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oPlot.Show()
#-->
'
   ^                   
Q1 │ ▇▇▇▇▇▇            
Q2 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇   
Q3 │ ▇▇▇▇▇▇▇▇▇         
Q4 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Q5 │ ▇▇▇▇▇▇▇▇▇▇▇▇      
   ╰──────────────────>
'

pf()
# Executed in 0.02 second(s) in Ring 1.22
