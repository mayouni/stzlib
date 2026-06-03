# Narrative
# --------
# Explaining matches
#
# Extracted from stztablextest.ring, block #43.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

oTx = new stzTablex("{cols(3) & rows(2)}")
oTx.Match(oTable)

aExplain = oTx.Explain()
? @@(aExplain[1])
#--> ["Pattern","{cols(3) & rows(2)}"]

? @@(aExplain[2])
#--> ["TokenCount",1]

pf()
# Executed in 0.06 second(s) in Ring 1.24
