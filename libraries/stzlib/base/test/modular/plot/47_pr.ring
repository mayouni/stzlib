# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #47.

load "../../../stzBase.ring"


# Test 10: Performance Metrics

oPlot = new stzMultiBarPlot([
	:CPU = [ :Server1 = 23, :Server2 = 32, :Server3 = 78 ],
	:Memory = [ :Server1 = 65, :Server2 = 78, :Server3 = 52],
	:Disk = [ :Server1 = 45, :Server2 = 52, :Server3 = 28 ]
])

oPlot {
	SetSeriesChars(["■", "▲", "●"])
	SetCategoryInterSpace(7)
	SetBarInterSpace(3)
	SetPercent(True)
	Show()
}
#-->
'
↑                                                     
│                       17.2%         17.2%           
│    14.3%                ▲▲            ■■            
│      ▲▲  9.9%           ▲▲ 11.5%      ■■ 11.5%      
│      ▲▲   ●●            ▲▲   ●●       ■■   ▲▲       
│5.1%  ▲▲   ●●      7.1%  ▲▲   ●●       ■■   ▲▲  6.2% 
│ ■■   ▲▲   ●●       ■■   ▲▲   ●●       ■■   ▲▲   ●●  
│ ■■   ▲▲   ●●       ■■   ▲▲   ●●       ■■   ▲▲   ●●  
│ ■■   ▲▲   ●●       ■■   ▲▲   ●●       ■■   ▲▲   ●●  
╰────────────────────────────────────────────────────>
    Server1            Server2            Server3       
'

pf()
# Executed in 0.21 second(s) in Ring 1.23
# Executed in 0.38 second(s) in Ring 1.22
