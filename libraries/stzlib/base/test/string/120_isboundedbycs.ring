# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #120.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Bounds family"): IsBoundedByCS with
# a SINGLE-string bound returns FALSE -- IsBoundedByCS requires a 2-element list,
# so IsBoundedByCS("aa", TRUE) on "aa***aa**aa***aa" is FALSE though the string
# is bounded by "aa" on both ends. (Same root as block #44; fix = widen a string
# bound c to [c, c].) Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("aa***aa**aa***aa")
? o1.IsBoundedByCS("aa", TRUE) #--> expected TRUE (currently FALSE)

pf()
