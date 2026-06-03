# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #36.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveAll()
o1.Show()

#--> COL1
#    ----
#      ""

pf()
# Executed in 0.08 second(s)
