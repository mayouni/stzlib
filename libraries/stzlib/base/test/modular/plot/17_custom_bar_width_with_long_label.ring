# Narrative
# --------
# Custom bar width with long label
#
# Extracted from stzPlotTest.ring, block #17.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :A = 5, :BColumnLableIsSoLong = 8, :C = 3 ])
oPlot.SetBarWidth(5)
oPlot.Show()
#-->
'
^
│          █████           
│          █████           
│          █████           
│ █████    █████           
│ █████    █████           
│ █████    █████     █████ 
│ █████    █████     █████ 
│ █████    █████     █████ 
╰──────────────────────────>
    A   Bcolumnlab..   C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22
