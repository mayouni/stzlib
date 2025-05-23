load "../max/stzmax.ring"

/*---

pr()

oChart = new stzBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarWidth(3)
oChart.AddValues()
oChart.Show()
#-->
# ^      8       
# │     ███      
# │     ███      
# │     ███      
# │  5  ███      
# │ ███ ███  3   
# │ ███ ███ ███  
# ╰────────────>

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

oChart = new stzBarChart([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20])
oChart {
	AddYLabels()
	AddAverage()
	SetBarWidth(1)
	Show()
}

pf()
#-->
# ^               
# │         █     
# │         █     
# │   █     █     
# │---█-----█--█- 
# │   █     █  █  
# │█  █  █  █  █  
# ╰──────────────>
#  Q1 Q2 Q3 Q4 Q5

/*---

pr()

oChart = new stzBarChart([
	:1 = 42,
	:2 = 18,
	:3 = 73,
	:4 = 29,
	:5 = 35,
	:6 = 70,
	:7 = 14,
	:8 = 34
])

oChart {
	SetHight(8)
	SetBarWidth(1)

	Show()
}
#-->
# ^                  
# │     █            
# │     █     █      
# │     █     █      
# │ █ █ █ █ █ █ █ █  
# ╰─────────────────>

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---
*/
pr()

oChart = new stzBarChart([
	:Mali 	= 42,
	:Niger 	= 18,
	:Egypt 	= 73,
	:Bosnia = 29,
	:Brazil = 35,
	:France = 70,
	:Qatar 	= 14,
	:SouthKorea = 34
])

oChart { SetBarWidth(2) AddYLabels() AddValues() Show() }
#-->
# ^            73                                         
# │            ██                   70                    
# │            ██                   ██                    
# │            ██                   ██                    
# │ 42         ██            35     ██             34     
# │ ██   18    ██     29     ██     ██    14       ██     
# │ ██   ██    ██     ██     ██     ██    ██       ██     
# ╰──────────────────────────────────────────────────────>
#  Mali Niger Egypt Bosnia Brazil France Qatar Southkorea

pf()
# Executed in almost 0 second(s) in Ring 1.22


/*=== TODO


pr()

oChart = new stzBarChartXT([ [ :Mali = 42, :Niger = 18 ], [ :Mali = 35, :Niger = 25 ] ])
oChart {
    SetBarWidth(2)
    AddYLabels()
    Show()
}
#-->
# ^              
# │ ████         
# │ ████         
# │ ████ ▒▒▒▒    
# │ ████ ▒▒▒▒    
# │ ████ ▒▒▒▒    
# │ ████ ▒▒▒▒    
# ╰─────────────>
#  Mali  Niger  

pf()


