# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #7.

load "../../../stzBase.ring"


oPlot = new stzVBarPlot([ 42, 18, 73, 29, 35, 70, 14, 34 ])

oPlot {

	SetHeight(2)
	SetBarWidth(1)
	SetLabelChar(FALSE)
	Show()
	? ""

	WithoutAxies() #TODO #ERR // See why lables are displayed
	Show()

	# Try with
//	WithoutYAxis()
//	WithoutXAxis()
//	WithoutAxisLabels()
}
#-->
'
↑                  
│ █   █     █      
│ █ █ █ █ █ █ █ █  
╰─────────────────>
  1 2 3 4 5 6 7 8  

█   █     █      
█ █ █ █ █ █ █ █  
'

pf()
# Executed in 0.03 second(s) in Ring 1.22
