# Narrative
# --------
# Test 2: Named data points with labels
#
# Extracted from stzPlotTest.ring, block #66.

load "../../../stzBase.ring"


pr()

oPlot = new stzScatterPlot([ 
	:Ali = [10, 25], 
	:Ben = [15, 30], 
	:Tom = [20, 22], 
	:Maiga = [25, 35] 
])
oPlot.AddGrid()
oPlot.AddLabels()

oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 35 ┼----------------------------● Maiga  
    │                            ⁞        
    │                            ⁞        
    │                            ⁞        
 30 ┼---------● Ben              ⁞        
    │         ⁞                  ⁞        
    │         ⁞                  ⁞        
 25 ┼● Ali    ⁞                  ⁞        
 22 ┼⁞--------⁞--------● Tom     ⁞        
    ╰┼────────┼────────┼─────────┼──► Y       
    10       15       20        25       
'

#TODO #ERR See why two Xs and two Ys are displayed

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
