# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #362.

load "../../../stzBase.ring"


# Same example above in stzList

o1 = new stzList([ "A", "C", "D" ])
o1.InsertAt(2, "B")

? o1.Content()
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s).
