# Narrative
# --------
# Values displayed
#
# Extracted from stzPlotTest.ring, block #15.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 7520, :B = 8898, :C = 32393 ])
oPlot.SetValues(TRUE)
oPlot.Show()
#-->
'
↑                  
│           32393  
│            ██    
│            ██    
│            ██    
│            ██    
│ 7520 8898  ██    
│  ██   ██   ██    
│  ██   ██   ██    
╰─────────────────>
   A    B     C    
'

pf()
# Executed in 0.04 second(s) in Ring 1.22
