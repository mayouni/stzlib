# Narrative
# --------
# #TODO Idem
#
# Extracted from stzStringTest.ring, block #220.
#ERR Error (R14) : Calling Method without definition: yieldwxt

load "../../stzBase.ring"


pr()

? Q(["A", "B", "C"]).YieldWXT('[ @item, ascii(@item) - 64 ]')

pf()
