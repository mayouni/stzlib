# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #194.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

o1.ExtendXT(:To = 10, :ByRepeatingItems)
? @@( o1.Content() )
#--> [ "A", "B", "C", "A", "B", "C", "A", "B", "C", "A" ]

pf()
# Executed in 0.02 second(s)
