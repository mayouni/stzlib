# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #179.

load "../../stzBase.ring"


o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveSection(3, 5)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

pf()
# Executed in 0.03 second(s)

*-----------------

pr()

o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveRange(3, 3)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

pf()
# Executed in 0.03 second(s)
