# Narrative
# --------
# Histogram with frequency display and statistics
#
# Extracted from stzPlotTest.ring, block #50.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"
load "../_expect.ring"


pr()

aTemperatures = [
	72, 74, 76, 73, 75, 78, 79,
	77, 74, 76, 75, 73, 77, 78,
	76, 74, 75, 79, 78, 77
]

oPlot = new stzHistogram(aTemperatures)
oPlot {
    SetBinCount(4)
    UseFrequency()
    AddStats()
	# ~> You can get the stats directly using these functions:
	# Mean() StandartDeviation() Median() Count()

    Show()
Shows(oPlot, '
▲
│
│
│        ██    ██
│        ██    ██    ██
│        ██    ██    ██
│  ██    ██    ██    ██
│  ██    ██    ██    ██
│  ██    ██    ██    ██
╰───────────────────────►
   72   73.8  75.5  77.3
  73.8  75.5  77.3   79

Mean:   75.8
StdDev: 2.07
Median: 76
Count:  20
')
}
#-->
'^                        
│                        
│        ██    ██        
│        ██    ██    ██  
│        ██    ██    ██  
│  ██    ██    ██    ██  
│  ██    ██    ██    ██  
│  ██    ██    ██    ██  
╰────────────────────────>
   72    74    76    77  
   74    76    77    79  

Mean: 75.80
StdDev: 2.07
Median: 76
Count: 20
'

#TODO #ERR See why lables are not displayed

pf()
# Executed in 0.27 second(s) in Ring 1.23
# Executed in 0.56 second(s) in Ring 1.22
