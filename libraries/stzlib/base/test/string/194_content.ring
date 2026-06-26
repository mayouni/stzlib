# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #194.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT([], :BoundedBy = [a,b],
# :With = new) RAISES "ReplaceXT: unsupported argument shape" (stzString.ring
# ~2917) -- the :BoundedBy form is not handled. Should replace the bounded
# content: "bla bla <<♥♥♥>> and bla!" -> "bla bla <<bla>> and bla!". Left in print
# form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<♥♥♥>> and bla!")
o1.ReplaceXT( [], :BoundedBy = ["<<",">>"], :With = "bla" )  # raises: unsupported argument shape
? o1.Content()
#--> expected "bla bla <<bla>> and bla!"

pf()
