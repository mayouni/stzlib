# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #232.

load "../../stzBase.ring"


oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.NumberOfChars()
#--> 1914201

? oLargeStr.NumberOfLines()
#--> 34933

? oLargeStr.SplitQ(NL).NumberOfItems()
#--> 34933

StopProfiler()
# Executed in 0.51 second(s) in Ring 1.21
# Executed in 0.85 second(s) in Ring 1.18
