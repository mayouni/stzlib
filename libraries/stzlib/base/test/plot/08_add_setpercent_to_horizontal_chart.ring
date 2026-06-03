# Narrative
# --------
# #TODO Add SetPercent() to horizontal chart
#
# Extracted from stzPlotTest.ring, block #8.

load "../../stzBase.ring"


pr()

oPlot = new stzVBarPlot([
	:Mali 	= 42,
	:Niger 	= 18,
	:Egypt 	= 73,
	:Bosnia = 29,
	:Brazil = 35,
	:France = 70,
	:Spain 	= 14,
	:SouthKorea = 34
])

oPlot {
	AddLabels()
	AddPercent()
	SetHeight(5)
	Show()
}
#-->
'
↑                                                          
│             23.2%               22.2%                    
│              ██                   ██                     
│ 13.3%        ██          11.1%    ██           10.8%     
│  ██   5.7%   ██    9.2%    ██     ██             ██      
│  ██    ██    ██     ██     ██     ██   4.4%      ██      
│  ██    ██    ██     ██     ██     ██    ██       ██      
╰─────────────────────────────────────────────────────────>
  Mali  Niger Egypt Bosnia Brazil France Spain Southkorea  
'

pf()
# Executed in 0.15 second(s) in Ring 1.23
# Executed in 0.32 second(s) in Ring 1.22
