# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #78.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])
o1.ReplaceManyByMany([ "*", "=" ], :With = ["C", "E", "F"])
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

pf()
# Executed in 0.06 second(s)
