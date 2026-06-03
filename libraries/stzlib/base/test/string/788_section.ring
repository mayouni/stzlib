# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #788.

load "../../stzBase.ring"

pr()

o1 = new stzstring("123456789")
? o1.Section(4,6)
#--> "456"

pf()
