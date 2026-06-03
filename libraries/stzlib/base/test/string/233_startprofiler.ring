# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #233.

load "../../stzBase.ring"


oLargeStr = new stzString( UnicodeData() )
#~> Contains ~2M chars (1.914.201 exactly)

? oLargeStr.Reverse()
? oLargeStr.Content()

StopProfiler()
# Executed in  8.50 second(s) in Ring 1.22
# Executed in 14.56 second(s) in Ring 1.17
