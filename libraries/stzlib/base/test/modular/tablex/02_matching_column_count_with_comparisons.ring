# Narrative
# --------
# Matching column count with comparisons
#
# Extracted from stztablextest.ring, block #2.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE, :SALARY, :DEPT ],
	[ 1, "Ali", 28, 45000, "IT" ],
	[ 2, "Sara", 32, 52000, "HR" ]
])

oTx = new stzTablex("{cols(>3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(<10)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.24
