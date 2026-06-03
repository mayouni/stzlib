# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #5.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.TrimStart()
? @@(o1.Content())
#--> [ " one ", " two ", " three", " ", " " ]

o1.TrimEnd()
#--> [ " one ", " two ", " three" ]

? @@(o1.Content())

StopProfiler()
# Executed in 0.04 second(s)
