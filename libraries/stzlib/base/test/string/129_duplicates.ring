# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #129.
#
# SEMANTICS TO CONFIRM (deferred -- see _AUDIT_DEFECTS.md): Duplicates() on
# "RINGORIALAND" returns the duplicated CHARACTERS [ "R", "I", "A", "N" ], but
# the archive expected a set that also includes the duplicated multi-char
# substring "RI" ([ "R", "RI", "I", "N", "A" ]). Unclear whether Duplicates()
# should enumerate duplicated SUBSTRINGS or just characters; pending the author's
# call. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("RINGORIALAND")
? @@( o1.Duplicates() )
#--> currently [ "R", "I", "A", "N" ]; archive expected [ "R", "RI", "I", "N", "A" ]

pf()
