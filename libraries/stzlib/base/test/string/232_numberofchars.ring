# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #232.
#ERR Error (R14) : Calling Method without definition: splitq

load "../../stzBase.ring"

pr()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.NumberOfChars()
#--> 1914201

? oLargeStr.NumberOfLines()
#--> 34933

? oLargeStr.SplitQ(NL).NumberOfItems()
#--> 34933

StopProfiler()

pf()
# Executed in 0.51 second(s) in Ring 1.21
# Executed in 0.85 second(s) in Ring 1.18
