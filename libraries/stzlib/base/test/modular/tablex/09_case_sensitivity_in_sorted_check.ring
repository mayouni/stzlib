# Narrative
# --------
# Case sensitivity in sorted check
#
# Extracted from stztablextest.ring, block #9.

load "../../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "sara" ],
	[ "Ziad" ]
])

# Case-insensitive sort (a, s, z)
oTx = new stzTablex("{sorted(name)}")
? oTx.Match(oTable1)
#--> TRUE

oTable2 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "Ziad" ],
	[ "sara" ]
])

# Case-sensitive sort (A < Z < s in ASCII)
oTx = new stzTablex("{@cs:sorted(name)}")
? oTx.Match(oTable2)
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.24
