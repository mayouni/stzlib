# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #225.
#ERR Error (R14) : Calling Method without definition: findprevious

load "../../stzBase.ring"

pr()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
? o1.FindPrevious("<<<", :StartingAt = 11)
#--> 4

pf()
# Executed in 0.02 second(s) in Ring 1.21
