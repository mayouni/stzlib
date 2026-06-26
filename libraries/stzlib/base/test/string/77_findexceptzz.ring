# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #77.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Except family"): with a LIST of
# separators, FindExceptZZ([ "--", "__" ]) returns the whole string as one span
# ([ [1,21] ]) instead of [ [3,6], [9,9], [12,19] ], and Except([...]) returns ""
# instead of [ "ring", "&", "softanza" ]. The single-separator FindExceptZZ
# (block #76) works. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("--ring--&__softanza__")
? @@( o1.FindExceptZZ([ "--", "__" ]) )  #--> expected [ [3,6],[9,9],[12,19] ] (currently [ [1,21] ])
? @@( o1.Except([ "--", "__" ]) )        #--> expected [ "ring","&","softanza" ] (currently "")

pf()
