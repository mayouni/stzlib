# Narrative
# --------
# Completeness percentage
#
# Extracted from stztablextest.ring, block #28.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :NAME, :PHONE ],
	[ "Ali", "123456" ],
	[ "Sara", "789012" ],
	[ "Omar", "345678" ],
	[ "Fatma", "" ]  # Missing phone
])

# 75% complete (3 out of 4)
oTx = new stzTablex("{completeness(phone:75)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{completeness(phone:90)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.17 second(s) in Ring 1.24
