# Narrative
# --------
# Test 10: Custom maximum label width
#
# Extracted from stzPlotTest.ring, block #30.

load "../../stzBase.ring"


pr()

oPlot = new stzHBarPlot([ :LongLabel = 10, :AnotherLongLabel = 20 ])
oPlot.SetMaxLabelWidth(5)
oPlot.Show()
# Expected: Labels truncated to 5 characters (e.g., "LongL..", "Anothe..")
#-->
'
      ^
Lon.. │ ▇▇▇▇▇▇▇▇▇▇
Ano.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰───────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
