# Narrative
# --------
#
# Extracted from stzPlotTest.ring, block #6.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

oPlot = new stzVBarPlot([
	:Q1 = 9, :Q2 = 25, :Q3 = 15, :Q4 = 32, :Q5 = 20
])

oPlot {
//	AddValues()
//	AddAverage()
//	AddLegend()

//	SetBarWidth(1)
//	SetTopChar("▲")
	Show()
Shows(oPlot, '
▲                 
│          ██     
│    ██    ██     
│    ██    ██ ██  
│    ██ ██ ██ ██  
│    ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
╰────────────────►
  Q1 Q2 Q3 Q4 Q5  
')

}

pf()
# Executed in 0.10 second(s) in Ring 1.22
