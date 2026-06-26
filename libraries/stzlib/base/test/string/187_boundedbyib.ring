# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #187.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "BoundedBy variants"): BoundedByIB
# (Include Bounds) loses the second element ("<<★★>>" comes back as ""), and
# BoundedByIBZZ returns position spans only ([ [4,16], [20,29] ]) -- wrong spans
# AND missing the substring grouping it should provide. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")
? o1.BoundedByIB([ "<<", ">>" ])
#--> expected [ "<<♥♥♥>>", "<<★★>>" ] (currently second element is empty)

? @@NL( o1.BoundedByIBZZ([ "<<", ">>" ]) )
#--> expected each substring paired with its [from,to] span (currently positions only)

pf()
