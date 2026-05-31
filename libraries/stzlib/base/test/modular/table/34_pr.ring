# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #34.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.Show()
#-->
#	NAME   AGE   SCORE
#	----- ----- ------
#	 sam    24      10
#	 dan    36      20
#	 tom    43      30

? ""

? @@( o1.FindColsExcept([ :NAME, :SCORE ]) )
#--> [ 2 ]

? ""

o1.RemoveCol(2)
o1.Show()
#--> :NAME   :SCORE
#    ------ -------
#    sam       10
#    dan       20
#    tom       30

? ""

o1.RemoveCols([ 1, 2 ])
o1.Show() + NL

#--> COL1
#    ----
#      ""

pf()
# Executed in 0.13 second(s)
