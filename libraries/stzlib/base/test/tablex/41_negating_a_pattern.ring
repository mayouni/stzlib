# Narrative
# --------
# Negating a pattern
#
# Extracted from stztablextest.ring, block #41.

load "../../stzBase.ring"


pr()

oTx1 = new stzTablex("{duplicates(email)}")
oTx2 = oTx1.Not_()

? oTx2.Pattern()
#--> {@!duplicates(email)}

oTable = new stzTable([
	[ :EMAIL ],
	[ "a@m.com" ],
	[ "b@m.com" ]
])

? oTx2.Match(oTable)
#--> TRUE (no duplicates)

pf()
# Executed in 0.11 second(s) in Ring 1.24

#-------------------------------#
#  DEBUGGING AND INTROSPECTION  #
#-------------------------------#
