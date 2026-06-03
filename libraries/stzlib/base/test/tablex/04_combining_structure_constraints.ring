# Narrative
# --------
# Combining structure constraints
#
# Extracted from stztablextest.ring, block #4.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

oTx = new stzTablex("{cols(3) & rows(2)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(>2) & rows(<5)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.24

#--------------------------#
#  CASE SENSITIVITY TESTS  #
#--------------------------#
