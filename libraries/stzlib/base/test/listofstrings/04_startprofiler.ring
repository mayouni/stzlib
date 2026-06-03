# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #4.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.Trim()
? @@(o1.Content())
#--> [ " one ", " two ", " three" ]

o1.TrimStrings()
? @@(o1.Content())
#--> [ "one", "two", "three" ]

StopProfiler()
# Executed in 0.08 second(s)
