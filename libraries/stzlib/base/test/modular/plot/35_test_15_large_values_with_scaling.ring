# Narrative
# --------
# Test 15: Large values with scaling
#
# Extracted from stzPlotTest.ring, block #35.

load "../../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :Small = 1, :Large = 1000 ])
oPlot.Show()
#-->
'
      ^                   
Small │ ▇                 
Large │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

#--------------------------------------------#
#  TEST SUITE FOR THE MULTI-BAR CHART CLASS  #
#--------------------------------------------#
