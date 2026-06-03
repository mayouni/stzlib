# Narrative
# --------
# #ring
#
# Extracted from stzStringTest.ring, block #259.

load "../../stzBase.ring"


pr()

? @@( substr("", 1, 1) )
#--> ""

? substr("blablabla", "")
#--> 1

? ring_substr1("blablabla", "")
#--> 0

pf()
