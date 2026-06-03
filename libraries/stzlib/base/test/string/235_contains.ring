# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #235.

load "../../stzBase.ring"

pr()

o1 = new stzString("•••••••••")

? o1.Contains("")
#--> FALSE

? o1.Contains("•")
#--> TRUE

pf()
