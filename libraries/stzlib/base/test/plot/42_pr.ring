# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #42.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

# Test 5: With Percentage Display

oPlot = new stzMultiBarPlot([
	:Desktop = [ :2021 = 65, :2022 = 58, :2023 = 52 ],
	:Mobile = [ :2021 = 35, :2022 = 42, :2023 = 48 ]
])

oPlot {
	SetPercent(True)
	SetBarWidth(1)
	Show()
Shows(oPlot, '
▲                       
│ █     █               
│ █     █     █ ▒       
│ █     █ ▒   █ ▒       
│ █ ▒   █ ▒   █ ▒       
│ █ ▒   █ ▒   █ ▒       
│ █ ▒   █ ▒   █ ▒       
│ █ ▒   █ ▒   █ ▒       
╰──────────────────────►
  2021  2022  2023      
                        
██ Desktop   ▒▒ Mobile  
')
}

pf()
# Executed in 0.24 second(s) in Ring 1.22
