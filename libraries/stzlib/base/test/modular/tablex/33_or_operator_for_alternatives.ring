# Narrative
# --------
# OR operator for alternatives
#
# Extracted from stztablextest.ring, block #33.

load "../../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :A, :B, :C ],
	[ 1, 2, 3 ]
])

oTable2 = new stzTable([
	[ :A, :B, :C, :D ],
	[ 1, 2, 3, 4 ]
])

oTx = new stzTablex("{cols(3) | cols(4)}")
? oTx.Match(oTable1)
#--> TRUE

? oTx.Match(oTable2)
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.24
