# Narrative
# --------
# Average line enabled
#
# Extracted from stzPlotTest.ring, block #14.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetAverage(TRUE)
oPlot.Show()
Shows(oPlot, '
▲                
│    ██          
│    ██          
│ ██-██--- 5.3   
│ ██ ██          
│ ██ ██ ██       
│ ██ ██ ██       
│ ██ ██ ██       
╰───────────────►
  A  B  C        
')

? ""

oPlot.AddValues()
oPlot.Show()
Shows(oPlot, '
▲                
│    8           
│    ██          
│ 5  ██          
│ ██-██--- 5.3   
│ ██ ██ 3        
│ ██ ██ ██       
│ ██ ██ ██       
│ ██ ██ ██       
╰───────────────►
  A  B  C        
')

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.15 second(s) in Ring 1.22
