# Narrative
# --------
# Test 10: Custom maximum label width
#
# Extracted from stzPlotTest.ring, block #30.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :LongLabel = 10, :AnotherLongLabel = 20 ])
oPlot.SetMaxLabelWidth(5)
oPlot.Show()
Shows(oPlot, '
      ▲                   
Lon.. │ ▇▇▇▇▇▇▇▇▇         
Ano.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰──────────────────►
')
# Expected: Labels truncated to 5 characters (e.g., "LongL..", "Anothe..")

pf()
# Executed in 0.01 second(s) in Ring 1.22
