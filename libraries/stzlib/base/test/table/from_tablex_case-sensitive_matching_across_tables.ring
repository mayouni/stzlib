# Narrative
# --------
# Case-sensitive matching across tables
#
# Extracted from stztablextest.ring, block #38.
#ERR Error (R14) : Calling Method without definition: containscellcs

load "../../stzBase.ring"


pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Ali", 28, "Teacher" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "ali", 32, "Engineer" ]
])

oTable3 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "ALI", 45, "Doctor" ]
])

# Case-insensitive
oTx = new stzTablex("{contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 3

# Case-sensitive
oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 1 (only exact "Ali")

pf()
# Executed in 0.27 second(s) in Ring 1.24

#--------------------------#
#  PATTERN COMBINATION     #
#--------------------------#
