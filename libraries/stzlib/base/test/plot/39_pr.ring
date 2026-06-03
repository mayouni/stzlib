# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #39.

load "../../stzBase.ring"


# Test 2: Customized Bar Width and Spacing

oPlot = new stzMultiBarPlot([
  :Sales  = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs  = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=14 ]
])

oPlot {
	# A clean simple value-enabled chart
	SetBarWidth(1)
	SetBarSpace(2) # Or SetSeriesSpace()
	SetCategorySpace(5)

	AddValues()
	SetLegend(FALSE)
	Show()

	# An elaborated %-enabled chart
	SetBarWidth(3)
//	SetSeriesSpace(2)
//	SetCategorySpace(5)

	AddPercent()
	SetLegend(TRUE)
	Show()
}


#-->
'
↑                                              
│            35                      40        
│             █          30           █        
│25           █           █           █        
│ █           █ 20        █ 18        █ 22     
│ █ 15        █  ▒ 15     █  ▒ 12     █  ▒ 14  
│ █  ▒ 10     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
╰─────────────────────────────────────────────>
    Q1          Q2          Q3          Q4     
                                
↑                                                                      
│                  13.7%                               15.6%           
│                   ███              11.7%              ███            
│9.8%               ███               ███               ███            
│ ███               ███ 7.8%          ███ 7.0%          ███ 8.6%       
│ ███ 5.9%          ███  ▒▒▒ 5.9%     ███  ▒▒▒ 4.7%     ███  ▒▒▒ 5.5%  
│ ███  ▒▒▒ 3.9%     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
│ ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
│ ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
╰─────────────────────────────────────────────────────────────────────>
       Q1                Q2                Q3                Q4        

██ Sales   ▒▒ Costs   ▓▓ Profit 
'
pf()
# Executed in 0.30 second(s) in Ring 1.23
# Executed in 0.51 second(s) in Ring 1.22
