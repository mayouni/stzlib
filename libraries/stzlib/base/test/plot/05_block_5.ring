# Narrative
# --------
# *
#
# Extracted from stzPlotTest.ring, block #5.

load "../../stzBase.ring"

pr()

oPlot = new stzBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.AddValues()
oPlot.Show()
#-->
'
↑           
│    8      
│    ██     
│    ██     
│ 5  ██     
│ ██ ██     
│ ██ ██ 3   
│ ██ ██ ██  
│ ██ ██ ██  
│ ██ ██ ██  
╰──────────>
  A  B  C   
'

pf()
# Executed in almost 0.01 second(s) in Ring 1.22
