# Narrative
# --------
# Test 6: Clean plot without axes
#
# Extracted from stzPlotTest.ring, block #68.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzScatterPlot([
	[1,1], [2, 5], [2,4], [3,2], [3, 4], [4,5], [4,6], [5,3]
])
oPlot.WithoutVHAxis()
oPlot.Show()
Shows(oPlot, '
                             ●            
                                          
         ●                   ●            
                                          
         ●         ●                      
                                          
                                       ●  
                                          
                   ●                      
                                          
●                                         
')

pf()
# Executed in 0.01 second(s) in Ring 1.22
