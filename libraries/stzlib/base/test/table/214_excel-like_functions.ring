# Narrative
# --------
# EXCEL-Like functions
#
# Extracted from stztabletest.ring, block #214.
#ERR Error (R14) : Calling Method without definition: kount

load "../../stzBase.ring"


pr()

o1 = new stzTable([

	[ "A", "B", "C" ],

	[  12,  10,   8 ],
	[  10,  14,  24 ],
	[   7,   4,   8 ]

])

? o1.KOUNT([ :A, 1 ], [ :C, 3 ]) # We use "K" because we have an other Count() method
#--> 9

? o1.SUM([ :A, 1 ], [ :C, 3 ])
#--> 97

? o1.AVERAGE([ :A, 1 ], [ :C, 3 ])
#--> 10.78

? o1.PRODUCT([ :A, 1 ], [ :C, 3 ])
#--> 722_534_400

? o1.MAX([ :A, 1 ], [ :C, 3 ])
#--> 24

? o1.MIN([ :A, 1 ], [ :C, 3 ])
#--> 4

pf()
# Executed in 0.13 second(s) in Ring 1.22
