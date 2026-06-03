# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #253.

load "../../stzBase.ring"


o1 = new stzString("ABC*EF")
o1.ReplaceSection( 4, 4, "D")
? o1.Content()
#--> ABCDEF

StopProfiler()
#--> Executed in 0.01 second(s)
