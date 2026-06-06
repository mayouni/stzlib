# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #245.

load "../../stzBase.ring"

pr()

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.Contains("Plane 15 Private Use")
#--> TRUE

? oLargeStr.HowMany("Plane 15 Private Use") + NL
#--> 2

? oLargeStr.FindAll("Plane 15 Private Use")
#--> [ 1913993, 1914047 ]

? oLargeStr.FindFirst("Plane 15 Private Use") + NL
#--> 1913993

? oLargeStr.FindLast("Plane 15 Private Use")
#--> 1914047

StopProfiler()

pf()
# Executed in 0.04 second(s) in Ring 1.26
# Executed in 0.12 second(s) in Ring 1.21
