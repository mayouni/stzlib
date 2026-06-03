# Narrative
# --------
# Checking unique columns
#
# Extracted from stztablextest.ring, block #18.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :DEPT ],
	[ 1, "Ali", "IT" ],
	[ 2, "Sara", "IT" ],
	[ 3, "Omar", "HR" ]
])

oTx = new stzTablex("{unique(id)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{unique(dept)}")
? oTx.Match(oTable)
#--> FALSE (IT appears twice)

pf()
# Executed in 0.13 second(s) in Ring 1.24
