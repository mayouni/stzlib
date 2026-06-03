# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #4.
#ERR Error (R14) : Calling Method without definition: trimstrings 

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.Trim()
? @@(o1.Content())
#--> [ " one ", " two ", " three" ]

o1.TrimStrings()
? @@(o1.Content())
#--> [ "one", "two", "three" ]

StopProfiler()

pf()
# Executed in 0.08 second(s)
