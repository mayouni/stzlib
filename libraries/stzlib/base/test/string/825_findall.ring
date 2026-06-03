# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #825.
#ERR Error (R14) : Calling Method without definition: findnthoccurrence

load "../../stzBase.ring"

pr()

o1 = new stzString("text this text is written with the text of my scrampy text")

? o1.FindAll("text")
#--> [ 1, 11, 36, 55 ]

? o1.FindNthOccurrence(4, :Of = "text") + NL
#--> 55

? o1.ContainsNtimes(4, "text")
#--> TRUE

pf()
# Executed in 0.01 second(s).
