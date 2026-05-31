# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #37.

load "../../../stzBase.ring"


# Test 1: Basic Multi-Series Plot (same as previous sample but with new stz...)

oPlot = new stzMultiBarPlot([
	:Mali = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger = [ :2020 = 87, :2022 = 40, :2024 = 12 ]
])

oPlot.Show()
'
↑                      
│    ▒▒                
│    ▒▒                
│    ▒▒                
│ ██ ▒▒     ▒▒         
│ ██ ▒▒     ▒▒         
│ ██ ▒▒  ██ ▒▒  ██     
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
╰─────────────────────>
  2020   2022   2024   
                       
██ Mali   ▒▒ Niger     
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
