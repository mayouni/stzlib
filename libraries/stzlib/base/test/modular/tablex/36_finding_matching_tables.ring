# Narrative
# --------
# Finding matching tables
#
# Extracted from stztablextest.ring, block #36.

load "../../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE ],
	[ "Omar", 45 ]
])

oTable3 = new stzTable([
	[ :NAME, :AGE, :COUNTRY ],
	[ "Fatma", 29, "Tunisia" ],
	[ "Dorra", 35, "France" ]
])

oTx = new stzTablex("{cols(3) & contains(Tunis)}")

# Only oTable1 matches (3 cols + contains Tunis)
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 1

pf()
# Executed in 0.15 second(s) in Ring 1.24
