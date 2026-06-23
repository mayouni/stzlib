# Narrative
# --------
# ReplaceManyByMany: distinct 1-to-1, the clean case where each needle occurs
# once.
#
# Three needles [ "3","5","6" ] paired with [ "C","E","F" ]: 3->C, 5->E, 6->F,
# rebuilding [ "A","B","C","D","E","F" ]. Same value-keyed contract as block
# #78; here each needle appears a single time so the mapping reads directly.
#
# Extracted from stzlisttest.ring, block #79.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "3", "D", "5",  "6" ])
o1.ReplaceManyByMany([ "3", "5", "6"], :With = ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

pf()
# Executed in 0.06 second(s)
