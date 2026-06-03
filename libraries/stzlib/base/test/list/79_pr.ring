# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #79.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "3", "D", "5",  "6" ])
o1.ReplaceManyByMany([ "3", "5", "6"], :With = ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

pf()
# Executed in 0.06 second(s)
