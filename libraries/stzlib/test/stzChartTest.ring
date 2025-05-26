load "../max/stzmax.ring"

/*---

pr()

o1 = new stzString('           ^
      Mali │ ▇▇▇▇▇▇▇▇▇▇▇▇░ 42
     Niger │ ▇░ 18
     Egypt │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 73
    Bosnia │ ▇▇▇▇▇▇░ 29
    Brazil │ ▇▇▇▇▇▇▇▇▇ 35
    France │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇░ 70
     Spain │ ░ 14
           ╰───────────────────────────>')



oCopy = o1.Copy()
oCopy.RemoveMany([ "^", "│", "╰", "─", ">" ])
? oCopy.Content()


oCopy = o1.Copy()
oCopy.RemoveMany([ "^", "│", "╰" ])
? oCopy.Content()

oCopy = o1.Copy()
oCopy.RemoveMany([ "^", "╰", "─", ">" ])
? oCopy.Content()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- 
*/
pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
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
# Executed in almost 01 second(s) in Ring 1.22

/*---

pr()

oChart = new stzHBarChart([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20])
oChart {
	AddLabels()
//	AddAverage()
	SetBarWidth(1)
	Show()
}
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

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

oChart = new stzHBarChart([ 42, 18, 73, 29, 35, 70, 14, 34 ])

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

oChart = new stzHBarChart([
	:Mali 	= 42,
	:Niger 	= 18,
	:Egypt 	= 73,
	:Bosnia = 29,
	:Brazil = 35,
	:France = 70,
	:Spain 	= 14,
	:SouthKorea = 34
])

oChart { SetYXAxis([1, 0])  SetLabels(1) SetValues(0) Show() }
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
# ┊

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


