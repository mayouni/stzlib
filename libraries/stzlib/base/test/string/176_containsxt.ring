# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #176.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "ContainsXT named-position forms"):
# the substring-valued ContainsXT(sub, :Before = "♥^") / ContainsXT(sub, :After =
# "-♥") forms return FALSE although the matches exist. Part of the broken
# ContainsXT named-position family (blocks 170/173/174/175). Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :Before = "♥^") #--> expected TRUE (currently FALSE)
? Q("--♥^^").ContainsXT("^", :After = "-♥")  #--> expected TRUE (currently FALSE)

pf()
