# Narrative
# --------
# Large values with scaling
#
# Extracted from stzPlotTest.ring, block #21.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([ :Small = 1, :Large = 1000 ])
oPlot.Show()
#-->
'
^
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│  ██    ██   
╰─────────────>
  Small Large 
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.22

#------------------------------------------------------#
#  Test Suite for stzHBarPlot (Horizontal Bar Plot)  #
#------------------------------------------------------#
