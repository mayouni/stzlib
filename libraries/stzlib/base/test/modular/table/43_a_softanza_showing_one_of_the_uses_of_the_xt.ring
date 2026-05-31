# Narrative
# --------
# A Softanza #narration showing one of the uses of the XT()
#
# Extracted from stztabletest.ring, block #43.

load "../../../stzBase.ring"


pr()

# You create a table with this structure:

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

# And you want to show it on screen:

? o1.Show() + NL

#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#        *       *       *
#       30     300    3000

# That's fine! But you may want a more elaborated formatting!
# Use the XT() extension:

? o1.ShowXT([]) + NL

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |   10 |  100 | 1000
#    2 |   20 |  200 | 2000
#    3 |    * |    * |    *
#    4 |   30 |  300 | 3000

# You can even even set the options at your will...

? o1.ShowXT([
	:Separator 	  = " | ",
	:Alignment 	  = :Center,

	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = "+",

	:ShowRowNumbers   = TRUE
])

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |  10  | 100  | 1000
#    2 |  20  | 200  | 2000
#    3 |  *   |  *   |  *  
#    4 |  30  | 300  | 3000

pf()
# Executed in 0.20 seconds(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17
