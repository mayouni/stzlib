# Narrative
# --------
# Ensuring no nulls
#
# Extracted from stztablextest.ring, block #29.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :EMAIL ],
	[ 1, "Ali", "ali@mail.com" ],
	[ 2, "Sara", "sara@mail.com" ]
])

oTx = new stzTablex("{@!nulls(email) & @!nulls(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.15 second(s) in Ring 1.24

#--------------------------#
#  CALCULATED COLUMNS      #
#--------------------------#
