# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #3.
#ERR Error (R14) : Calling Method without definition: removesubstring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "--**-*", "*---*", "--*-***" ])
o1.RemoveSubString("*")
? @@( o1.Content() )
#--> [ "---", "---", "---" ]

pf()
# Executed in 0.05 second(s)
