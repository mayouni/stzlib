# Narrative
# --------
# Case sensitivity in unique check
#
# Extracted from stztablextest.ring, block #7.

load "../../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "ali" ],
	[ "ALI" ]
])

# Case-insensitive (all are same)
oTx = new stzTablex("{unique(name)}")
? oTx.Match(oTable1)
#--> FALSE (duplicates when ignoring case)

# Case-sensitive (all different)
oTx = new stzTablex("{@cs:unique(name)}")
? oTx.Match(oTable1)
#--> TRUE (each is unique with case)

pf()
# Executed in 0.09 second(s) in Ring 1.24
