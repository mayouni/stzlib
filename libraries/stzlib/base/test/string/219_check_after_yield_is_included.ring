# Narrative
# --------
# #TODO Check after Yield() is included
#
# Extracted from stzStringTest.ring, block #219.
#
# DEFERRED to the W/WXT-conditional pass (string step 2): YieldWXT is RETIRED
# (R14: "Calling Method without definition: yieldwxt") -- the WXT family was
# removed. Its replacement is the W form (YieldW). The intended output maps each
# uppercased letter to ascii(letter)-65. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

# Map each letter to its ascii code minus 65:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('ascii(@item) - 65')
#--> [ 17, 8, 13, 6, 8, 18, 14, 22, 18, 14, 12, 4 ]

# Letter together with its code:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]')
#--> [ [ "R",17 ], [ "I",8 ], ... ]

pf()
