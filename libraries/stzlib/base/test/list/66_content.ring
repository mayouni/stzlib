# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #66.
#ERR Error (R14) : Calling Method without definition: removeanycharfromleft

load "../../stzBase.ring"

pr()

o1 = new stzString("♥♥♥123♥♥♥")

o1.RemoveAnyCharFromLeft("♥")
? o1.Content()
#--> 123♥♥♥

o1.RemoveAnyCharFromRight("♥")
? o1.Content()
#--> 123

pf()
# Executed in 0.02 second(s)
