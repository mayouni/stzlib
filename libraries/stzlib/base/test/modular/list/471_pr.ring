# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #471.

load "../../../stzBase.ring"


o1 = new stzList(1:5)
o1.AddItemAt(8, 9)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, NULL, NULL, 9 ]

pf()
# Executed in almost 0 second(s).
