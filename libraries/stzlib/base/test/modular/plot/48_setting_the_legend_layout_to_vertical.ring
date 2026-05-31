# Narrative
# --------
# # Setting the legend layout to :Vertical
#
# Extracted from stzPlotTest.ring, block #48.

load "../../../stzBase.ring"

pr()

oPlot = new stzMultiBarPlot([
	:Desktop = [ :Q1 = 45, :Q2 = 42 ],
	:Mobile =  [ :Q1 = 35, :Q2 = 88 ],
	:Tablet =  [ :Q1 = 15, :Q2 = 18 ]
])

oPlot {
	SetBarsChars([ "█", "|", "X" ])
	SetBarWidth(3)
	SetBarInterSpace(1)
	SetCategorySpace(3)

	AddValues()
	SetLegendLayout(:Vertical)

	Show()
	SetLegend(False)

}
#-->
'
↑                            
│                   88       
│                   |||      
│                   |||      
│ 45            42  |||      
│ ███ 35        ███ |||      
│ ███ ||| 15    ███ ||| 18   
│ ███ ||| XXX   ███ ||| XXX  
│ ███ ||| XXX   ███ ||| XXX  
╰───────────────────────────>
      Q1            Q2       
                             
██ Desktop                   
|| Mobile                    
XX Tablet   
'
pf()
#--> Executed in 0.02 second(s) in Ring 1.23
#--> Executed in 0.05 second(s) in Ring 1.22

#--------------------------------------#
#  TEST SAMPLE OF THE HISTOGRAM CHART  #
#--------------------------------------#
