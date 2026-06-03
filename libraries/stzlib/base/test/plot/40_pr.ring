# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #40.

load "../../stzBase.ring"

pr()

# Test 3: Custom Series Characters

oPlot = new stzMultiBarPlot([
	:Team_A = [ :Jan = 45, :Feb = 52, :Mar = 38 ],
	:Team_B = [ :Jan = 38, :Feb = 41, :Mar = 49 ],
	:Team_C = [ :Jan = 29, :Feb = 35, :Mar = 42 ]
])

oPlot {
	SetSeriesChars(["|", "X", "~"])
	SetBarWidth(2)
	SetCategorySpace(3)
	Show()
}
#-->
'
↑                                  
│ ||         ||            XX      
│ || XX      || XX      || XX ~~   
│ || XX      || XX ~~   || XX ~~   
│ || XX ~~   || XX ~~   || XX ~~   
│ || XX ~~   || XX ~~   || XX ~~   
│ || XX ~~   || XX ~~   || XX ~~   
│ || XX ~~   || XX ~~   || XX ~~   
╰─────────────────────────────────>
    Jan        Feb        Mar      
                                   
|| Team_a   XX Team_b   ~~ Team_c  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22
