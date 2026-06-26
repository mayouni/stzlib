# Narrative
# --------
# # Testing FindNthNext()/FindNthPrevious on a very large string (~2M chars)
#
# Extracted from stzStringTest.ring, block #237.
#
# DEFERRED (data unavailable): this perf test searches UnicodeDataAsString()
# (~1.9M chars), but that global returns "" in this checkout, so the archive's
# positions (110819, 106564, 300643, ...) can't be reproduced. The directional
# FindNext/FindNthNext/FindPrevious methods themselves are verified on a small
# string in block 236. Left in print form; NOT asserted. (See the
# 07_managing_a_big_text perf guard for large-text coverage.)

load "../../stzBase.ring"

pr()

o1 = new stzString( UnicodeDataAsString() ) # intended: 1_897_793 chars

? o1.FindNext("ARABIC HA", :StartingAt = 1)        #--> 110819
? o1.FindNthNext(6, "ARABIC", :StartingAt = 3)     #--> 106564
? o1.FindNthNext(12, "HAN", :StartingAt = 250_000) #--> 300643

pf()
