# Narrative
# --------
# Multiple bars with varying values
#
# Extracted from stzPlotTest.ring, block #18.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oPlot.Show()
#-->
'
↑                 
│          ██     
│    ██    ██     
│    ██    ██ ██  
│    ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
╰────────────────>
  Q1 Q2 Q3 Q4 Q5  
'

oPlot.SetBarWidth(1)
oPlot.SetBarInterSpace(0) #TODO has no effect
oPlot.Show()
#-->
'
↑             
│       █     
│   █   █     
│   █   █ █   
│   █ █ █ █   
│ █ █ █ █ █   
│ █ █ █ █ █   
│ █ █ █ █ █   
╰────────────>
  Q1Q2Q3Q4Q5  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22
