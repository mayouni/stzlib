load "../max/stzmax.ring"


/*===

pr()

aMyList = [
	:Mali  	 = [ 42, 18, 22 ],
	:Niger 	 = [ 87, 40, 18 ]
]

? IsHashList(aMyList)
#--> TRUE

? IsHashListOfNumbers(aMyList)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMyList = [
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 18 ]
]

? IsHashList(aMyList)
#--> TRUE

? IsHashListOfLists(aMyList)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

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
	SetYHAxis([1, 1])
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
oChart.SetHAxis(FALSE)
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
oChart.SetVAxis(FALSE)
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
oChart.SetXVAxis([FALSE, FALSE])
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
oChart.SetHAxis(FALSE)
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
oChart.SetVAxis(FALSE)
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
oChart.SetXVAxis([FALSE, FALSE])
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

#--------------------------------------------#
#  TEST SUITE FOR THE MULTI-BAR CHART CLASS  #
#--------------------------------------------#

#--- Using the short form StzCharQ()

pr()

StzChartQ(:MultiBar, [
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 18 ]
])

.Show()

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
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

# Test 1: Basic Multi-Series Chart (same as previous sample but with new stz...)

oChart = new stzMultiBarChart([
	:Mali = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger = [ :2020 = 87, :2022 = 40, :2024 = 18 ]
])

oChart.Show()
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

/*---

pr()

# Test 2: Customized Bar Width and Spacing

oChart = new stzMultiBarChart([
  :Sales = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=18 ]
])

oChart {

	# Default display
	Show()

	# Personalsed display
	SetBarWidth(1)
	SetSeriesSpace(1)
	SetCategorySpace(3)
	SetLegend(FALSE)

	Show()
}
#-->
'
^
│                         ██     
│         ██              ██     
│         ██      ██      ██     
│ ██      ██      ██      ██▒▒   
│ ██      ██▒▒    ██▒▒    ██▒▒▓▓ 
│ ██▒▒    ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓ 
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓ 
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓ 
╰────────────────────────────────>
    Q1      Q2      Q3      Q4   
                                 
██ Sales   ▒▒ Costs   ▓▓ Profit 

^
│                         █     
│         █               █     
│         █       █       █     
│ █       █       █       █ ▒   
│ █       █ ▒     █ ▒     █ ▒ ▓ 
│ █ ▒     █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
╰───────────────────────────────>
   Q1      Q2      Q3      Q4   
'
pf()

/*---
# Executed in 0.05 second(s) in Ring 1.22

pr()

# Test 2: Customized Bar Width and Spacing

oChart = new stzMultiBarChart([
  :Sales = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=18 ]
])

oChart {
	# A clean simple value-enabled chart
//	SetBarWidth(2)
//	SetSeriesSpace(1)
//	SetCategorySpace(3)

	AddValues()
	AddAverage()
	SetLegend(FALSE)
	Show()

	# An elaborated %-enabled chart
//	SetBarWidth(3)
//	SetSeriesSpace(2)
//	SetCategorySpace(5)

	AddPercent()
	SetAverage(0)
	SetLegend(TRUE)
	Show()
}


#-->
'
^
│                         █     
│         █               █     
│         █       █       █     
│ █       █       █       █ ▒   
│ █       █ ▒     █ ▒     █ ▒ ▓ 
│ █ ▒     █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓ 
╰───────────────────────────────>
   Q1      Q2      Q3      Q4   
                                
██ Sales   ▒▒ Costs   ▓▓ Profit 
'
pf()


/*---

pr()

# Test 3: Custom Series Characters
? "=== Test 3: Custom Series Characters ==="

oChart = new stzMultiBarChart([
	:TeamA = [ :Jan = 45, :Feb = 52, :Mar = 38 ],
	:TeamB = [ :Jan = 38, :Feb = 41, :Mar = 49 ],
	:TeamC = [ :Jan = 29, :Feb = 35, :Mar = 42 ]
])

oChart {
	SetSeriesChars(["●", "▲", "■"])
	SetBarWidth(2)
	Show()
}

pf()

/*---

pr()

# Test 4: With Values Display
? "=== Test 4: With Values Display ==="

oChart = new stzMultiBarChart([
	:Product1 = [ :Store1 = 12, :Store2 = 18, :Store3 = 15 ],
	:Product2 = [ :Store1 = 20, :Store2 = 14, :Store3 = 22 ]
])

oChart {
	SetValues(True)
	SetBarWidth(2)
	Show()
}

pf()

/*---

pr()

# Test 5: With Percentage Display
? "=== Test 5: With Percentage Display ==="

oChart = new stzMultiBarChart([
	:Desktop = [ :2021 = 65, :2022 = 58, :2023 = 52 ],
	:Mobile = [ :2021 = 35, :2022 = 42, :2023 = 48 ]
])

oChart {
	SetPercent(True)
	SetBarWidth(1)
	Show()
}

pf()

/*---

pr()

# Test 6: Hide/Show Axes and Labels
? "=== Test 6: Hide/Show Axes and Labels ==="

oChart = new stzMultiBarChart([
	:North = [ :Spring = 30, :Summer = 45, :Fall = 25, :Winter = 20 ],
	:South = [ :Spring = 35, :Summer = 50, :Fall = 30, :Winter = 25 ]
])

# With full display
oChart {
	SetHAxis(True)
	SetVAxis(True)  
	SetLabels(True)
	SetLegend(True)
	Show()
}

? ""
? "--- Same chart with minimal display ---"

# With minimal display
oChart {
	SetHAxis(False)
	SetVAxis(False)
	SetLabels(False)
	SetLegend(False)
	Show()
}

pf()

/*---

pr()

# Test 7: Compact Multi-Series
? "=== Test 7: Compact Multi-Series ==="

oChart = new stzMultiBarChart([
	:A = [ :X = 8, :Y = 12, :Z = 6 ],
	:B = [ :X = 15, :Y = 9, :Z = 18 ],
	:C = [ :X = 11, :Y = 16, :Z = 13 ]
])

oChart {
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(1)
	SetMaxWidth(50)
	Show()
}

pf()

/*---

pr()

# Test 8: Large Dataset with Custom Characters
? "=== Test 8: Large Dataset with Custom Characters ==="

oChart = new stzMultiBarChart([
	:Region1 = [ :Mon = 23, :Tue = 31, :Wed = 28, :Thu = 35, :Fri = 42 ],
	:Region2 = [ :Mon = 18, :Tue = 25, :Wed = 33, :Thu = 29, :Fri = 38 ],
	:Region3 = [ :Mon = 31, :Tue = 27, :Wed = 24, :Thu = 41, :Fri = 36 ],
	:Region4 = [ :Mon = 26, :Tue = 39, :Wed = 31, :Thu = 33, :Fri = 28 ]
])

oChart {
	SetSeriesChars(["█", "▓", "▒", "░"])
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(2)
	Show()
}

pf()

/*---

pr()

# Test 9: Two Series Comparison
? "=== Test 9: Two Series Comparison ==="

oChart = new stzMultiBarChart([
	:Before = [ :Feature1 = 45, :Feature2 = 38, :Feature3 = 52, :Feature4 = 29 ],
	:After = [ :Feature1 = 62, :Feature2 = 48, :Feature3 = 59, :Feature4 = 41 ]
])

oChart {
	SetSeriesChars(["▒", "█"])
	SetBarWidth(2)
	SetSeriesSpace(1)
	AddLabels()
	Show()
}

pf()

/*---

pr()

# Test 10: Performance Metrics
? "=== Test 10: Performance Metrics ==="

oChart = new stzMultiBarChart([
	:CPU = [ :Server1 = 75, :Server2 = 82, :Server3 = 68, :Server4 = 91 ],
	:Memory = [ :Server1 = 65, :Server2 = 78, :Server3 = 72, :Server4 = 85 ],
	:Disk = [ :Server1 = 45, :Server2 = 52, :Server3 = 48, :Server4 = 61 ]
])

oChart {
	SetSeriesChars(["■", "▲", "●"])
	SetBarWidth(1)
	SetValues(True)
	Show()
}

pf()

# Expected outputs would show various multi-series bar charts demonstrating:
# - Basic functionality with legend
# - Different bar widths and spacing options  
# - Custom series characters (bars, triangles, circles, etc.)
# - Value and percentage displays
# - Axis and label visibility controls
# - Compact and expanded layouts
# - Multiple series comparisons
# - Real-world data scenarios

/*====

// Setting the legend layout to :Vertical
pr()

oChart = new stzMultiBarChart([
	:Desktop = [ :Q1 = 45, :Q2 = 42 ],
	:Mobile =  [ :Q1 = 35, :Q2=48 ],
	:Tablet =  [ :Q1 = 15, :Q2 = 18 ]
])

oChart {
//	SetBarsChars([ "█", "|", "X" ])
	SetBarWidth(3)
	SetBarInterSpace(1)

	AddValues()
	SetLegendLayout(:Vertical)

	Show()
	SetLegend(False)

}
#-->
'
^
│ 45         42 48    
│ ██ 35      ██ ▒▒    
│ ██ ▒▒      ██ ▒▒    
│ ██ ▒▒      ██ ▒▒    
│ ██ ▒▒ 15   ██ ▒▒ 18 
│ ██ ▒▒ ▓▓   ██ ▒▒ ▓▓ 
│ ██ ▒▒ ▓▓   ██ ▒▒ ▓▓ 
│ ██ ▒▒ ▓▓   ██ ▒▒ ▓▓ 
╰─────────────────────>
     Q1         Q2    
                      
██ Desktop        
▒▒ Mobile         
▓▓ Tablet   
'
pf()
#--> Executed in 0.03 second(s) in Ring 1.22


#--------------------------------------#
#  TEST SAMPLE OF THE HISTOGRAM CHART  #
#--------------------------------------#


/*--- Basic histogram with student test scores
*/
pr()

aScores = [85, 92, 78, 88, 95, 82, 90, 87, 93, 86, 79, 91, 84, 89, 96, 83, 88, 92, 87, 85]
oChart = new stzHistogram(aScores)
oChart {

//	? @@(AggregationTypes())
	#--> [ "frequency", "sum", "average", "min", "max" ]

//	SetBarInterSpace(1)
//	SetLabelInterSpace(2)

//  SetBinCount(5) # Or DivideToNGroups(5)
	# ~> # Auto-calculate bin count using Sturges' rule if not set

	UseFrequency()
	IncludeValues()

    Show()
}
#-->
'
^
│                    5               
│              4     ██    4         
│              ██    ██    ██    3   
│              ██    ██    ██    ██  
│  2     2     ██    ██    ██    ██  
│  ██    ██    ██    ██    ██    ██  
│  ██    ██    ██    ██    ██    ██  
│  ██    ██    ██    ██    ██    ██  
╰────────────────────────────────────>
  78.0  81.0  84.0  87.0  90.0  93.0 
  81.0  84.0  87.0  90.0  93.0  96.0 
'

pf()
# Executed in 0.33 second(s) in Ring 1.22

/*--- Histogram with frequency display and statistics
*/
pr()

aTemperatures = [72, 74, 76, 73, 75, 78, 79, 77, 74, 76, 75, 73, 77, 78, 76, 74, 75, 79, 78, 77]
oChart = new stzHistogram(aTemperatures)
oChart {
    SetBinCount(4)
    AddFrequency()
    AddStats()
    AddLabels()
    Show()
}
#-->
'
      ^
    6 │  6
      │ ██
      │ ██     5
    4 │ ██    ██
      │ ██    ██
      │ ██    ██  4   5
    2 │ ██    ██ ██  ██
      │ ██    ██ ██  ██
      ╰─────────────────────>
        72-74 74-76 76-78 78-80

Mean: 75.8 | StdDev: 2.1 | Median: 76.0 | Count: 20
'

pf()


/*--- Histogram with percentage display

pr()

aSalaries = [45000, 52000, 48000, 67000, 55000, 49000, 58000, 62000, 51000, 46000, 
             59000, 53000, 47000, 61000, 56000, 50000, 54000, 48000, 60000, 57000]
oChart = new stzHistogram(aSalaries)
oChart {
    SetBinCount(6)
    AddPercent()
    AddLabels()
    SetBarChar("▓")
    Show()
}
#-->
'
        ^
      │ 25.0%
    4 │ ▓▓▓
      │ ▓▓▓   20.0%  20.0%
    3 │ ▓▓▓   ▓▓▓    ▓▓▓   15.0%
      │ ▓▓▓   ▓▓▓    ▓▓▓   ▓▓▓   15.0%
    2 │ ▓▓▓   ▓▓▓    ▓▓▓   ▓▓▓   ▓▓▓    5.0%
      │ ▓▓▓   ▓▓▓    ▓▓▓   ▓▓▓   ▓▓▓    ▓▓▓
    1 │ ▓▓▓   ▓▓▓    ▓▓▓   ▓▓▓   ▓▓▓    ▓▓▓
      ╰─────────────────────────────────────────>
        45k-48k 48k-52k 52k-55k 55k-59k 59k-62k 62k-67k
'

pf()

/*--- Simple histogram without axes

pr()
aAges = [25, 34, 45, 28, 37, 42, 31, 39, 33, 46, 29, 38, 41, 35, 27, 44, 36, 32, 40, 43]
oChart = new stzHistogram(aAges)
oChart {
    SetBinCount(4)
    WithoutXAxis()
    WithoutYAxis()
    AddFrequency()
    SetBarChar("■")
    SetBarWidth(4)
    Show()
}
#-->
'
     6
    ■■■■
    ■■■■     5      5      4
    ■■■■    ■■■■   ■■■■   ■■■■
    ■■■■    ■■■■   ■■■■   ■■■■
    ■■■■    ■■■■   ■■■■   ■■■■
    25-30   30-35  35-40  40-46
'
pf()

/*--- Compact histogram with custom bin width
*/

pr()

aWeights = [150, 155, 160, 152, 158, 162, 165, 159, 157, 161, 163, 156, 154, 164, 166, 153, 151, 167, 168, 149]
oChart = new stzHistogram(aWeights)
oChart {
    SetBinWidth(5)
    AddLabels()
    SetBarWidth(2)
    SetBarInterSpace(2)
    WithoutLabels()
    Show()
}
#-->
'
      ^
    8 │
      │ ██
      │ ██
    6 │ ██
      │ ██
      │ ██
    4 │ ██    ██
      │ ██    ██
    2 │ ██    ██    ██    ██
      │ ██    ██    ██    ██
      ╰─────────────────────────>
'
