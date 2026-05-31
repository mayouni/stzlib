# Narrative
# --------
# Debug mode
#
# Extracted from stztablextest.ring, block #44.

load "../../../stzBase.ring"


pr()

oTx = new stzTablex("{cols(3)}")
oTx.EnableDebug()

oTable = new stzTable([
	[ :A, :B, :C ],
	[ 1, 2, 3 ]
])

? oTx.Match(oTable)
#--> TRUE
# (with debug output showing token parsing) #ERR

oTx.DisableDebug()

pf()

#--------------------------#
#  REAL-WORLD SCENARIOS    #
#--------------------------#
