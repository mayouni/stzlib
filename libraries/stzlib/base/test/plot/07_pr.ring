# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #7.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

oPlot = new stzVBarPlot([ 42, 18, 73, 29, 35, 70, 14, 34 ])

oPlot {

	SetHeight(2)
	SetBarWidth(1)
	SetLabelChar(FALSE)
	Show()
Shows(oPlot, '
▲                  
│ █   █     █      
│ █ █ █ █ █ █ █ █  
╰─────────────────►
  1 2 3 4 5 6 7 8  
')
	? ""

	WithoutAxies() #TODO #ERR // See why lables are displayed
	Show()
Shows(oPlot, '
█   █     █      
█ █ █ █ █ █ █ █  
1 2 3 4 5 6 7 8  
')

	# Try with
//	WithoutYAxis()
//	WithoutXAxis()
//	WithoutAxisLabels()
}

pf()
# Executed in 0.03 second(s) in Ring 1.22
