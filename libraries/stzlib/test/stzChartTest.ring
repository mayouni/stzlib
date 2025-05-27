load "../max/stzmax.ring"


/*===============

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

? oChart.LargestBarWidth()

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

pr()

oChart = new stzVBarChart([
	:Mali 	= 42,
	:Niger 	= 18,
	:Egypt 	= 73,
	:Bosnia = 29,
	:Brazil = 35,
	:France = 70,
	:Spain 	= 14,
	:SouthKorea = 34
])

oChart { SetYXAxis([1, 1])  SetLabels(1) SetValues(1) Show()  }
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

#----------------------------------------------------#
#  Test Suite for stzVBarChart (Vertical Bar Chart)  #
#----------------------------------------------------#

/*--- Test 1: Basic vertical bar chart

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.Show()
#-->
'
^
│    ██    
│    ██    
│    ██    
│ ██ ██    
│ ██ ██    
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 2: Custom width and height

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetSize(50, 15)
oChart.Show()
#-->
'
^
│    ██    
│    ██    
│    ██    
│    ██    
│ ██ ██    
│ ██ ██    
│ ██ ██    
│ ██ ██    
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 3: Custom bar character

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarChar("X")
oChart.Show()
#-->
'
^
│    XX    
│    XX    
│    XX    
│ XX XX    
│ XX XX    
│ XX XX XX 
│ XX XX XX 
│ XX XX XX 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 4: X-axis disabled

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXAxis(FALSE)
oChart.Show()
#-->
'
^
│    ██    
│    ██    
│    ██    
│ ██ ██    
│ ██ ██    
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
           
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 5: Y-axis disabled

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetYAxis(FALSE)
oChart.SetLabels(TRUE)
oChart.Show()
#-->
'
    ██    
    ██    
    ██    
 ██ ██    
 ██ ██    
 ██ ██ ██ 
 ██ ██ ██ 
 ██ ██ ██ 
──────────>
 A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 6: Both axes disabled

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXYAxis([FALSE, FALSE])
oChart.Show()
#-->
'
    ██    
    ██    
    ██    
 ██ ██    
 ██ ██    
 ██ ██ ██ 
 ██ ██ ██ 
 ██ ██ ██ 
          
 A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 7: Labels disabled

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetLabels(FALSE)
oChart.Show()
#-->
'
^
│    ██    
│    ██    
│    ██    
│ ██ ██    
│ ██ ██    
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
╰──────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 8: Average line enabled

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetAverageLine(TRUE)
oChart.Show()
#-->
'
^
│    ██    
│    ██    
│ ---██--- 
│ ██ ██    
│ ██ ██    
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 9: Values displayed
*/
pr()

oChart = new stzVBarChart([ :A = 7520, :B = 8898, :C = 32393 ])
oChart.SetValues(TRUE)
oChart.Show()
#-->
'
^
│    8     
│    ██    
│ 5  ██    
│ ██ ██    
│ ██ ██ 3  
│ ██ ██ ██ 
│ ██ ██ ██ 
│ ██ ██ ██ 
╰──────────>
  A  B  C  
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 10: Custom bar width

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarWidth(5)
oChart.Show()
#-->
'
^
│       █████       
│       █████       
│       █████       
│ █████ █████       
│ █████ █████       
│ █████ █████ █████ 
│ █████ █████ █████ 
│ █████ █████ █████ 
╰───────────────────>
    A     B     C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 11: Multiple bars with varying values

pr()

oChart = new stzVBarChart([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oChart.Show()
#-->
'
^
│          ██    
│    ██    ██    
│    ██    ██ ██ 
│    ██    ██ ██ 
│    ██ ██ ██ ██ 
│ ██ ██ ██ ██ ██ 
│ ██ ██ ██ ██ ██ 
│ ██ ██ ██ ██ ██ 
╰────────────────>
  Q1 Q2 Q3 Q4 Q5 
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 12: Zero values

pr()

oChart = new stzVBarChart([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oChart.Show()
#-->
'
^
│         ██                
│         ██                
│         ██                
│         ██                
│         ██                
│         ██                
│         ██                
│         ██                
╰───────────────────────────>
  Zero Positive Anotherzero 
'

pf()

/*--- Test 13: Single bar

pr()

oChart = new stzVBarChart([ :Single = 10 ])
oChart.Show()
#-->
'
^
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
│   ██   
╰────────>
  Single 
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 14: Large values with scaling

pr()

oChart = new stzVBarChart([ :Small = 1, :Large = 1000 ])
oChart.Show()
#-->
'
^
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│        ██   
│  ██    ██   
╰─────────────>
  Small Large 
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#------------------------------------------------------#
#  Test Suite for stzHBarChart (Horizontal Bar Chart)  #
#------------------------------------------------------#

/*--- Test 1: Basic horizontal bar chart

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.Show()
# Expected: Horizontal bars for A, B, C with lengths proportional to 5, 8, 3, labels on the left

pf()

/*--- Test 2: Custom width and height

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetSize(50, 10)
oChart.Show()
# Expected: Same chart with a width of 50 characters and height of 10 lines

pf()

/*--- Test 3: Custom bar character

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarChar("=")
oChart.Show()
# Expected: Bars made of '=' instead of default '▇'


/*--- Test 4: X-axis disabled

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXAxis(FALSE)
oChart.Show()
# Expected: Chart without the X-axis (bottom horizontal line)


/*--- Test 5: Y-axis disabled

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetYAxis(FALSE)
oChart.Show()
# Expected: Chart without the Y-axis (vertical line)


/*--- Test 6: Both axes disabled

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXYAxis([FALSE, FALSE])
oChart.Show()
# Expected: Chart with no axes


/*--- Test 7: Labels disabled

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetLabels(FALSE)
oChart.Show()
# Expected: Chart without labels on the left side


/*--- Test 8: Values displayed

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetValues(TRUE)
oChart.Show()
# Expected: Chart with numerical values (5, 8, 3) next to each bar


/*--- Test 9: Custom bar height

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarHeight(2)
oChart.Show()
# Expected: Each bar occupies 2 rows (Note: Current implementation may not fully support multi-row bars)


/*--- Test 10: Custom maximum label width

oChart = new stzHBarChart([ :LongLabel = 10, :AnotherLongLabel = 20 ])
oChart.SetMaxLabelWidth(5)
oChart.Show()
# Expected: Labels truncated to 5 characters (e.g., "LongL..", "Anothe..")


/*--- Test 11: Long labels

oChart = new stzHBarChart([ :ThisIsALongLabel = 15, :Short = 5 ])
oChart.Show()
# Expected: Long labels truncated to max width (12 by default) with ".." (e.g., "ThisIsALon..")


/*--- Test 12: Multiple bars with varying values

oChart = new stzHBarChart([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oChart.Show()
# Expected: Five horizontal bars with lengths proportional to 10, 25, 15, 30, 20


/*--- Test 13: Zero values

oChart = new stzHBarChart([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oChart.Show()
# Expected: Bars for zero values have minimal length (1 unit), Positive bar at 5


/*--- Test 14: Single bar

oChart = new stzHBarChart([ :Single = 10 ])
oChart.Show()
# Expected: A single horizontal bar with length proportional to 10


/*--- Test 15: Large values with scaling

oChart = new stzHBarChart([ :Small = 1, :Large = 1000 ])
oChart.Show()
# Expected: Two bars scaled to fit the chart, with Large much longer than Small
