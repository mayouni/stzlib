# Narrative
# --------
# Single bar
#
# Extracted from stzPlotTest.ring, block #20.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :Single = 10 ])
oPlot.Show()
#-->
'
^
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
╰────────>
  Single 
'

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
