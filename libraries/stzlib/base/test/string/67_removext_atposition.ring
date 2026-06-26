# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #67.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): RemoveXT(sub, :AtPosition = n) is
# byte-based -- its helper _RemoveOccurrenceAtPos (stzString.ring ~2070) uses
# len()/StzMid instead of the engine codepoint helpers, so a multibyte sub like
# "♥♥♥" (9 bytes / 3 codepoints) corrupts the cut: it returns "ring ru" instead
# of "ring ruby php". The plain RemoveAt(6, "♥♥♥") form (block #66) works. Left
# in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring ♥♥♥ruby php")
o1.RemoveXT("♥♥♥", :AtPosition = 6)
? o1.Content() #--> expected "ring ruby php" (currently "ring ru")

pf()
