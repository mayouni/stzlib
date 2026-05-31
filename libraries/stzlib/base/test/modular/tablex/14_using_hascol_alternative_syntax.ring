# Narrative
# --------
# Using hascol (alternative syntax)
#
# Extracted from stztablextest.ring, block #14.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

? oTable.HasCol("name") #--> TRUE

oTx = new stzTablex("{hascol(name) & hascol(age)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.24

#--------------------------#
#  DATA CONTENT TESTS      #
#--------------------------#
