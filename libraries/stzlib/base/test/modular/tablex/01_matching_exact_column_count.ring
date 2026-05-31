# Narrative
# --------
# Matching exact column count
#
# Extracted from stztablextest.ring, block #1.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Ali", 28, "Teacher" ],
	[ "Sara", 32, "Engineer" ]
])

oTx = new stzTablex("{cols(3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(4)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.06 second(s) in Ring 1.24
