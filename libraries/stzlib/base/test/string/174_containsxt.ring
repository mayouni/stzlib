# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #174.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "ContainsXT named-position forms"):
# ContainsXT(sub, :BeforePosition = n) and ContainsXT(sub, :AfterPosition = n)
# both return FALSE although the matches exist. The plain ContainsBefore /
# ContainsAfter forms (block 172) work. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3) #--> expected TRUE (currently FALSE)
? Q("--♥^^").ContainsXT("^", :AfterPosition = 2)  #--> expected TRUE (currently FALSE)

pf()
