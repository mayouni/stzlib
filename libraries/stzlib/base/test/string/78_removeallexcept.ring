# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #78.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Except family"): RemoveAllExcept
# only handles a SINGLE keep-token -- it counts NumberOfOccurrence(pcKeep) and
# rebuilds StzRepeatStr(pcKeep, n) (stzString.ring ~12926). Passed a LIST of
# keep-tokens it produces "" instead of "Ring&Softanza". Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--&__Softanza__")
o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
? o1.Content() #--> expected "Ring&Softanza" (currently "")

pf()
