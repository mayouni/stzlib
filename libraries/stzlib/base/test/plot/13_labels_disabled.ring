# Narrative
# --------
# Labels disabled
#
# Extracted from stzPlotTest.ring, block #13.

load "../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetLabels(FALSE)
oPlot.Show()
#-->
'
↑           
│    ██     
│    ██     
│ ██ ██     
│ ██ ██     
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
╰──────────>
'

pf()
# Etxecued in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
