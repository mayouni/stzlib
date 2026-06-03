# Narrative
# --------
# Case-sensitive contains
#
# Extracted from stztablextest.ring, block #16.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "ali", 28 ],
	[ "ALI", 32 ]
])

# Case-insensitive (matches both)
oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (no exact "Ali")
oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.Match(oTable)
#--> FALSE

# Add exact match
oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "Ali", 28 ]
])

? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.20 second(s) in Ring 1.24
