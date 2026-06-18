# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #499.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSectionByMany(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", "*", "*", "*", "*", "D", "E" ]

pf()
# Executed in almost 0 second(s).
