# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #758.

load "../../stzBase.ring"

pr()

o1 = new stzString("a")
? o1 * [ "b", "c", "d" ]
#--> abacad

pf()
# Executed in 0.01 second(s).
