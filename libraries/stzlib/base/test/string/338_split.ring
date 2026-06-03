# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #338.
#ERR Error (R14) : Calling Method without definition: splitq

load "../../stzBase.ring"

pr()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")
? o1.SplitQ("aa").IfQ('NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO // Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

pf()
# Executed in 0.01 second(s) in Ring 1.21
