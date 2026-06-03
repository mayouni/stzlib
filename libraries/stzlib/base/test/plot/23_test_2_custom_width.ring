# Narrative
# --------
# Test 2: Custom width
#
# Extracted from stzPlotTest.ring, block #23.

load "../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3, :D = 2, :E = 4 ])
oPlot.Setwidth(40)
oPlot.Show()
#-->
'
  ^                                         
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇               
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                         
D │ ▇▇▇▇▇▇▇▇▇▇                              
E │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                    
  ╰────────────────────────────────────────>
'

# Note: Hight can not changed with SetHight() in horizontal bars
# but we can define a maximum number of horizontal bars with SetMawHight()

? ""

? oPlot.MaxHeight()
#--> 30

oPlot.SetMaxHeight(3)
oPlot.Show()
#-->
'
  ^                                         
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇               
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                         
  ╰────────────────────────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
