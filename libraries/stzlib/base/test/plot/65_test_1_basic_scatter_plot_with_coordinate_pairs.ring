# Narrative
# --------
# Test 1: Basic scatter plot with coordinate pairs
#
# Extracted from stzPlotTest.ring, block #65.

load "../../stzBase.ring"


pr()

oPlot = new stzScatterPlot([
	[1,2], [3,5], [6,9], [5,4], [7,8], [9,6]
])

oPlot.Show()
#-->
'
   X
   ▲
   │                                      
 9 ┤                     ●                
   │                                      
 8 ┤                          ●           
   │                                      
 6 ┤                                   ●  
 5 ┤        ●                             
 4 ┤                 ●                    
   │                                      
 2 ┤●                                     
   ╰┬───────┬────────┬───┬────┬────────┬──► Y 
    1       3        5   6    7        9  
'

#TODO #ERR See why two Xs and two Ys are displayed

pf()
# Executed in 0.03 second(s) in Ring 1.22
