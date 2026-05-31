# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #396.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1.Contains("a")
#--> FALSE

? o1.Contains("A")
#--> TRUE

? o1.ContainsNo("C")
#--> FALSE

? o1.ContainsNo("X")
#--> TRUE

pf()
# Executed in 0.02 second(s).
