# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #252.

load "../../../stzBase.ring"


o1 = new stzString("ABC*EF")

o1.ReplaceCharAt( :Position = 4, :By = "D")
? o1.Content()
#--> "ABCDEF"

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
