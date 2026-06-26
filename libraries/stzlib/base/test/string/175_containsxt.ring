# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #175.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "ContainsXT named-position forms"):
# ContainsXT(sub, :Before = n) and ContainsXT(sub, :After = n) (the short
# spellings of block 174) both return FALSE although the matches exist. The plain
# ContainsBefore / ContainsAfter forms (block 172) work. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :Before = 3) #--> expected TRUE (currently FALSE)
? Q("--♥^^").ContainsXT("^", :After = 2)  #--> expected TRUE (currently FALSE)

pf()
