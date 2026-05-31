# Narrative
# --------
# Y-axis disabled
#
# Extracted from stzPlotTest.ring, block #12.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetYAxis(FALSE)
oPlot.SetLabels(TRUE)
oPlot.Show()
#-->
'
   ██     
   ██     
██ ██     
██ ██     
██ ██ ██  
██ ██ ██  
██ ██ ██  
─────────>
A  B  C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.22
