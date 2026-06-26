# Narrative
# --------
# #TODO Idem
#
# Extracted from stzStringTest.ring, block #221.
#
# DEFERRED to the W/WXT-conditional pass (string step 2): YieldWXT is RETIRED
# (R14). Replacement is YieldW. Intended: map each uppercased letter to
# [letter, ascii-65]. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? @@( Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]') )
#--> [ [ "R",17 ], [ "I",8 ], [ "N",13 ], ... ]

pf()
