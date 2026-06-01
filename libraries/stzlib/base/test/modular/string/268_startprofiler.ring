# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #268.

load "../../../stzBase.ring"


o1 = new stzString("99999999999")
o1.SpacifyChars()

? o1.Content()
#--> 9 9 9 9 9 9 9 9 9 9 9

StopProfiler()
# Executed in 0.01 second(s)
