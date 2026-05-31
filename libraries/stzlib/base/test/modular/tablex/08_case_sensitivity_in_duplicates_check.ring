# Narrative
# --------
# Case sensitivity in duplicates check
#
# Extracted from stztablextest.ring, block #8.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :EMAIL ],
	[ "Ali@mail.com" ],
	[ "ali@mail.com" ]
])

# Case-insensitive (same email)
oTx = new stzTablex("{duplicates(email)}")
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (different)
oTx = new stzTablex("{@cs:duplicates(email)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.10 second(s) in Ring 1.24
