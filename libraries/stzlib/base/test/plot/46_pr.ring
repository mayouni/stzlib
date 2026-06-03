# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #46.

load "../../stzBase.ring"

pr()

# Test 9: Two Series Comparison

oPlot = new stzMultiBarPlot([
	:Before = [ :Feature1 = 45, :Feature2 = 38, :Feature3 = 52, :Feature4 = 29 ],
	:After = [ :Feature1 = 62, :Feature2 = 48, :Feature3 = 59, :Feature4 = 41 ]
])

oPlot {
	SetSeriesChars(["▒", "█"])
	SetBarWidth(2)
	SetSeriesSpace(1)
	AddLabels()
	Show()
}
#-->
'
↑                                         
│     ██                  ██              
│  ▒▒ ██        ██     ▒▒ ██              
│  ▒▒ ██     ▒▒ ██     ▒▒ ██        ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
╰────────────────────────────────────────>
  Feature1  Feature2  Feature3  Feature4  
                                          
▒▒ Before   ██ After         
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22
