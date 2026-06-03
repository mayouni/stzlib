# Narrative
# --------
# Checking if column is numeric
#
# Extracted from stztablextest.ring, block #22.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE, :SALARY ],
	[ "Ali", 28, 45000 ],
	[ "Sara", 32, 52000 ]
])

oTx = new stzTablex("{numeric(age)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{numeric(name)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.16 second(s) in Ring 1.24
