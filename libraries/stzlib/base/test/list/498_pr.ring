# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #498.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSection(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", [ "*", "*", "*", "*" ], "D", "E" ]

pf()
# Executed in almost 0 second(s).
