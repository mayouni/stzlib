# Narrative
# --------
# Test 7: Performance data visualization
#
# Extracted from stzPlotTest.ring, block #71.

load "../../../stzBase.ring"


pr()

oPlot = new stzScatterPlot([
	:Week1 = [100, 85],
	:Week2 = [120, 90], 
	:Week3 = [110, 88],
	:Week4 = [140, 95]
])
oPlot.AddLabels()

oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 95 ┤                            ● Week4  
    │                                     
    │                                     
    │                                     
 90 ┤              ● Week2                
    │                                     
 88 ┤       ● Week3                       
    │                                     
 85 ┤● Week1                              
    ╰┬──────┬──────┬─────────────┬──► Y       
    100    110    120           140         
'

#TODO #ERR See why two Xs and two Ys are displayed

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.22
