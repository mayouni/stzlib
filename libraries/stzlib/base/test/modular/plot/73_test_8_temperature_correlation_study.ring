# Narrative
# --------
# Test 8: Temperature correlation study
#
# Extracted from stzPlotTest.ring, block #73.

load "../../../stzBase.ring"

pr()

aData = [
	[ :Jan, [5, 32] ],
	[ :Feb, [8, 35] ],
	[ :Mar, [12, 50] ], 
	[ :Apr, [18, 64] ],
	[ :May, [22, 72] ],
	[ :Jun, [28, 82] ]
]

oPlot = new stzScatterPlot(aData)
oPlot.AddLabels()
oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 82 ┤                              ● Jun  
    │                                     
 72 ┤                      ● May          
 64 ┤                ● Apr                
    │                                     
    │                                     
 50 ┤         ● Mar                       
    │                                     
 35 ┤● Ja Feb                             
    ╰┬──┬─────┬──────┬─────┬───────┬──► Y     
     5  8    12     18    22      28                                         
'

#TODO #ERR See why two Xs and two Ys are displayed
#TODO #ERR See why vertrical axis is not alligned

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22
