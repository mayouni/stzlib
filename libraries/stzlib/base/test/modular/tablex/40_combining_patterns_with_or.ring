# Narrative
# --------
# Combining patterns with Or_()
#
# Extracted from stztablextest.ring, block #40.

load "../../../stzBase.ring"


pr()

oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{cols(4)}")
oTx3 = oTx1.Or_(oTx2)

? oTx3.Pattern()
#--> {cols(3) | cols(4)}

pf()
# Executed in 0.15 second(s) in Ring 1.24
