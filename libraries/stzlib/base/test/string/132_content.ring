# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #132.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("Ringprogramminglanguageispowerful!")

o1.SpacifySections([ [ 5, 15 ], [ 24, 25 ] ])
? o1.Content()
#--> Ring programming language is powerful!

pf()
# Executed in 0.04 second(s)
