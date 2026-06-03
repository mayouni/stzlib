# Narrative
# --------
# Alphabetic column check
#
# Extracted from stztablextest.ring, block #23.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :CODE ],
	[ "Ali", "ABC" ],
	[ "Sara", "XYZ" ]
])

oTx = new stzTablex("{alphabetic(name)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{alphabetic(code)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.25 second(s) in Ring 1.24

#--------------------------#
#  STATISTICAL TESTS       #
#--------------------------#
