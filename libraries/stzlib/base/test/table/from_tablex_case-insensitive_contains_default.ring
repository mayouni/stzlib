# Narrative
# --------
# Case-insensitive contains (default)
#
# Extracted from stztablextest.ring, block #5.
#ERR Error (R14) : Calling Method without definition: containscellcs

load "../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Hussein", 24, "Programmer" ],
	[ "ali", 28, "Teacher" ],
	[ "Omar", 44, "Farmer" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE ],
	[ "Hussein", 24 ],
	[ "Salem", 28 ]
])

oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable1)
#--> TRUE (matches "ali")

? oTx.Match(oTable2)
#--> FALSE

pf()
#◙ Executed in 0.10 second(s) in Ring 1.24
