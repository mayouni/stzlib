# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #583.

load "../../stzBase.ring"

pr()

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrence(:Last, "A")
? o1.Content()
#--> **A1****A2***3

pf()
# Executed in 0.01 second(s) in Ring 1.22
