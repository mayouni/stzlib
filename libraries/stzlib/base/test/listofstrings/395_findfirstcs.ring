# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #395.
#ERR Error (R14) : Calling Method without definition: findfirstcs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "A", "B", "1", "C", "2", "3", "D", "4", "5" ])

? o1.FindFirstCS("b", TRUE)
#--> 0

? o1.FindFirstCS("b", :CS = FALSE)
#--> 2

pf()
# Executed in 0.13 second(s).
