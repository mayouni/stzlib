# Narrative
# --------
# Test 3: Custom bar character
#
# Extracted from stzPlotTest.ring, block #24.

load "../../stzBase.ring"
load "../_expect.ring"


pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetBarChar("=")
oPlot.Show()
Shows(oPlot, '
  ▲                   
A │ ============      
B │ ==================
C │ =======           
  ╰──────────────────►
')
# Expected: Bars made of '=' instead of default '▇'

pf()
# Executed in 0.01 second(s) in Ring 1.22
