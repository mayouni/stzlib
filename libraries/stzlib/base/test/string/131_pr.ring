# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #131.

load "../../stzBase.ring"

pr()

o1 = new stzString("Ringprogramminglanguageispowerful!")
//o1.InsertAfterPositions([ 4, 15, 23, 25], " ")
o1.InsertBeforePositions([ 5, 16, 24, 26], " ")
#--> Ring programming language is powerful!

pf()
# Executed in 0.03 second(s)
