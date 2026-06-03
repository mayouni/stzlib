# Narrative
# --------
# CHECKING IF TABLE IS SORTED
#
# Extracted from stztabletest.ring, block #1.

load "../../stzBase.ring"


pr()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",        4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

oCopy = o1.Copy()
oCopy.RemoveCol(1)
oCopy.Show()
#-->
'
╭────────┬────────────╮
│ Income │ Population │
├────────┼────────────┤
│  25450 │     340.10 │
│  18150 │    1430.10 │
│   5310 │     123.20 │
│   4490 │      83.30 │
│   3370 │    1430.20 │
╰────────┴────────────╯
'

? o1.Show() # Original table unchanged
#-->
'
╭─────────┬────────┬────────────╮
│ Country │ Income │ Population │
├─────────┼────────┼────────────┤
│ USA     │  25450 │     340.10 │
│ China   │  18150 │    1430.10 │
│ Japan   │   5310 │     123.20 │
│ Germany │   4490 │      83.30 │
│ India   │   3370 │    1430.20 │
╰─────────┴────────┴────────────╯
'
pf()
# Executed in 0.01 second(s) in Ring 1.26 (backed by StzEngine)
# Executed in 0.08 second(s) in Ring 1.24
