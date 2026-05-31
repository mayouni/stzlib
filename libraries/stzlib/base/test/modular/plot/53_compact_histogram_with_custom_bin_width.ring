# Narrative
# --------
# Compact histogram with custom bin width
#
# Extracted from stzPlotTest.ring, block #53.

load "../../../stzBase.ring"


pr()

aWeights = [
	150, 155, 160, 152, 158, 162, 165,
	159, 157, 161, 163, 156, 154, 164,
	166, 153, 151, 167, 168, 149
]

oPlot = new stzHistogram(aWeights)
oPlot {

	UseSum()
	AddValues()

    SetBarWidth(3)
    SetBarInterSpace(1)
	SetLabelInterSpace(0)

    Show()
}
#-->
'
^
│  602                           666  
│  ███                           ███  
│  ███   462   471   480   489   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
╰─────────────────────────────────────>
   149   152   155   158   162   165  
   152   155   158   162   165   168  
'

#TODO #ERR See why lables are not displayed

pf()
# Executed in 0.29 second(s) in Ring 1.23

#===============================#
#  TEST OF Surface CHART CLASS  #
#===============================#
