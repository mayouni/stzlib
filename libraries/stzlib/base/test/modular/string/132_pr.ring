# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #132.

load "../../../stzBase.ring"


o1 = new stzString("Ringprogramminglanguageispowerful!")

o1.SpacifySections([ [ 5, 15 ], [ 24, 25 ] ])
? o1.Content()
#--> Ring programming language is powerful!

pf()
# Executed in 0.04 second(s)
