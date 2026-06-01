# Narrative
# --------
# # Testing FindLast() on a very large string (~2M chars)
#
# Extracted from stzStringTest.ring, block #239.

load "../../../stzBase.ring"


StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars
? o1.Contains("جميل")
#--> FALSE

? o1.FindLast("جميل")
#--> FALSE

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.21
