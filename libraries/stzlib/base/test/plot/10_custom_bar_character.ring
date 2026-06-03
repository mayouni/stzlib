# Narrative
# --------
# Custom bar character
#
# Extracted from stzPlotTest.ring, block #10.

load "../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetBarChar("X")
oPlot.Show()
#-->
'
^
│    XX    
│    XX    
│    XX    
│ XX XX    
│ XX XX    
│ XX XX XX 
│ XX XX XX 
│ XX XX XX 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
