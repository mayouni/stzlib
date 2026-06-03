# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #363.

load "../../stzBase.ring"

pr()

# Same example above in stzListOfStrings

o1 = new stzListOfStrings([ "A", "C", "D" ])
o1.Insert("B", :AtPosition = 2)			# or you can say: o1.InsertAt(2, "B")
? o1.Content()
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in 0.04 second(s).
