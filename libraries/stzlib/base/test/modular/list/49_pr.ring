# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #49.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceAnyItemAt(3, :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

pf()
# Executed in 0.05 second(s)
