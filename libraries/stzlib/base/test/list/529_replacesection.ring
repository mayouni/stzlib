# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #529.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "_", "_", "_", "4", "5" ])
o1.ReplaceSection(3, 5, :With = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

pf()
# Executed in almost 0 second(s).
