# Narrative
# --------
# Checking for null values
#
# Extracted from stztablextest.ring, block #27.

load "../../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME, :EMAIL ],
	[ "Ali", "ali@mail.com" ],
	[ "Sara", "" ]  # Empty email
])

oTable2 = new stzTable([
	[ :NAME, :EMAIL ],
	[ "Ali", "ali@mail.com" ],
	[ "Sara", "sara@mail.com" ]
])

oTx = new stzTablex("{nulls(email)}")
? oTx.Match(oTable1)
#--> TRUE

? oTx.Match(oTable2)
#--> FALSE

pf()
# Executed in 0.09 second(s) in Ring 1.24
