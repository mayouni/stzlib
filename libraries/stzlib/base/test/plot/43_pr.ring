# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #43.

load "../../stzBase.ring"

pr()

# Test 6: Hide/Show Axes and Labels

oPlot = new stzMultiBarPlot([
	:North = [ :Spring = 30, :Summer = 40, :Fall = 25, :Winter = 20 ],
	:South = [ :Spring = 35, :Summer = 50, :Fall = 36, :Winter = 25 ]
])

# With full display

oPlot {
	SetHAxis(True)
	SetVAxis(True)  
	SetLabels(True)
	SetLegend(True)
	Show()
}
#-->
'
↑                                
│            ▒▒                  
│         ██ ▒▒      ▒▒          
│ ██ ▒▒   ██ ▒▒      ▒▒          
│ ██ ▒▒   ██ ▒▒   ██ ▒▒     ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
╰───────────────────────────────>
  Spring  Summer  Fall   Winter  
                                 
██ North   ▒▒ South   
'

? ""

# Same chart with minimal display

oPlot {
	SetHAxis(False)
	SetVAxis(False)
	SetLabels(False)
	SetLegend(False)
	Show()
}
#-->
'
          ▒▒                
       ██ ▒▒     ▒▒         
██ ▒▒  ██ ▒▒     ▒▒         
██ ▒▒  ██ ▒▒  ██ ▒▒     ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
