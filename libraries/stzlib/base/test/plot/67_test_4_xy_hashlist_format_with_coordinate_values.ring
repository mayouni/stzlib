# Narrative
# --------
# Test 4: X,Y hashlist format with coordinate values
#
# Extracted from stzPlotTest.ring, block #67.

load "../../stzBase.ring"


pr()

oPlot = new stzScatterPlot([[:X, [1,3,5,7]], [:Y, [2,6,4,8]]])

oPlot.AddLabels()
oPlot.Show()
#-->
'
   X
   ▲
   │                                      
 8 ┤                                ● P4  
   │                                      
   │                                      
 6 ┤          ● P2                        
   │                                      
   │                                      
 4 ┤                     ● P3             
   │                                      
 2 ┤● P1                                  
   ╰┬─────────┬──────────┬──────────┬──► Y    
    1         3          5          7     
'

#TODO #ERR See why two Xs and two Ys are displayed

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.22
