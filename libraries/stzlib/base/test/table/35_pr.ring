# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #35.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveCols([1, 2])
o1.Show()

#--> SCORE
#    -----
#       10
#       20
#       30

pf()
# Executed in 0.07 second(s)
