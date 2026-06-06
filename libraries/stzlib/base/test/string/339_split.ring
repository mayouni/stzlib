# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #339.

load "../../stzBase.ring"

pr()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? o1.SplitQ("aa").IfQ('This.NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO // IfQ() function Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

pf()
# Executed in 0.03 second(s)
