# Narrative
# --------
# Test 13: Zero values
#
# Extracted from stzPlotTest.ring, block #33.

load "../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oPlot.Show()
#-->
'
            ^                   
       Zero │                   
   Positive │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Anotherzero │                   
            ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
