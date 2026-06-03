# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #19.

load "../../stzBase.ring"

pr()

# WAY 3: Creating a table by provding a list of lists, formatted as you
# would find it in the real world (the first line is for column names!)

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
#   ID   EMPLOYEE   SALARY
#   --- ---------- -------
#   10        Ali    35000
#   20      Dania    28900
#   30        Han    25982
#   40        Ali    12870

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17
