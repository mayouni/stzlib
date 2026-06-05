# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #453.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "A", "D", "B", "A" ])
? o1.FindNthOccurrence(3, :Of = "A")
#--> 7

? @@( o1.Content() )
# [ "A", "B", "C", "A", "D", "B", "A" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
