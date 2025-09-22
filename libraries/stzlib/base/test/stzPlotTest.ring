load "../stzbase.ring"


/*===

pr()

# Basic compact form
oNum = new stzNumber(1_290_800_280)
? oNum.ToCompactForm()
#--> 1.3B

? oNum.ToKForm()
#--> 1290800.3K

? oNum.ToMForm()
#--> 1290.8M

? oNum.ToBForm()
#--> 1.3B

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.07 second(s) in Ring 1.22


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

#--------------------------------------------------#
#  Test Suite for stzVBarPlot (Vertical Bar Plot)  #
#--------------------------------------------------#

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

/*===

pr()

StzChartQ(:VBar, [ 5, 4, 2, 5, 3, 2, 4 ]) {

	# Default chart
	Show()

	# Personalized chart

	SetTopChar("●") #TODO // 3ERR Check why it's not displayed
	SetBarChar("┃")
	SetBarWidth(1)
	
	Show()

	# Further personalization
	SetBarWidth(2)
	SetBarInterSpace(0)
	WithoutAxisLabels()
	Show()

}
#-->
'
↑                       
│ ██       ██           
│ ██ ██    ██       ██  
│ ██ ██    ██ ██    ██  
│ ██ ██    ██ ██    ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  

↑                       
│ ●        ●            
│ ┃  ●     ┃        ●   
│ ┃  ┃     ┃  ●     ┃   
│ ┃  ┃     ┃  ┃     ┃   
│ ┃  ┃  ●  ┃  ┃  ●  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  

↑                 
│ ●●    ●●        
│ ┃┃●●  ┃┃    ●●  
│ ┃┃┃┃  ┃┃●●  ┃┃  
│ ┃┃┃┃  ┃┃┃┃  ┃┃  
│ ┃┃┃┃●●┃┃┃┃●●┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
│ ┃┃┃┃┃┃┃┃┃┃┃┃┃┃  
╰────────────────>
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*===============

pr()

oPlot = new stzBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.AddValues()
oPlot.Show()
#-->
'
↑           
│    8      
│    ██     
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
# Executed in almost 0.01 second(s) in Ring 1.22

/*---

pr()

oPlot = new stzVBarPlot([
	:Q1 = 9, :Q2 = 25, :Q3 = 15, :Q4 = 32, :Q5 = 20
])

oPlot {
	AddValues()
	AddAverage()

	SetBarWidth(1)
	SetTopChar("▲")
	Show()

}
#-->
'
↑                       
│          32           
│    25    ▲            
│    ▲     █  20        
│----█--15-█--▲--- 20.2 
│    █  ▲  █  █         
│ 9  █  █  █  █         
│ ▲  █  █  █  █         
│ █  █  █  █  █         
╰────────────────>      
  Q1 Q2 Q3 Q4 Q5      
'

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*---

pr()

oPlot = new stzVBarPlot([ 42, 18, 73, 29, 35, 70, 14, 34 ])

oPlot {

	SetHeight(2)
	SetBarWidth(1)
	SetLabelChar(FALSE)
	Show()
	? ""

	WithoutAxies() #TODO #ERR // See why lables are displayed
	Show()

	# Try with
//	WithoutYAxis()
//	WithoutXAxis()
//	WithoutAxisLabels()
}
#-->
'
↑                  
│ █   █     █      
│ █ █ █ █ █ █ █ █  
╰─────────────────>
  1 2 3 4 5 6 7 8  

█   █     █      
█ █ █ █ █ █ █ █  
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- #TODO Add SetPercent() to horizontal chart

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

/*--- Custom width and Hight

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetSize(50, 15)
oPlot.Show()
#-->
'
↑           
│    ██     
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
│ ██ ██ ██  
╰──────────>
  A  B  C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22

/*--- Custom bar character

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetBarChar("X")
oPlot.Show()
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
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22

/*--- X-axis disabled

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetXAxis(FALSE)
oPlot.Show()
#-->
'
↑           
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
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22

/*--- Y-axis disabled

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetYAxis(FALSE)
oPlot.SetLabels(TRUE)
oPlot.Show()
#-->
'
   ██     
   ██     
██ ██     
██ ██     
██ ██ ██  
██ ██ ██  
██ ██ ██  
─────────>
A  B  C   
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Labels disabled

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetLabels(FALSE)
oPlot.Show()
#-->
'
↑           
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
# Etxecued in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22

/*--- Average line enabled

pr()

oPlot = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetAverage(TRUE)
oPlot.Show()
#-->
'
↑                
│    ██          
│    ██          
│-██-██-----     
│ ██ ██          
│ ██ ██ ██       
│ ██ ██ ██       
│ ██ ██ ██       
╰──────────>     
  A  B  C     
'

? ""

oPlot.AddValues()
oPlot.Show()
#-->
'
↑                
│    8           
│    ██          
│ 5  ██          
│-██-██----- 5.3 
│ ██ ██ 3        
│ ██ ██ ██       
│ ██ ██ ██       
│ ██ ██ ██       
╰──────────>     
  A  B  C      
'

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.15 second(s) in Ring 1.22

/*--- Values displayed

pr()

oPlot = new stzVBarPlot([ :A = 7520, :B = 8898, :C = 32393 ])
oPlot.SetValues(TRUE)
oPlot.Show()
#-->
'
↑                  
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
# Executed in 0.04 second(s) in Ring 1.22

/*--- Values displayed

pr()

oPlot = new stzVBarPlot([
	:Green = 7520,
	:BlackAndWhite = 8898,
	:Blue = 32393
])

oPlot {

	SetPercent(TRUE)
	Show()

	? ""
	SetValues(TRUE)
	Show()

}

pf()
# Executed in 0.13 second(s) in Ring 1.22

#-->
'
↑                           
│                    66.4%  
│                     ██    
│                     ██    
│                     ██    
│                     ██    
│ 15.4%    18.2%      ██    
│  ██        ██       ██    
│  ██        ██       ██    
╰──────────────────────────>
  Green Blackandwh.. Blue   

↑                           
│                    32393  
│                     ██    
│                     ██    
│                     ██    
│                     ██    
│ 7520      8898      ██    
│  ██        ██       ██    
│  ██        ██       ██    
╰──────────────────────────>
  Green Blackandwh.. Blue   
'

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.17 second(s) in Ring 1.22

/*--- Custom bar width with long label

pr()

oPlot = new stzVBarPlot([ :A = 5, :BColumnLableIsSoLong = 8, :C = 3 ])
oPlot.SetBarWidth(5)
oPlot.Show()
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
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22

/*--- Multiple bars with varying values

pr()

oPlot = new stzVBarPlot([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oPlot.Show()
#-->
'
↑                 
│          ██     
│    ██    ██     
│    ██    ██ ██  
│    ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██  
╰────────────────>
  Q1 Q2 Q3 Q4 Q5  
'

oPlot.SetBarWidth(1)
oPlot.SetBarInterSpace(0) #TODO has no effect
oPlot.Show()
#-->
'
↑             
│       █     
│   █   █     
│   █   █ █   
│   █ █ █ █   
│ █ █ █ █ █   
│ █ █ █ █ █   
│ █ █ █ █ █   
╰────────────>
  Q1Q2Q3Q4Q5  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Zero values

pr()

oPlot = new stzVBarPlot([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oPlot.Show()
#-->
'
↑                            
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
│         ██                 
╰──────────────────────────>
  Zero Positive Anotherzero  
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.22

/*--- Single bar

pr()

oPlot = new stzVBarPlot([ :Single = 10 ])
oPlot.Show()
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
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22

/*--- Large values with scaling

pr()

oPlot = new stzVBarPlot([ :Small = 1, :Large = 1000 ])
oPlot.Show()
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
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.22

#------------------------------------------------------#
#  Test Suite for stzHBarPlot (Horizontal Bar Plot)  #
#------------------------------------------------------#

/*--- Test 1: Basic horizontal bar chart, with percent values,

pr()

oPlot = new stzHBarPlot([ :Warda = 5, :Yessmina = 8, :Folla = 3 ])

oPlot.AddPercent()
oPlot.Show()
#-->
'
         ^                         
   Warda │ ▇▇▇▇▇▇▇▇▇▇▇▇ 31.2%      
Yessmina │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 50%  
   Folla │ ▇▇▇▇▇▇▇ 18.8%           
         ╰───────────────────>   
'
#NOTE: By default, the width is set on 18
? oPlot.Width()
#--> 18

oPlot.SetWidth(10)
oPlot.Show()
#-->
'
         ^                 
   Warda │ ▇▇▇▇▇▇▇ 31.2%   
Yessmina │ ▇▇▇▇▇▇▇▇▇▇ 50%  
   Folla │ ▇▇▇▇ 18.8%      
         ╰───────────>  
'

oPlot.SetWidth(5)
oPlot.Show()
#-->
'
         ^                 
   Warda │ ▇▇▇▇▇▇▇ 31.2%   
Yessmina │ ▇▇▇▇▇▇▇▇▇▇ 50%  
   Folla │ ▇▇▇▇ 18.8%      
         ╰───────────>    
'

pf()
# Executed in 0.14 second(s) in Ring 1.23
# Executed in 0.28 second(s) in Ring 1.22

/*--- Test 2: Custom width
*/
pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3, :D = 2, :E = 4 ])
oPlot.Setwidth(40)
oPlot.Show()
#-->
'
  ^                                         
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇               
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                         
D │ ▇▇▇▇▇▇▇▇▇▇                              
E │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                    
  ╰────────────────────────────────────────>
'

# Note: Hight can not changed with SetHight() in horizontal bars
# but we can define a maximum number of horizontal bars with SetMawHight()

? ""

? oPlot.MaxHeight()
#--> 30

oPlot.SetMaxHeight(3)
oPlot.Show()
#-->
'
  ^                                         
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇               
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                         
  ╰────────────────────────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 3: Custom bar character

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetBarChar("=")
oPlot.Show()
# Expected: Bars made of '=' instead of default '▇'
#-->
'
  ^                   
A │ ============      
B │ ==================
C │ =======           
  ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 4: X-axis disabled

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetHAxis(FALSE)
oPlot.Show()
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C │ ▇▇▇▇▇▇▇▇
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 5: Y-axis disabled

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetVAxis(FALSE)
oPlot.Show()
# Expected: Plot without the Y-axis (vertical line)
#-->
'
A ▇▇▇▇▇▇▇▇▇▇▇▇      
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇           
  ─────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 6: Both axes disabled

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetHVAxis(FALSE, FALSE)
oPlot.SetAxisLabels(TRUE)

oPlot.Show()
# Expected: Plot with no axes
#-->
'
A ▇▇▇▇▇▇▇▇▇▇▇▇      
B ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
C ▇▇▇▇▇▇▇           
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 7: Labels disabled

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetLabels(FALSE)
oPlot.Show()
# Expected: Plot without labels on the left side
#-->
'
^
│ ▇▇▇▇▇▇▇▇▇▇▇▇▇
│ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
│ ▇▇▇▇▇▇▇▇
╰───────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 8: Values displayed

pr()

oPlot = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
oPlot.SetValues(TRUE)
oPlot.Show()
# Expected: Plot with numerical values (5, 8, 3) next to each bar
#-->
'
  ^
A │ ▇▇▇▇▇▇▇▇▇▇▇▇▇ 5
B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 8
C │ ▇▇▇▇▇▇▇▇ 3
  ╰─────────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 10: Custom maximum label width

pr()

oPlot = new stzHBarPlot([ :LongLabel = 10, :AnotherLongLabel = 20 ])
oPlot.SetMaxLabelWidth(5)
oPlot.Show()
# Expected: Labels truncated to 5 characters (e.g., "LongL..", "Anothe..")
#-->
'
      ^
Lon.. │ ▇▇▇▇▇▇▇▇▇▇
Ano.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰───────────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 11: Long labels

pr()

oPlot = new stzHBarPlot([ :ThisIsALongLabel = 15, :Short = 5 ])
oPlot.Show()
#-->
'
             ^                   
Thisisalon.. │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       Short │ ▇▇▇▇▇▇            
             ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 12: Multiple bars with varying values

pr()

oPlot = new stzHBarPlot([ :Q1 = 10, :Q2 = 25, :Q3 = 15, :Q4 = 30, :Q5 = 20 ])
oPlot.Show()
#-->
'
   ^                   
Q1 │ ▇▇▇▇▇▇            
Q2 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇   
Q3 │ ▇▇▇▇▇▇▇▇▇         
Q4 │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Q5 │ ▇▇▇▇▇▇▇▇▇▇▇▇      
   ╰──────────────────>
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 13: Zero values

pr()

oPlot = new stzHBarPlot([ :Zero = 0, :Positive = 5, :AnotherZero = 0 ])
oPlot.Show()
#-->
'
            ^                   
       Zero │                   
   Positive │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
Anotherzero │                   
            ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 14: Single bar

pr()

oPlot = new stzHBarPlot([ :Single = 10 ])
oPlot.Show()
#-->
'
       ^                   
Single │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
       ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 15: Large values with scaling

pr()

oPlot = new stzHBarPlot([ :Small = 1, :Large = 1000 ])
oPlot.Show()
#-->
'
      ^                   
Small │ ▇                 
Large │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
      ╰──────────────────>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

#--------------------------------------------#
#  TEST SUITE FOR THE MULTI-BAR CHART CLASS  #
#--------------------------------------------#

/*--- Using the short form StzCharQ()

pr()

StzPlotQ(:MultiBar, [
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 16 ]
])

.Show()

#-->
'
↑                      
│    ▒▒                
│    ▒▒                
│    ▒▒                
│ ██ ▒▒     ▒▒         
│ ██ ▒▒     ▒▒         
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
╰─────────────────────>
  2020   2022   2024   
                       
██ Mali   ▒▒ Niger     
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 1: Basic Multi-Series Plot (same as previous sample but with new stz...)

oPlot = new stzMultiBarPlot([
	:Mali = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger = [ :2020 = 87, :2022 = 40, :2024 = 12 ]
])

oPlot.Show()
'
↑                      
│    ▒▒                
│    ▒▒                
│    ▒▒                
│ ██ ▒▒     ▒▒         
│ ██ ▒▒     ▒▒         
│ ██ ▒▒  ██ ▒▒  ██     
│ ██ ▒▒  ██ ▒▒  ██ ▒▒  
╰─────────────────────>
  2020   2022   2024   
                       
██ Mali   ▒▒ Niger     
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 2: Customized Bar Width and Spacing

oPlot = new stzMultiBarPlot([
  :Sales = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=14 ]
])

oPlot {

	# Default display
	SetInterBarSpace(0)
	Show()
	? ""

	# Personalsed display
	SetBarWidth(1)
	SetSeriesSpace(1)
	SetCategorySpace(3)
	SetLegend(FALSE)

	Show()
}
#-->
'
↑                                 
│         ██              ██      
│         ██      ██      ██      
│ ██      ██      ██      ██      
│ ██      ██▒▒    ██▒▒    ██▒▒    
│ ██▒▒    ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
│ ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  ██▒▒▓▓  
╰────────────────────────────────>
    Q1      Q2      Q3      Q4    

↑                                
│         █               █      
│         █       █       █      
│ █       █       █       █      
│ █       █ ▒     █ ▒     █ ▒    
│ █ ▒     █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
│ █ ▒ ▓   █ ▒ ▓   █ ▒ ▓   █ ▒ ▓  
╰───────────────────────────────>
   Q1      Q2      Q3      Q4    
'
pf()
# # Executed in 0.08 second(s) in Ring 1.22

/*---

pr()

# Test 2: Customized Bar Width and Spacing

oPlot = new stzMultiBarPlot([
  :Sales = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
  :Costs = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
  :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=14 ]
])

oPlot {
	# A clean simple value-enabled chart
	SetBarWidth(1)
	SetBarSpace(2) # Or SetSeriesSpace()
	SetCategorySpace(5)

	AddValues()
	SetLegend(FALSE)
	Show()

	# An elaborated %-enabled chart
	SetBarWidth(3)
//	SetSeriesSpace(2)
//	SetCategorySpace(5)

	AddPercent()
	SetLegend(TRUE)
	Show()
}


#-->
'
↑                                              
│            35                      40        
│             █          30           █        
│25           █           █           █        
│ █           █ 20        █ 18        █ 22     
│ █ 15        █  ▒ 15     █  ▒ 12     █  ▒ 14  
│ █  ▒ 10     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
╰─────────────────────────────────────────────>
    Q1          Q2          Q3          Q4     
                                
↑                                                                      
│                  13.7%                               15.6%           
│                   ███              11.7%              ███            
│9.8%               ███               ███               ███            
│ ███               ███ 7.8%          ███ 7.0%          ███ 8.6%       
│ ███ 5.9%          ███  ▒▒▒ 5.9%     ███  ▒▒▒ 4.7%     ███  ▒▒▒ 5.5%  
│ ███  ▒▒▒ 3.9%     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
│ ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
│ ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓     ███  ▒▒▒  ▓▓▓  
╰─────────────────────────────────────────────────────────────────────>
       Q1                Q2                Q3                Q4        

██ Sales   ▒▒ Costs   ▓▓ Profit 
'
pf()
# Executed in 0.51 second(s) in Ring 1.22

/*---

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
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 4: With Values Display

oPlot = new stzMultiBarPlot([
	:Product1 = [ :Store1 = 12, :Store2 = 18, :Store3 = 15 ],
	:Product2 = [ :Store1 = 20, :Store2 = 14, :Store3 = 22 ]
])

oPlot {
	SetValues(True)
	SetBarWidth(2)
	Show()
}
#-->
'
↑                          
│    20              22    
│    ▒▒   18         ▒▒    
│    ▒▒   ██ 14   15 ▒▒    
│ 12 ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
│ ██ ▒▒   ██ ▒▒   ██ ▒▒    
╰─────────────────────────>
  Store1  Store2  Store3   
                           
██ Product1   ▒▒ Product2  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 5: With Percentage Display

oPlot = new stzMultiBarPlot([
	:Desktop = [ :2021 = 65, :2022 = 58, :2023 = 52 ],
	:Mobile = [ :2021 = 35, :2022 = 42, :2023 = 48 ]
])

oPlot {
	SetPercent(True)
	SetBarWidth(1)
	Show()
}
#--> #TODO: better automatic spacing
'
↑                       
│21.7%  19.3%           
│  █      █    1716.0%  
│  █      14.0%  █ ▒    
│  11.7%  █ ▒    █ ▒    
│  █ ▒    █ ▒    █ ▒    
│  █ ▒    █ ▒    █ ▒    
│  █ ▒    █ ▒    █ ▒    
│  █ ▒    █ ▒    █ ▒    
╰──────────────────────>
  2021   2022   2023    
                        
██ Desktop   ▒▒ Mobile  
'

pf()
# Executed in 0.24 second(s) in Ring 1.22

/*---

pr()

# Test 6: Hide/Show Axes and Labels

oPlot = new stzMultiBarPlot([
	:North = [ :Spring = 30, :Summer = 40, :Fall = 25, :Winter = 20 ],
	:South = [ :Spring = 35, :Summer = 50, :Fall = 36, :Winter = 25 ]
])

# With full display

oPlot {
	SetHAxis(True)
	SetVAxis(True)  
	SetLabels(True)
	SetLegend(True)
	Show()
}
#-->
'
↑                                
│            ▒▒                  
│         ██ ▒▒      ▒▒          
│ ██ ▒▒   ██ ▒▒      ▒▒          
│ ██ ▒▒   ██ ▒▒   ██ ▒▒     ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
│ ██ ▒▒   ██ ▒▒   ██ ▒▒  ██ ▒▒   
╰───────────────────────────────>
  Spring  Summer  Fall   Winter  
                                 
██ North   ▒▒ South   
'

? ""

# Same chart with minimal display

oPlot {
	SetHAxis(False)
	SetVAxis(False)
	SetLabels(False)
	SetLegend(False)
	Show()
}
#-->
'
          ▒▒                
       ██ ▒▒     ▒▒         
██ ▒▒  ██ ▒▒     ▒▒         
██ ▒▒  ██ ▒▒  ██ ▒▒     ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
██ ▒▒  ██ ▒▒  ██ ▒▒  ██ ▒▒  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 7: Compact Multi-Series

oPlot = new stzMultiBarPlot([
	:A = [ :X = 8, :Y = 12, :Z = 6 ],
	:B = [ :X = 15, :Y = 9, :Z = 18 ],
	:C = [ :X = 11, :Y = 16, :Z = 13 ]
])

oPlot {
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(1)
	SetHeight(3)
	SetMaxWidth(50)
	Show()
}
#-->
'
↑                   
│  ▒    ▓  ▒▓       
│ █▒▓ █▒▓  ▒▓       
│ █▒▓ █▒▓ █▒▓       
╰──────────────────>
   X   Y   Z        
                    
██ A   ▒▒ B   ▓▓ C  
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*---

pr()

# Test 8: Large Dataset with Custom Characters

oPlot = new stzMultiBarPlot([
	:Region1 = [ :Mon = 23, :Tue = 31, :Wed = 28, :Thu = 35, :Fri = 42 ],
	:Region2 = [ :Mon = 18, :Tue = 25, :Wed = 33, :Thu = 29, :Fri = 38 ],
	:Region3 = [ :Mon = 31, :Tue = 27, :Wed = 24, :Thu = 41, :Fri = 36 ],
	:Region4 = [ :Mon = 26, :Tue = 39, :Wed = 31, :Thu = 33, :Fri = 28 ]
])

oPlot {
	SetSeriesChars(["█", "▓", "▒", "░"])
	SetBarWidth(1)
	SetSeriesSpace(0)
	SetCategorySpace(2)
	Show()
}
#--> #TODO HAxis very long!
'
↑                                                  
│          ░          ▒   █▓                       
│   ▒   █  ░   ▓ ░  █ ▒░  █▓▒                      
│   ▒░  █▓▒░  █▓ ░  █▓▒░  █▓▒░                     
│ █ ▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
│ █▓▒░  █▓▒░  █▓▒░  █▓▒░  █▓▒░                     
╰─────────────────────────────────────────────────>
  Mon   Tue   Wed   Thu   Fri                      
                                                   
██ Region1   ▓▓ Region2   ▒▒ Region3   ░░ Region4  
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*---

pr()

# Test 9: Two Series Comparison

oPlot = new stzMultiBarPlot([
	:Before = [ :Feature1 = 45, :Feature2 = 38, :Feature3 = 52, :Feature4 = 29 ],
	:After = [ :Feature1 = 62, :Feature2 = 48, :Feature3 = 59, :Feature4 = 41 ]
])

oPlot {
	SetSeriesChars(["▒", "█"])
	SetBarWidth(2)
	SetSeriesSpace(1)
	AddLabels()
	Show()
}
#-->
'
↑                                         
│     ██                  ██              
│  ▒▒ ██        ██     ▒▒ ██              
│  ▒▒ ██     ▒▒ ██     ▒▒ ██        ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
│  ▒▒ ██     ▒▒ ██     ▒▒ ██     ▒▒ ██    
╰────────────────────────────────────────>
  Feature1  Feature2  Feature3  Feature4  
                                          
▒▒ Before   ██ After         
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*---

pr()

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
# Executed in 0.38 second(s) in Ring 1.22

/*====

// Setting the legend layout to :Vertical
pr()

oPlot = new stzMultiBarPlot([
	:Desktop = [ :Q1 = 45, :Q2 = 42 ],
	:Mobile =  [ :Q1 = 35, :Q2 = 88 ],
	:Tablet =  [ :Q1 = 15, :Q2 = 18 ]
])

oPlot {
	SetBarsChars([ "█", "|", "X" ])
	SetBarWidth(3)
	SetBarInterSpace(1)
	SetCategorySpace(3)

	AddValues()
	SetLegendLayout(:Vertical)

	Show()
	SetLegend(False)

}
#-->
'
↑                            
│                   88       
│                   |||      
│                   |||      
│ 45            42  |||      
│ ███ 35        ███ |||      
│ ███ ||| 15    ███ ||| 18   
│ ███ ||| XXX   ███ ||| XXX  
│ ███ ||| XXX   ███ ||| XXX  
╰───────────────────────────>
      Q1            Q2       
                             
██ Desktop                   
|| Mobile                    
XX Tablet   
'
pf()
#--> Executed in 0.05 second(s) in Ring 1.22


#--------------------------------------#
#  TEST SAMPLE OF THE HISTOGRAM CHART  #
#--------------------------------------#


/*--- Basic histogram with student test scores

pr()

aScores = [
	85, 92, 78, 88, 95, 82, 90,
	87, 93, 86, 79, 91, 84, 89,
	96, 83, 88, 92, 87, 85
]

oPlot = new stzHistogram(aScores)
oPlot {

	# ? @@(AggregationTypes())
	#--> [ "frequency", "sum", "average", "min", "max" ]

	# SetBinCount(5) # Or SetClassCount(5)
	# ~> Auto-calculate bin count using Sturges' rule
	# if not set

	UseFrequency()
	AddPercent()

    Show()
}
#-->
'
^                                          
│                       25%                
│                20%    ██     20%         
│                ██     ██     ██     15%  
│  10%    10%    ██     ██     ██     ██   
│  ██     ██     ██     ██     ██     ██   
│  ██     ██     ██     ██     ██     ██   
╰──────────────────────────────────────────>
   78     81     84     87     90     93   
   81     84     87     90     93     96  
'

pf()
# Executed in 0.48 second(s) in Ring 1.22

/*--- Histogram with frequency display and statistics

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

pf()
# Executed in 0.56 second(s) in Ring 1.22

/*--- Histogram with percentage display
*/
pr()

aSalaries = [
	45000, 52000, 48000, 67000, 55000,
	49000, 58000, 62000, 51000, 46000,
	59000, 53000, 47000, 61000, 56000,
	50000, 54000, 48000, 60000, 57000
]

oPlot = new stzHistogram(aSalaries)
oPlot {
    SetClassCount(6) # Or SetBinCount(6)
    AddPercent()

    SetBarChar("▓")
    Show()
}
#-->
'
^                                                      
│   25%                                                
│   ▓▓       20%               20%                     
│   ▓▓       ▓▓       15%      ▓▓       15%            
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓             
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓       5%    
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓       ▓▓    
╰──────────────────────────────────────────────────────>
   45.0K    48.7K    52.3K    56.0K    59.7K    63.3K  
   48.7K    52.3K    56.0K    59.7K    63.3K    67.0K  
'
# Note how Softanza transforms thousands to Ks for better radability

pf()
# Executed in 0.95 second(s) in Ring 1.22

/*--- Simple histogram without axes

pr()

aAges = [
	25, 34, 45, 28, 37, 42, 31,
	39, 33, 46, 29, 38, 41, 35,
	27, 44, 36, 32, 40, 43
]

oPlot = new stzHistogram(aAges)
oPlot {

    SetBinCount(4)
	UseFrequency()
	IncludeValues()

    WithoutXAxis()
    WithoutYAxis()
    SetBarChar("■")
    SetBarWidth(4)

    Show()
}
#-->
'
                    6   
        5     5    ■■■■ 
  4    ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
 ■■■■  ■■■■  ■■■■  ■■■■ 
                        
  25    30    36    41  
  30    36    41    46   
'
pf()
# Executed in 0.54 second(s) in Ring 1.22

/*--- Compact histogram with custom bin width

pr()

aWeights = [
	150, 155, 160, 152, 158, 162, 165,
	159, 157, 161, 163, 156, 154, 164,
	166, 153, 151, 167, 168, 149
]

oPlot = new stzHistogram(aWeights)
oPlot {

	UseSum()
	AddValues()

    SetBarWidth(3)
    SetBarInterSpace(1)
	SetLabelInterSpace(0)

    Show()
}
#-->
'
^
│  602                           666  
│  ███                           ███  
│  ███   462   471   480   489   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
│  ███   ███   ███   ███   ███   ███  
╰─────────────────────────────────────>
   149   152   155   158   162   165  
   152   155   158   162   165   168  
'

pf()
# Executed in 0.60 second(s) in Ring 1.22

#==============================#
#  TEST OF Surface CHART CLASS  #
#==============================#

/*--- Basic 4-item test with percentages

pr()

oPlot = new stzSurfacePlot([
    :Sales = 45,
    :Marketing = 25, 
    :Dev = 20,
    :Support = 10
])

oPlot.AddPercent().AddLegend().AddValues().Show()
'
╭──────────────────────────┬───────────╮
│                          │           │
│          Sales           │   Dev     │
│        45 (45%)          │ 20 (20%)  │
│                          │           │
│                          │           │
│                          │           │
├──────────────────────────┼───────────┤
│        Marketing         │ Support   │
│        25 (25%)          │ 10 (10%)  │
│                          │           │
╰──────────────────────────┴───────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*--- 2-item comparison test

pr()

oPlot2 = new stzSurfacePlot([
    :Desktop = 75,
    :Mobile = 25
])
oPlot2.AddPercent().Show()
#-->
'
╭────────────────────────────┬─────────╮
│                            │         │
│                            │         │
│                            │         │
│                            │         │
│          Desktop           │ Mobile  │
│            75%             │  25%    │
│                            │         │
│                            │         │
│                            │         │
│                            │         │
╰────────────────────────────┴─────────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- 3-item test with values and percentages

pr()

oPlot3 = new stzSurfacePlot([
    :Frontend = 60,
    :Backend = 30,
    :DevOps = 10
])
oPlot3.AddValues().AddPercent().Show()
#-->
'
╭──────────────────────┬───────────────╮
│                      │               │
│                      │               │
│                      │   Backend     │
│                      │   30 (30%)    │
│      Frontend        │               │
│      60 (60%)        │               │
│                      │               │
│                      ├───────────────┤
│                      │   10 (10%)    │
│                      │               │
╰──────────────────────┴───────────────╯
'

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- 5-item test (recursive division)

pr()

oPlot4 = new stzSurfacePlot([
    :A = 40,
    :B = 25,
    :C = 15,
    :D = 12,
    :E = 8
])
oPlot4.AddPercent().Show()
#--> 
'
╭──────────────┬─────────┬─────┬───────╮
│              │         │     │       │
│              │         │     │  D    │
│              │         │     │ 12%   │
│              │         │     │       │
│      A       │   B     │ C   │       │
│     40%      │  25%    │15%  │       │
│              │         │     ├───────┤
│              │         │     │  E    │
│              │         │     │  8%   │
│              │         │     │       │
╰──────────────┴─────────┴─────┴───────╯
'

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Large dataset (6 items)

pr()

oPlot5 = new stzSurfacePlot([
    :North = 35,
    :South = 30,
    :East = 28,
    :West = 18,
    :Center = 30,
    :Remote = 10
])
oPlot5.AddPercent().Show()
#-->
'
╭────────┬──────────────┬──────┬───────╮
│        │              │      │       │
│        │   South      │      │ West  │
│        │   19.9%      │      │11.9%  │
│        │              │      │       │
│ North  │              │East  │       │
│ 23.2%  ├──────────────┤8.5%  │       │
│        │   Center     │      ├───────┤
│        │   19.9%      │      │Remote │
│        │              │      │ 6.6%  │
│        │              │      │       │
╰────────┴──────────────┴──────┴───────╯
'

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Equal values test

pr()

oPlot6 = new stzSurfacePlot([
    :Q1 = 25,
    :Q2 = 25,
    :Q3 = 25,
    :Q4 = 25
])
oPlot6 {
	AddPercent()
	Show()
}
#-->
'
╭───────────────────┬──────────────────╮
│                   │                  │
│        Q1         │       Q3         │
│       25%         │       25%        │
│                   │                  │
│                   │                  │
├───────────────────┼──────────────────┤
│        Q2         │       Q4         │
│       25%         │       25%        │
│                   │                  │
│                   │                  │
╰───────────────────┴──────────────────╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Custom size test

pr()

oPlot7 = new stzSurfacePlot([
    :Red = 50,
    :Blue = 30,
    :Green = 20
])
oPlot7.SetSize(60, 16).AddPercent().Show()
#-->
'
╭─────────────────────────────┬────────────────────────────╮
│                             │                            │
│                             │                            │
│                             │           Blue             │
│                             │            30%             │
│                             │                            │
│                             │                            │
│            Red              │                            │
│            50%              │                            │
│                             ├────────────────────────────┤
│                             │                            │
│                             │           Green            │
│                             │            20%             │
│                             │                            │
│                             │                            │
╰─────────────────────────────┴────────────────────────────╯
'
pf()
# Executed in 0.05 second(s) in Ring 1.22

/*--- Values only (no percentages)

pr()

oPlot9 = new stzSurfacePlot([
    :Server1 = 120,
    :Server2 = 80,
    :Server3 = 45,
    :Server4 = 35
])
oPlot9.AddValues().Show()
#-->
'
╭───────────────────────────┬──────────╮
│                           │          │
│         Server1           │ Server3  │
│           120             │   45     │
│                           │          │
│                           │          │
│                           ├──────────┤
├───────────────────────────│ Server4  │
│         Server2           │   35     │
│            80             │          │
│                           │          │
╰───────────────────────────┴──────────╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Single item test

pr()

oPlot10 = new stzSurfacePlot([
    :Total = 100
])
oPlot10.AddPercent().Show()
#-->
'
╭──────────────────────────────────────╮
│                                      │
│                                      │
│                                      │
│                                      │
│                Total                 │
│                 100%                 │
│                                      │
│                                      │
│                                      │
│                                      │
╰──────────────────────────────────────╯
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Large numbers test

pr()

oPlot11 = new stzSurfacePlot([
    :Revenue = 2500000,
    :Costs = 1800000,
    :Profit = 700000
])
oPlot11.AddValues().AddPercent().Show()
#-->
'
╭───────────────────┬──────────────────╮
│                   │                  │
│                   │                  │
│                   │      Costs       │
│                   │  1800000 (36%)   │
│     Revenue       │                  │
│  2500000 (50%)    │                  │
│                   │                  │
│                   ├──────────────────┤
│                   │  700000 (14%)    │
│                   │                  │
╰───────────────────┴──────────────────╯
'

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- 8-item complex test

pr()

oPlot12 = new stzSurfacePlot([
    :Chrome = 65,
    :Safari = 19,
    :Edge = 8,
    :Firefox = 4,
    :Opera = 2,
    :Samsung = 1,
    :UCBrowser = 0.5,
    :Others = 0.5
])
oPlot12.AddPercent().SetSize(80, 20).Show()
#-->
'
╭────────────────────────────────────────────────────────────────┬─────────┬─┬─╮
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │ Edge    │ │ │
│                            Chrome                              │  8%     │ │ │
│                              65%                               │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
│                                                                ├─────────┤ │ │
├────────────────────────────────────────────────────────────────┤         ├─┼─┤
│                            Safari                              │Firefox  │ │ │
│                              19%                               │  4%     │ │ │
│                                                                │         │ │ │
│                                                                │         │ │ │
╰────────────────────────────────────────────────────────────────┴─────────┴─┴─╯
'
pf()
# Executed in 0.09 second(s) in Ring 1.22


#----------------------------------#
# Test Suite for stzScatterPlot   #
#----------------------------------#

/*--- Test 1: Basic scatter plot with coordinate pairs

pr()

oPlot = new stzScatterPlot([
	[1,2], [3,5], [6,9], [5,4], [7,8], [9,6]
])

oPlot.Show()
#-->
'
   X
   ▲
   │                                      
 9 ┤                     ●                
   │                                      
 8 ┤                          ●           
   │                                      
 6 ┤                                   ●  
 5 ┤        ●                             
 4 ┤                 ●                    
   │                                      
 2 ┤●                                     
   ╰┬───────┬────────┬───┬────┬────────┬──► Y 
    1       3        5   6    7        9  
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Test 2: Named data points with labels

pr()

oPlot = new stzScatterPlot([ 
	:Ali = [10, 25], 
	:Ben = [15, 30], 
	:Tom = [20, 22], 
	:Maiga = [25, 35] 
])
oPlot.AddGrid()
oPlot.AddLabels()

oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 35 ┼----------------------------● Maiga  
    │                            ⁞        
    │                            ⁞        
    │                            ⁞        
 30 ┼---------● Ben              ⁞        
    │         ⁞                  ⁞        
    │         ⁞                  ⁞        
 25 ┼● Ali    ⁞                  ⁞        
 22 ┼⁞--------⁞--------● Tom     ⁞        
    ╰┼────────┼────────┼─────────┼──► Y       
    10       15       20        25       
'

pf()
# Executed in 0.04 second(s) in Ring 1.22


/*--- Test 4: X,Y array format with coordinate values

pr()

oPlot = new stzScatterPlot([[:X, [1,3,5,7]], [:Y, [2,6,4,8]]])

oPlot.AddLabels()
oPlot.Show()
#-->
'
   X
   ▲
   │                                      
 8 ┤                                ● P4  
   │                                      
   │                                      
 6 ┤          ● P2                        
   │                                      
   │                                      
 4 ┤                     ● P3             
   │                                      
 2 ┤● P1                                  
   ╰┬─────────┬──────────┬──────────┬──► Y    
    1         3          5          7     
'


pf()
# Executed in 0.03 second(s) in Ring 1.22


/*--- Test 6: Clean plot without axes

pr()

oPlot = new stzScatterPlot([
	[1,1], [2, 5], [2,4], [3,2], [3, 4], [4,5], [4,6], [5,3]
])
oPlot.WithoutVHAxis()
oPlot.Show()
#-->
'
                             ●            
                                          
         ●                   ●            
                                          
         ●         ●                      
                                          
                                       ●  
                                          
                   ●                      
                                          
●                
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

o1 = new stzListOfPairs([

	[1,12], [1,14], [1,16], [1,18], [1,20],
	[1,22], [1,24], [1,26], [1,30]
])

o1.ReversePairs()
? @@(o1.Content())
#--> [ [ 12, 1 ], [ 14, 1 ], [ 16, 1 ], [ 18, 1 ], [ 20, 1 ], [ 22, 1 ], [ 24, 1 ], [ 26, 1 ], [ 30, 1 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- In the Name of Allah

pr()

oPlot = new stzScatterPlot([

	[ 12, 1 ], [ 14, 1 ], [ 16, 1 ], [ 18, 1 ], [ 20, 1 ],
	[ 22, 1 ], [ 24, 1 ], [ 26, 1 ], [ 30, 1 ],

	[ 11, 2 ], [ 19, 2 ], [ 27, 2 ], [30, 2],

	[ 3, 3 ], [ 5, 3 ], [ 7, 3 ], [ 9, 3 ], [ 11, 3 ], [ 19, 3 ], [ 27, 3 ], [ 30, 3 ],

	[ 3, 4 ], [ 11, 4 ], [ 19, 4 ], [ 27, 4 ], [ 30, 4 ],

	[ 5, 5 ], [ 7, 5 ], [ 9, 5 ], [ 11, 5 ], [ 19, 5 ], [ 27, 5 ], [ 30, 5 ],
	[ 11, 6 ], [ 19, 6 ], [ 27, 6 ], [ 30, 6 ],

	[ 19, 7 ], [ 27, 7 ], [ 30, 7 ],

	[ 19, 8 ], [ 27, 8 ], [ 30, 8 ],

	[ 15, 10 ], [ 17, 10 ], [ 19, 10 ], [ 21, 10 ], [ 23, 10 ],

	[ 15, 11 ], [ 19, 11 ], [ 23, 11 ]
])

oPlot.WithoutXYAxis()
oPlot.Show()

'                                    
                 ●     ●    ●             
                 ●  ●  ●  ● ●             
                                          
                       ●          ●    ●  
                       ●          ●    ●  
           ●           ●          ●    ●  
  ●  ●  ●  ●           ●          ●    ●  
●          ●           ●          ●    ●  
● ●  ●  ●  ●           ●          ●    ●  
           ●           ●          ●    ●  
             ● ●  ●  ●  ●  ●  ●  ●     ●  
'
pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test 7: Performance data visualization

pr()

oPlot = new stzScatterPlot([
	:Week1 = [100, 85],
	:Week2 = [120, 90], 
	:Week3 = [110, 88],
	:Week4 = [140, 95]
])
oPlot.AddLabels()

oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 95 ┤                            ● Week4  
    │                                     
    │                                     
    │                                     
 90 ┤              ● Week2                
    │                                     
 88 ┤       ● Week3                       
    │                                     
 85 ┤● Week1                              
    ╰┬──────┬──────┬─────────────┬──► Y       
    100    110    120           140         
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*===

pr()

str = "    ╰┬──┬─────┬──────┬─────┬───────┬►     "
? @trimend(str)
#--> "    ╰┬──┬─────┬──────┬─────┬───────┬►"

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 8: Temperature correlation study

pr()

aData = [
	[ :Jan, [5, 32] ],
	[ :Feb, [8, 35] ],
	[ :Mar, [12, 50] ], 
	[ :Apr, [18, 64] ],
	[ :May, [22, 72] ],
	[ :Jun, [28, 82] ]
]

oPlot = new stzScatterPlot(aData)
oPlot.AddLabels()
oPlot.Show()
#-->
'
    X
    ▲
    │                                     
 82 ┤                              ● Jun  
    │                                     
 72 ┤                      ● May          
 64 ┤                ● Apr                
    │                                     
    │                                     
 50 ┤         ● Mar                       
    │                                     
 35 ┤● Ja Feb                             
    ╰┬──┬─────┬──────┬─────┬───────┬──► Y     
     5  8    12     18    22      28                                         
'

pf()
# Executed in 0.05 second(s) in Ring 1.22


