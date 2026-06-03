# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #364.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A1", "A2", "A3" ])
o1.InsertAfter( :ItemAtPosition = 3, "A4" )
? o1.Content()
#--> [ "A1", "A2", "A3" ]

pf()
# Executed in 0.01 second(s).
