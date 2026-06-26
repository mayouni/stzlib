# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #188.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT(:Each = sub, [], :With =
# new) RAISES "ReplaceXT: unsupported argument shape" (stzString.ring ~2917) --
# the :Each form (with the trailing []) is not handled. Use ReplaceAll / the
# plain Replace instead. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

Q("♥♥♥ Ring programing language ♥♥♥") {
	ReplaceXT( :Each = "♥", [], :With = "*")  # raises: unsupported argument shape
	? Content()
	#--> expected "*** Ring programing language ***"

	ReplaceXT("*", :With = "♥", [])
	? Content()
	#--> expected "♥♥♥ Ring programing language ♥♥♥"
}

pf()
