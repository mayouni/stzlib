# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #193.
#ERR Error (R14) : Calling Method without definition: replacext

load "../../stzBase.ring"

pr()

o1 = new stzString("~♥/♥\~♥")
o1.ReplaceXT("♥", :AtPositions = [2, 7], :With = "~") # Or :AtPositions
? o1.Content()
#--> ~~/♥\~~

pf()
#-- Executed in 0.01 second(s)
