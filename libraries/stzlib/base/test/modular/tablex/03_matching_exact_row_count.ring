# Narrative
# --------
# Matching exact row count
#
# Extracted from stztablextest.ring, block #3.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "Ali", 28 ],
	[ "Sara", 32 ],
	[ "Omar", 45 ]
])

oTx = new stzTablex("{rows(3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{rows(>2)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.24
