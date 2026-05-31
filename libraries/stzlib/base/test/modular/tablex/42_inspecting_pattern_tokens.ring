# Narrative
# --------
# Inspecting pattern tokens
#
# Extracted from stztablextest.ring, block #42.

load "../../../stzBase.ring"


pr()

oTx = new stzTablex("{cols(3) & unique(id) & avgcol(salary:>40000)}")

? oTx.Pattern()
#--> {cols(3) & unique(id) & avgcol(salary:>40000)}

? oTx.NumberOfTokens()
#--> Token count: 1

pf()
# Executed in 0.09 second(s) in Ring 1.24
