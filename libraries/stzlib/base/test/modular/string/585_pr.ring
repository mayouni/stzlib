# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #585.

load "../../../stzBase.ring"


o1 = new stzString("**A1****A2***A3")
o1.RemoveLast("A")
? o1.Content()
#--> **A1****A2***3

pf()
# Executed in 0.03 second(s)
