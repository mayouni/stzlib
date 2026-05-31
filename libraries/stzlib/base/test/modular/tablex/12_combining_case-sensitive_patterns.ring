# Narrative
# --------
# Combining case-sensitive patterns
#
# Extracted from stztablextest.ring, block #12.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :EMAIL ],
	[ 1, "Ali", "ali@mail.com" ],
	[ 2, "Sara", "sara@mail.com" ],
	[ 3, "Omar", "omar@mail.com" ]
])

# Case-sensitive validation
oTx = new stzTablex("{@cs:unique(name) & @cs:contains(Ali) & @cs:sorted(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.17 second(s) in Ring 1.24

#--------------------------#
#  COLUMN EXISTENCE TESTS  #
#--------------------------#
