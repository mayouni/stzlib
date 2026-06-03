# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #38.

load "../../stzBase.ring"


# Test 2: Customized Bar Width and Spacing

oPlot = new stzMultiBarPlot([
  :Sales  = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs  = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=14 ]
])

oPlot {

	# Default display
	SetInterBarSpace(0)
	Show()
	? ""

	# Personalsed display
	SetBarWidth(1)
	SetSeriesSpace(1)
	SetCategorySpace(3)
	SetLegend(FALSE)

	Show()
}
#-->
'
↑                                 
│         ██              ██      
│         ██      ██      ██      
│ ██      ██      ██      ██      
│ ██      ██▒▒    ██▒▒    ██▒▒    
│ ██▒▒    ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
╰────────────────────────────────>
    Q1      Q2      Q3      Q4    

↑                                
│         █               █      
│         █       █       █      
│ █       █       █       █      
│ █       █ ▒     █ ▒     █ ▒    
│ █ ▒     █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
╰───────────────────────────────>
   Q1      Q2      Q3      Q4    
'
pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.22
