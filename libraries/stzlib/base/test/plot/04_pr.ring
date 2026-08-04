# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #4.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

oPlot = StzChartQ(:VBar, [ 5, 4, 2, 5, 3, 2, 4 ])

oPlot {

	# Default chart
	Show()
Shows(oPlot, '
▲                       
│ ██       ██           
│ ██ ██    ██       ██  
│ ██ ██    ██ ██    ██  
│ ██ ██    ██ ██    ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
╰──────────────────────►
  X1 X2 X3 X4 X5 X6 X7  
')

	# Personalized chart

	SetTopChar("●") #TODO #ERR //Check why it's not displayed
	SetBarChar("┃")
	SetBarWidth(1)
	
	Show()
Shows(oPlot, '
▲                       
│ ┃        ┃            
│ ┃  ┃     ┃        ┃   
│ ┃  ┃     ┃  ┃     ┃   
│ ┃  ┃     ┃  ┃     ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
╰──────────────────────►
  X1 X2 X3 X4 X5 X6 X7  
')

	# Further personalization
	SetBarWidth(2)
	SetBarInterSpace(0)
	WithoutAxisLabels()
	Show()
Shows(oPlot, '
▲                 
│ ┃┃    ┃┃        
│ ┃┃┃┃  ┃┃    ┃┃  
│ ┃┃┃┃  ┃┃┃┃  ┃┃  
│ ┃┃┃┃  ┃┃┃┃  ┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
╰────────────────►
')

}

pf()
# Executed in 0.03 second(s) in Ring 1.22
