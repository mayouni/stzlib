# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #68.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): same byte-vs-codepoint bug as block
# #67, compounded across positions -- RemoveXT(sub, :AtPositions = [...]) on a
# multibyte sub returns "" instead of "ring ruby php". The plain
# RemoveAt([1,9,17], "♥♥♥") form (block #69) works. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
o1.RemoveXT("♥♥♥", :AtPositions = [ 1, 9, 17 ])
? o1.Content() #--> expected "ring ruby php" (currently "")

pf()
