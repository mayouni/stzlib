# Narrative
# --------
# Using the short form StzCharQ()
#
# Extracted from stzPlotTest.ring, block #36.

load "../../../stzBase.ring"


pr()

StzPlotQ(:MultiBar, [
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 16 ]
])

.Show()

#-->
'
↑                      
│    ▒▒                
│    ▒▒                
│    ▒▒                
│ ██ ▒▒     ▒▒         
│ ██ ▒▒     ▒▒         
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
╰─────────────────────>
  2020   2022   2024   
                       
██ Mali   ▒▒ Niger     
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
