# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #586.

load "../../stzBase.ring"

pr()

o1 = new stzString("**A1****A2***A3")
o1.RemoveFirst("A")
? o1.Content()
#--> **1****A2***A3

pf()
