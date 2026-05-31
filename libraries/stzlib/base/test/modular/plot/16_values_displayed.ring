# Narrative
# --------
# Values displayed
#
# Extracted from stzPlotTest.ring, block #16.

load "../../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([
	:Green = 7520,
	:BlackAndWhite = 8898,
	:Blue = 32393
])

oPlot {

	SetPercent(TRUE)
	Show()

	? ""
	SetValues(TRUE)
	Show()

}

pf()
# Executed in 0.13 second(s) in Ring 1.22

#-->
'
↑                           
│                    66.4%  
│                     ██    
│                     ██    
│                     ██    
│                     ██    
│ 15.4%    18.2%      ██    
│  ██        ██       ██    
│  ██        ██       ██    
╰──────────────────────────>
  Green Blackandwh.. Blue   

↑                           
│                    32393  
│                     ██    
│                     ██    
│                     ██    
│                     ██    
│ 7520      8898      ██    
│  ██        ██       ██    
│  ██        ██       ██    
╰──────────────────────────>
  Green Blackandwh.. Blue   
'

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.17 second(s) in Ring 1.22
