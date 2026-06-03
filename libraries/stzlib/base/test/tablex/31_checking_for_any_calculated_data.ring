# Narrative
# --------
# Checking for any calculated data
#
# Extracted from stztablextest.ring, block #31.
#ERR Error (R14) : Calling Method without definition: findcalculatedrows

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :A, :B ],
	[ 1, 2 ],
	[ 3, 4 ]
])

oTx = new stzTablex("{aggregated()}")
? oTx.Match(oTable)
#--> FALSE

oTable.AddCalculatedCol(:SUM, '@(:A) + @(:B)')

? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.09 second(s) in Ring 1.24

#--------------------------#
#  LOGICAL COMBINATIONS    #
#--------------------------#
