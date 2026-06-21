# Narrative
# --------
# ReplaceManyByManyXT: occurrence-cycling -- a shorter palette wraps across
# ALL matched positions in order.
#
# Four needles [ "*","_","-","/" ] each match once (positions 3-6); the
# 2-item palette [ "A","B" ] cycles A,B,A,B over those four matches, giving
# [ "A","B","A","B","A","B" ]. Unlike the non-XT form (#78/#79) the palette is
# keyed to OCCURRENCE ORDER, not to which needle matched.
#
# Extracted from stzlisttest.ring, block #80.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "_", "-",  "/" ])
o1.ReplaceManyByManyXT([ "*", "_", "-",  "/" ], :With = ["A", "B"])

? @@( o1.Content() )
#--> [ "A", "B", "A", "B", "A", "B" ]

pf()
# Executed in 0.11 second(s)
