# Narrative
# --------
# Test 1: Basic horizontal bar chart, with percent values,
#
# Extracted from stzPlotTest.ring, block #22.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :Warda = 5, :Yessmina = 8, :Folla = 3 ])

oPlot.AddPercent()
oPlot.Show()
Shows(oPlot, '
         ▲                         
   Warda │ ▇▇▇▇▇▇▇▇▇▇▇▇ 31.3%      
Yessmina │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 50.0%
   Folla │ ▇▇▇▇▇▇▇ 18.8%           
         ╰────────────────────────►
')
#NOTE: By default, the width is set on 18
? oPlot.Width()
#--> 18

oPlot.SetWidth(10)
oPlot.Show()
Shows(oPlot, '
         ▲                 
   Warda │ ▇▇▇▇▇▇▇ 31.3%   
Yessmina │ ▇▇▇▇▇▇▇▇▇▇ 50.0%
   Folla │ ▇▇▇▇ 18.8%      
         ╰────────────────►
')

oPlot.SetWidth(5)
oPlot.Show()
Shows(oPlot, '
         ▲                 
   Warda │ ▇▇▇▇▇▇▇ 31.3%   
Yessmina │ ▇▇▇▇▇▇▇▇▇▇ 50.0%
   Folla │ ▇▇▇▇ 18.8%      
         ╰────────────────►
')

pf()
# Executed in 0.14 second(s) in Ring 1.23
# Executed in 0.28 second(s) in Ring 1.22
