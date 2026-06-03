# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #472.

load "../../stzBase.ring"

pr()

o1 = new stzList("A":"E")
o1.AddItemAt(8, "X")
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

pf()
# Executed in almost 0 second(s).
