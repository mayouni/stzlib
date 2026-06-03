# Narrative
# --------
# Multiple type constraints
#
# Extracted from stztablextest.ring, block #21.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :TAGS ],
	[ 1, "Ali", ["dev", "lead"] ],
	[ 2, "Sara", ["hr", "manager"] ]
])

oTx = new stzTablex("{coltype(id:number) & coltype(name:string) & coltype(tags:list)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.17 second(s) in Ring 1.24

#--------------------------#
#  NUMERIC COLUMN TESTS    #
#--------------------------#
