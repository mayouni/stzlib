# Narrative
# --------
# Custom width and Hight
#
# Extracted from stzPlotTest.ring, block #9.

load "../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetSize(50, 15)
oPlot.Show()
#-->
'
↑           
│    ██     
│    ██     
│    ██     
│    ██     
│    ██     
│ ██ ██     
│ ██ ██     
│ ██ ██     
│ ██ ██     
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
╰──────────>
  A  B  C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
