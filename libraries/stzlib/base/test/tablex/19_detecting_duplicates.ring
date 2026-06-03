# Narrative
# --------
# Detecting duplicates
#
# Extracted from stztablextest.ring, block #19.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :EMAIL, :NAME ],
	[ "ali@mail.com", "Ali" ],
	[ "sara@mail.com", "Sara" ],
	[ "ali@mail.com", "Ali B" ]
])

oTx = new stzTablex("{duplicates(email)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{@!duplicates(email)}")
? oTx.Match(oTable)
#--> FALSE (negated - we DO have duplicates)

pf()
# Executed in 0.12 second(s) in Ring 1.24

#--------------------------#
#  COLUMN TYPE TESTS       #
#--------------------------#
