# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #245.
#
# DEFERRED (data unavailable): perf test for Contains/HowMany/FindAll/FindFirst/
# FindLast of "Plane 15 Private Use" over the ~1.9M-char UnicodeData(). It returns
# "" in this checkout, so the archive positions ([1913993, 1914047]) can't be
# reproduced. The methods are verified on small strings elsewhere. Left in print
# form; NOT asserted.

load "../../stzBase.ring"

pr()

oLargeStr = new stzString( UnicodeData() ) # intended: 1_897_793 chars

? oLargeStr.Contains("Plane 15 Private Use")  #--> TRUE
? oLargeStr.HowMany("Plane 15 Private Use")   #--> 2
? oLargeStr.FindAll("Plane 15 Private Use")   #--> [ 1913993, 1914047 ]

pf()
