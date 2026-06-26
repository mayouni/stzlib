# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #60.
# #ERR Error (R14) : Calling Method without definition: isrealinstring
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): IsRealInString() / IsARealInString()
# / RepresentsRealInString() (and the global BothAreRealsInStrings) were dropped
# during modularization. In the archive monolith they are trivial aliases of
# RepresentsNumber() (stzString_monolithic.ring ~94018); the modular file kept
# only RepresentsRealNumber(). Restore the aliases in the fix-pass. Left in
# print/#ERR form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q("2.8").IsRealInString()
#--> TRUE

? Q("3.2").IsRealInString()
#--> TRUE

? BothAreRealsInStrings("2.8", "3.2")
#--> TRUE

pf()
