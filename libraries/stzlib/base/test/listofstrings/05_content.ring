# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #5.
#ERR Error (R14) : Calling Method without definition: trimstart 

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.TrimStart()
? @@(o1.Content())
#--> [ " one ", " two ", " three", " ", " " ]

o1.TrimEnd()
#--> [ " one ", " two ", " three" ]

? @@(o1.Content())

StopProfiler()

pf()
# Executed in 0.04 second(s)
