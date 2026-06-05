# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #133.

load "../../stzBase.ring"

pr()

o1 = new stzString("Ringprogramminglanguageispowerful!")
o1.SpacifySubStrings([ "programming", "is" ])
? o1.Content()
#--> Ring programming language is powerful!

pf()
# Executed in 0.27 second(s)
