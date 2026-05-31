# Narrative
# --------
# Zero values
#
# Extracted from stzPlotTest.ring, block #19.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oPlot.Show()
#-->
'
↑                            
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
╰──────────────────────────>
  Zero Positive Anotherzero  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
