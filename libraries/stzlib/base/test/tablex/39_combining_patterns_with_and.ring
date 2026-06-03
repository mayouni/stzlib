# Narrative
# --------
# Combining patterns with And_()
#
# Extracted from stztablextest.ring, block #39.

load "../../stzBase.ring"


pr()

oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{unique(id)}")
oTx3 = oTx1.And_(oTx2)

? oTx3.Pattern()
#--> {cols(3) & unique(id)}

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

? oTx3.Match(oTable)
#--> TRUE

pf()
# Executed in 0.15 second(s) in Ring 1.24
