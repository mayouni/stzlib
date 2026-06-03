# Narrative
# --------
# X-axis disabled
#
# Extracted from stzPlotTest.ring, block #11.

load "../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetXAxis(FALSE)
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
  A  B  C   
'

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
