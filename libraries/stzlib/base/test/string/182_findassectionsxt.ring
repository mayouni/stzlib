# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #182.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): FindAsSectionsXT(sub, :Between=[a,b])
# returns [] (the :Between named param is not parsed) instead of [ [6,6], [14,14] ]
# on "...<<*>>...<<*>>...". The plain FindBetweenAsSections form works (blocks
# 179/180). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("...<<*>>...<<*>>...")
? @@( o1.FindAsSectionsXT( "*", :Between = [ "<<", ">>" ]) )
#--> expected [ [ 6, 6 ], [ 14, 14 ] ] (currently [])

pf()
