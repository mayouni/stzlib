# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #159.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 12

? o1.Duplicates()
#--> [ "r", "ri", "rin", "ring", "i", "in", "ing", "n", "ng", "g", " ", "p" ]

pf()
# Executed in 0.65 second(s) in Ring 1.22
