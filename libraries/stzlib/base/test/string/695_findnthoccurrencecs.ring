# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #695.
#ERR Error (R14) : Calling Method without definition: findnthoccurrencecs

load "../../stzBase.ring"

pr()

o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceCS(3, "Mio", TRUE)
#--> 16

pf()
# Executed in 0.01 second(s).
