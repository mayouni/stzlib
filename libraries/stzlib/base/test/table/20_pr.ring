# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #20.

load "../../stzBase.ring"


# WAY 4: Creating a table by provding just the rows, without
# column names (they are added automatically by softanza):

o1 = new stzTable([
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
#   COL1    COL2    COL3
#   ----- ------- ------
#     10     Ali   35000
#     20   Dania   28900
#     30     Han   25982
#     40     Ali   12870

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17
