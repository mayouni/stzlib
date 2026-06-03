# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #41.

load "../../stzBase.ring"


# Test 4: With Values Display

oPlot = new stzMultiBarPlot([
	:Product1 = [ :Store1 = 12, :Store2 = 18, :Store3 = 15 ],
	:Product2 = [ :Store1 = 20, :Store2 = 14, :Store3 = 22 ]
])

oPlot {
	SetValues(True)
	SetBarWidth(2)
	Show()
}
#-->
'
↑                          
│    20              22    
│    ▒▒   18         ▒▒    
│    ▒▒   ██ 14   15 ▒▒    
│ 12 ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
╰─────────────────────────>
  Store1  Store2  Store3   
                           
██ Product1   ▒▒ Product2  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22
