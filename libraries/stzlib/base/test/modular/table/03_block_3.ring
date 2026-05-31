# Narrative
# --------
# */
#
# Extracted from stztabletest.ring, block #3.

load "../../../stzBase.ring"

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

o2 = o1.Copy()
? o1.ColQ(1).IsEqualTo(o2.Col(1))
#--> TRUE

o2.Sort()
o2.Show()
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

o1.Show() # Original table unchanged
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

? o1.ColQ(1).IsEqualToXT(o2.Col(1))
#--> FALSE

pf()
