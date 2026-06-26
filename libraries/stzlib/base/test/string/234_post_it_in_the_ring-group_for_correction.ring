# Narrative
# --------
# #ringqt #ERROR #TODO post it in the ring-group for correction
#
# Extracted from stzStringTest.ring, block #234.
#
# REFERENCE (not a Softanza test): this documents a RING-NATIVE substr() quirk on
# multibyte bullets -- substr(cStr, "") returns 0 and substr(cStr, "•") returns 1.
# It was posted to the ring-lang group for correction (link below). The
# codepoint-correct Softanza counterpart is Contains() -- see block #235. Kept in
# print form as a reference note; NOT asserted.

load "../../stzBase.ring"

# https://groups.google.com/d/msgid/ring-lang/c5f6c5ea-9afd-411d-8000-6a695d8db2f4n%40googlegroups.com

pr()

cStr = "•••••••••"

? substr(cStr, "")
#--> 0

? substr(cStr, "•")
#--> 1

pf()
