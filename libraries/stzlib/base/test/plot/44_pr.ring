# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #44.

load "../../stzBase.ring"

pr()

# Test 7: Compact Multi-Series

oPlot = new stzMultiBarPlot([
	:A = [ :X = 8, :Y = 12, :Z = 6 ],
	:B = [ :X = 15, :Y = 9, :Z = 18 ],
	:C = [ :X = 11, :Y = 16, :Z = 13 ]
])

oPlot {
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(1)
	SetHeight(3)
	SetMaxWidth(50)
	Show()
}
#-->
'
↑                   
│  ▒    ▓  ▒▓       
│ █▒▓ █▒▓  ▒▓       
│ █▒▓ █▒▓ █▒▓       
╰──────────────────>
   X   Y   Z        
                    
██ A   ▒▒ B   ▓▓ C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
