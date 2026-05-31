# Narrative
# --------
# Combining contains with structure
#
# Extracted from stztablextest.ring, block #17.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

oTx = new stzTablex("{cols(>2) & contains(Tunis)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.15 second(s) in Ring 1.24

#--------------------------#
#  UNIQUENESS TESTS        #
#--------------------------#
