# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #159.

load "../../stzBase.ring"


o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 12

? o1.Duplicates()
#--> [ "r", "ri", "rin", "ring", "i", "in", "ing", "n", "ng", "g", " ", "p" ]

pf()
# Executed in 0.65 second(s) in Ring 1.22
