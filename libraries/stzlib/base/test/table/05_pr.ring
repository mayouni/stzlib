# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #5.

load "../../stzBase.ring"


o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",        4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

? o1.IsSortedInAscending()
#--> FALSE

o1.SortInAscending()
o1.Show()
#-->
'
╭─────────┬────────┬────────────╮
│ Country │ Income │ Population │
├─────────┼────────┼────────────┤
│ China   │  18150 │    1430.10 │
│ Germany │   4490 │      83.30 │
│ India   │   3370 │    1430.20 │
│ Japan   │   5310 │     123.20 │
│ USA     │  25450 │     340.10 │
╰─────────┴────────┴────────────╯
'

? o1.IsSortedInAscending()
#--> TRUE

pf()
