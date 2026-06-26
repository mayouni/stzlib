# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #79.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Except family"): ReplaceAllExcept
# replaces each excluded CHAR individually (-> "♥♥Ring♥♥♥♥Softanza♥♥") rather
# than each excluded RUN once (block #82's intent is one ♥ per run). The archive
# #--> "Ring&♥Ring♥Softanza♥" is itself garbled (has an "&" absent from the input
# and "Ring" twice). Granularity/contract to confirm. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
? o1.Content() #--> currently "♥♥Ring♥♥♥♥Softanza♥♥"

pf()
