# Narrative
# --------
# # Now, what if you want the chain to execute randomly?
#
# Extracted from stzchainofvaluetest.ring, block #4.

load "../../stzBase.ring"

pr()

? SometimesWhen(:v).Is("12").DoThis('{ ? "Done! Because I am lucky ;)" }')
#--> Sometimes, it will say: Done! Because I am lucky ;)

pf()
