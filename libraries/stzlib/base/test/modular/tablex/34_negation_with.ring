# Narrative
# --------
# Negation with @!
#
# Extracted from stztablextest.ring, block #34.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME ],
	[ 1, "Ali" ],
	[ 2, "Sara" ],
	[ 3, "Omar" ]
])

oTx = new stzTablex("{@!duplicates(id) & @!nulls(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.12 second(s) in Ring 1.24
