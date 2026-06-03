# Narrative
# --------
# AND operator for multiple constraints
#
# Extracted from stztablextest.ring, block #32.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ],
	[ 3, "Omar", 45 ]
])

oTx = new stzTablex("{cols(3) & rows(3) & unique(id) & numeric(age)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.19 second(s) in Ring 1.24
