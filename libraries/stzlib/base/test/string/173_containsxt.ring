# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #173.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): both calls return FALSE on "^^♥^^"
# although a "^" does occur after position 2 and within the (reversed) section
# 5..3. ContainsXT(:AfterPosition=) is part of the broken ContainsXT named-
# position family (blocks 174/175); ContainsInSection is the block-171 bug, and
# it also fails to auto-order the reversed (5,3) bounds. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 2) #--> expected TRUE (currently FALSE)
? Q("^^♥^^").ContainsInSection("^", 5, 3)        #--> expected TRUE (currently FALSE)

pf()
