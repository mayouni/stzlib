# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #4.

load "../../stzBase.ring"

pr()

StzChartQ(:VBar, [ 5, 4, 2, 5, 3, 2, 4 ]) {

	# Default chart
	Show()

	# Personalized chart

	SetTopChar("●") #TODO #ERR //Check why it's not displayed
	SetBarChar("┃")
	SetBarWidth(1)
	
	Show()

	# Further personalization
	SetBarWidth(2)
	SetBarInterSpace(0)
	WithoutAxisLabels()
	Show()

}
#-->
'
↑                       
│ ██       ██           
│ ██ ██    ██       ██  
│ ██ ██    ██ ██    ██  
│ ██ ██    ██ ██    ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  

↑                       
│ ●        ●            
│ ┃  ●     ┃        ●   
│ ┃  ┃     ┃  ●     ┃   
│ ┃  ┃     ┃  ┃     ┃   
│ ┃  ┃  ●  ┃  ┃  ●  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  

↑                 
│ ●●    ●●        
│ ┃┃●●  ┃┃    ●●  
│ ┃┃┃┃  ┃┃●●  ┃┃  
│ ┃┃┃┃  ┃┃┃┃  ┃┃  
│ ┃┃┃┃●●┃┃┃┃●●┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
╰────────────────>
'

pf()
# Executed in 0.03 second(s) in Ring 1.22
