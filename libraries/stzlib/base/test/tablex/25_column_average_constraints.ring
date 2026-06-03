# Narrative
# --------
# Column average constraints
#
# Extracted from stztablextest.ring, block #25.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :SCORE ],
	[ "Ali", 80 ],
	[ "Sara", 90 ],
	[ "Omar", 70 ]
])

oTx = new stzTablex("{avgcol(score:80)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{avgcol(score:>75)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.13 second(s) in Ring 1.24
