# Narrative
# --------
# #TODO Idem
#
# Extracted from stzStringTest.ring, block #220.
#
# DEFERRED to the W/WXT-conditional pass (string step 2): YieldWXT is RETIRED
# (R14). Replacement is YieldW. Intended: map each letter to [letter, ascii-64].
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q(["A", "B", "C"]).YieldWXT('[ @item, ascii(@item) - 64 ]')
#--> [ [ "A",1 ], [ "B",2 ], [ "C",3 ] ]

pf()
