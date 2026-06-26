# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #143.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Extend family"): ExtendXT(
# :ToPosition = 5, :ByCharsRepeated) pads with SPACES ("ABC  ") instead of
# repeating the string's own chars to give "ABCAB". (Same intent as block #142,
# different spelling; both broken.) Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :ByCharsRepeated )
o1.Show()
#--> expected "ABCAB" (currently "ABC  ")

pf()
