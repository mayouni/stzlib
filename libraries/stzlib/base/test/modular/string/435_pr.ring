# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #435.

load "../../../stzBase.ring"


o1 = new stzString("{abc}")

o1.RemoveThisFirstChar("{")
o1.RemoveThisLastChar("}")

? o1.Content()
#--> abc

pf()
# Executed in 0.01 second(s) in Ring 1.21
