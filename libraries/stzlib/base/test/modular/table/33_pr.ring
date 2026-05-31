# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #33.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "C", "D", "E" ])
? @@( o1.FindMany([ "A", "B", "A", "B", "B" ]) )
#--> [ 1, 2 ]

o1.ReplaceManyByManyXT([ "A", "B", "A", "D", "E" ], :With = [ "1", "2"])
? @@( o1.Content() )
#--> [ "1", "2", "C", "1", "2" ]

pf()
# Executed in 0.02 second(s)
