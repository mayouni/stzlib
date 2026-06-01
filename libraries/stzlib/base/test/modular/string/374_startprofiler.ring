# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #374.

load "../../../stzBase.ring"


o1 = new stzString("123456789")

o1.ReplaceSection(4, 6, :with = "♥♥♥")
? o1.Content()
#--> 123♥♥♥789

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
