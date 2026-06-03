# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #244.

load "../../stzBase.ring"

pr()

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? @@( oLargeStr.FindAll("ALIF") )
#--> [ 130655, 1714648, 1716479, 1718401 ]

? oLargeStr.Contains("ALIF")
#--> TRUE

? oLargeStr.FindFirst("ALIF")
#--> 130655

? oLargeStr.NumberOfOccurrence("ALIF")
#--> 4

? oLargeStr.FindNth(4, "ALIF")
#--> 1718401

? oLargeStr.FindLast("ALIF")
#--> 1718401

StopProfiler()

pf()
# Executed in 0.18 second(s) in Ring 1.26 (SoftanzaEngine Zig-based backend, no Qt anymore!)
# Executed in 0.16 second(s) in Ring 1.21
