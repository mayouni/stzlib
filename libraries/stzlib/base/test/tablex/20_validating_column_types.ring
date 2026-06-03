# Narrative
# --------
# Validating column types
#
# Extracted from stztablextest.ring, block #20.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE, :SALARY ],
	[ "Ali", 28, 45000 ],
	[ "Sara", 32, 52000 ]
])

oTx = new stzTablex("{coltype(age:number)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{coltype(name:string)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{coltype(name:number)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.11 second(s) in Ring 1.24
