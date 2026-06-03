# Narrative
# --------
# Simple histogram without axes
#
# Extracted from stzPlotTest.ring, block #52.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

aAges = [
	25, 34, 45, 28, 37, 42, 31,
	39, 33, 46, 29, 38, 41, 35,
	27, 44, 36, 32, 40, 43
]

oPlot = new stzHistogram(aAges)
oPlot {

    SetBinCount(4)
	UseFrequency()
	IncludeValues()

    WithoutVAxis()
    WithoutHAxis()
    SetBarChar("■")
    SetBarWidth(4)

    Show()
}
#-->
'
                    6   
        5     5    ■■■■ 
  4    ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
                        
  25    30    36    41  
  30    36    41    46   
'

#TODO #ERR See why lables are not displayed

pf()
# Executed in 0.25 second(s) in Ring 1.23
# Executed in 0.54 second(s) in Ring 1.22
