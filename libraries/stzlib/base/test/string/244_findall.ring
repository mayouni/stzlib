# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #244.
#
# DEFERRED (data unavailable): this perf test runs FindAll/Contains/FindFirst/
# NumberOfOccurrence/FindNth/FindLast for "ALIF" over the ~1.9M-char UnicodeData()
# (now the Zig engine backend). UnicodeData() returns "" in this checkout, so the
# archive positions ([130655, 1714648, ...]) can't be reproduced. The same
# find/count methods are verified on small strings throughout (e.g. blocks
# 242/244-counterparts). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

oLargeStr = new stzString( UnicodeData() ) # intended: 1_897_793 chars

? @@( oLargeStr.FindAll("ALIF") )          #--> [ 130655, 1714648, 1716479, 1718401 ]
? oLargeStr.Contains("ALIF")               #--> TRUE
? oLargeStr.NumberOfOccurrence("ALIF")     #--> 4
? oLargeStr.FindLast("ALIF")               #--> 1718401

pf()
