load "../max/stzmax.ring"


/*---

pr()

StzChartQ(:VBar, [ 5, 4, 2, 5, 3, 2, 4 ]) {

	# Default chart
	SetHight(7)
	Show()

	# Personalized chart

	SetTopBarChar("●")
	SetBarChar("┃")
	SetBarWidth(1)
	
	Show()

	# Further personalization
	SetBarWidth(2)
	SetBarInterSpace(0)
	Show()

}
#-->
'
^
│ ██       ██          
│ ██ ██    ██       ██ 
│ ██ ██    ██ ██    ██ 
│ ██ ██ ██ ██ ██ ██ ██ 
│ ██ ██ ██ ██ ██ ██ ██ 
╰──────────────────────>
  1  2  3  4  5  6  7  

^
│ ●     ●       
│ ┃ ●   ┃     ● 
│ ┃ ┃   ┃ ●   ┃ 
│ ┃ ┃ ● ┃ ┃ ● ┃ 
│ ┃ ┃ ┃ ┃ ┃ ┃ ┃ 
╰───────────────>
  1 2 3 4 5 6 7 

^
│ ●●    ●●       
│ ┃┃●●  ┃┃    ●● 
│ ┃┃┃┃  ┃┃●●  ┃┃ 
│ ┃┃┃┃●●┃┃┃┃●●┃┃ 
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃ 
╰────────────────>
  1 2 3 4 5 6 7  
'

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*===============

pr()

oChart = new stzVBarChart([ :A = 5, :B = 8, :C = 3 ])
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

oChart = new stzVBarChart([
	:Q1 = 9, :Q2 = 25, :Q3 = 15, :Q4 = 32, :Q5 = 20
])

oChart {
	AddValues()
	AddAverage()

	SetBarWidth(1)
	SetTopbarChar("▲")
	Show()
}
#-->
'
^
│          32    
│    25    ▲     
│    ▲  15 █  20 
│----█-----█--▲-- 20.2
│    █  ▲  █  █  
│ 9  █  █  █  █  
│ ▲  █  █  █  █  
│ █  █  █  █  █  
╰────────────────>
  Q1 Q2 Q3 Q4 Q5 
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

oChart = new stzVBarChart([ 42, 18, 73, 29, 35, 70, 14, 34 ])

oChart {
	SetHight(3)
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
# Executed in almost 0.03 second(s) in Ring 1.22

/*--- #TODO Add SetPercent() to horizontal chart

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

oChart {
	SetYXAxis([1, 1])
	SetLabels(1)
	SetPercent(1)
	Show()
}
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

#TODO Use ┊ in setAverage() in horizontal chart

pf()
# Executed in almost 0 second(s) in Ring 1.22


/*=== TODO

*/
pr()

oChart = new stzMultiBarChart([
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 18 ]
])
oChart {
    AddLabels()
    Show()
}
#-->
'
^
│   ▒▒             
│   ▒▒             
│   ▒▒             
│   ▒▒             
│ ██▒▒    ▒▒       
│ ██▒▒    ▒▒  ██   
│ ██▒▒  ██▒▒  ██▒▒ 
│ ██▒▒  ██▒▒  ██▒▒ 
╰──────────────────>
  2020  2022  2024 
                   
██ Mali   ▒▒ Niger 
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

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

/*--- Test 2: Custom width and Hight

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

pr()

oChart = new stzVBarChart([ :A = 7520, :B = 8898, :C = 32393 ])
oChart.SetValues(TRUE)
oChart.Show()
#-->
'
^
│           32393 
│            ██   
│            ██   
│            ██   
│            ██   
│ 7520 8898  ██   
│  ██   ██   ██   
│  ██   ██   ██   
╰─────────────────>
   A    B     C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 9: Values displayed

pr()

oChart = new stzVBarChart([
	:Green = 7520,
	:BlackAndWhite = 8898,
	:Blue = 32393
])

oChart {

	SetPercent(TRUE)
	Show()

	SetValues(TRUE)
	Show()

}

pf()
# Executed in 0.13 second(s) in Ring 1.22

#-->
'
^
│                     66.4% 
│                      ██   
│                      ██   
│                      ██   
│                      ██   
│ 15.4%     18.2%      ██   
│  ██        ██        ██   
│  ██        ██        ██   
╰───────────────────────────>
  Green Blackandwhite Blue  
^
│                     32393 
│                      ██   
│                      ██   
│                      ██   
│                      ██   
│ 7520      8898       ██   
│  ██        ██        ██   
│  ██        ██        ██   
╰───────────────────────────>
  Green Blackandwhite Blue  
'

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Test 10: Custom bar width with long label

pr()

oChart = new stzVBarChart([ :A = 5, :BColumnLableIsSoLong = 8, :C = 3 ])
oChart.SetBarWidth(5)
oChart.Show()
#-->
'
^
│          █████           
│          █████           
│          █████           
│ █████    █████           
│ █████    █████           
│ █████    █████     █████ 
│ █████    █████     █████ 
│ █████    █████     █████ 
╰──────────────────────────>
    A   Bcolumnlab..   C   
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


oChart.SetBarWidth(1)
ochart.SetBarInterSpace(0) #TODO has no effect
oChart.Show()

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
# Executed in 0.02 second(s) in Ring 1.22

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
# Executed in 0.02 second(s) in Ring 1.22

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

/*--- Test 1: Basic horizontal bar chart, with percent values,
# scaled down to 10 positions

pr()

oChart = new stzHBarChart([ :Warda = 5, :Yessmina = 8, :Folla = 3 ])

oChart.AddPercent()
oChart.Show()
#-->
'
          ^
   Warda │ ▇▇▇▇▇▇▇▇▇▇▇▇▇ 31.2%
Yessmina │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 50%
   Folla │ ▇▇▇▇▇▇▇▇ 18.8%
         ╰─────────────────────────────>
'
#NOTE: By default, the width is set on 30

oChart.SetWidth(10)
oChart.Show()
#-->
'
         ^
   Warda │ ▇▇▇▇▇▇▇ 31.2%
Yessmina │ ▇▇▇▇▇▇▇▇▇▇ 50%
   Folla │ ▇▇▇▇ 18.8%
         ╰───────────────────>
'

oChart.SetWidth(5)
oChart.Show()
#-->
'
   Warda │ ▇▇▇▇ 31.2%
Yessmina │ ▇▇▇▇▇ 50%
   Folla │ ▇▇ 18.8%
         ╰──────────────>
'

pf()
# Executed in 0.45 second(s) in Ring 1.22

/*--- Test 2: Custom width

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.Setwidth(50)
oChart.Show()
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
  ╰─────────────────────────────────────────────────────>
'

# Note: Hight can not changed with SetHight() in horizontal bars

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Test 3: Custom bar character

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarChar("=")
oChart.Show()
# Expected: Bars made of '=' instead of default '▇'
#-->
'
  ^
A │ =============
B │ ====================
C │ ========
  ╰───────────────────────>
'

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Test 4: X-axis disabled

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXAxis(FALSE)
oChart.Show()
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇
'

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Test 5: Y-axis disabled

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetYAxis(FALSE)
oChart.Show()
# Expected: Chart without the Y-axis (vertical line)
#-->
'
A ▇▇▇▇▇▇▇▇▇▇▇▇▇
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇▇
  ────────────────────────>
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 6: Both axes disabled

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetXYAxis([FALSE, FALSE])
oChart.Show()
# Expected: Chart with no axes
#-->
'
A ▇▇▇▇▇▇▇▇▇▇▇▇▇
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇▇
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 7: Labels disabled

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetLabels(FALSE)
oChart.Show()
# Expected: Chart without labels on the left side
#-->
'
^
│ ▇▇▇▇▇▇▇▇▇▇▇▇▇
│ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
│ ▇▇▇▇▇▇▇▇
╰───────────────────────>
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 8: Values displayed

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetValues(TRUE)
oChart.Show()
# Expected: Chart with numerical values (5, 8, 3) next to each bar
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇ 5
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 8
C │ ▇▇▇▇▇▇▇▇ 3
  ╰─────────────────────────>
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 9: Custom bar Hight

pr()

oChart = new stzHBarChart([ :A = 5, :B = 8, :C = 3 ])
oChart.SetBarHight(2)
oChart.Show()
# Expected: Current implementation do not support multi-row bars
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇
  ╰───────────────────────>
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 10: Custom maximum label width

pr()

oChart = new stzHBarChart([ :LongLabel = 10, :AnotherLongLabel = 20 ])
oChart.SetMaxLabelWidth(5)
oChart.Show()
# Expected: Labels truncated to 5 characters (e.g., "LongL..", "Anothe..")
#-->
'
      ^
Lon.. │ ▇▇▇▇▇▇▇▇▇▇
Ano.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰───────────────────────>
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*--- Test 11: Long labels

pr()

oChart = new stzHBarChart([ :ThisIsALongLabel = 15, :Short = 5 ])
oChart.Show()
# Expected: Long labels truncated to max width (12 by default) with ".." (e.g., "ThisIsALon..")
#-->
'
             ^
Thisisalon.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       Short │ ▇▇▇▇▇▇▇
             ╰───────────────────────>
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Test 12: Multiple bars with varying values

pr()

oChart = new stzHBarChart([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oChart.Show()
# Expected: Five horizontal bars with lengths proportional to 10, 25, 15, 30, 20
#-->
'
   ^
Q1 │ ▇▇▇▇▇▇▇
Q2 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Q3 │ ▇▇▇▇▇▇▇▇▇▇
Q4 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Q5 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇
   ╰───────────────────────>
'

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Test 13: Zero values

pr()

oChart = new stzHBarChart([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oChart.Show()
# Expected: Bars for zero values not displayed, Positive bar at 5
#-->
'
            ^
       Zero │
   Positive │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Anotherzero │
            ╰───────────────────────>
'

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Test 14: Single bar

pr()

oChart = new stzHBarChart([ :Single = 10 ])
oChart.Show()
# Expected: A single horizontal bar with length proportional to 10
#-->
'
       ^
Single │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       ╰───────────────────────>
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Test 15: Large values with scaling

pr()

oChart = new stzHBarChart([ :Small = 1, :Large = 1000 ])
oChart.Show()
# Expected: Two bars scaled to fit the chart, with Large much longer than Small
#-->
'
      ^
Small │ ▇
Large │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰───────────────────────>
'

pf()
# Executed in 0.07 second(s) in Ring 1.22
