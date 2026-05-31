# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #45.

load "../../../stzBase.ring"


# Test 8: Large Dataset with Custom Characters

oPlot = new stzMultiBarPlot([
	:Region1 = [ :Mon = 23, :Tue = 31, :Wed = 28, :Thu = 35, :Fri = 42 ],
	:Region2 = [ :Mon = 18, :Tue = 25, :Wed = 33, :Thu = 29, :Fri = 38 ],
	:Region3 = [ :Mon = 31, :Tue = 27, :Wed = 24, :Thu = 41, :Fri = 36 ],
	:Region4 = [ :Mon = 26, :Tue = 39, :Wed = 31, :Thu = 33, :Fri = 28 ]
])

oPlot {
	SetSeriesChars(["█", "▓", "▒", "░"])
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(2)
	Show()
}
#--> #TODO HAxis very long!
'
↑                                                  
│          ░          ▒   █▓                       
│   ▒   █  ░   ▓ ░  █ ▒░  █▓▒                      
│   ▒░  █▓▒░  █▓ ░  █▓▒░  █▓▒░                     
│ █ ▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
╰─────────────────────────────────────────────────>
  Mon   Tue   Wed   Thu   Fri                      
                                                   
██ Region1   ▓▓ Region2   ▒▒ Region3   ░░ Region4  
'

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.06 second(s) in Ring 1.22
