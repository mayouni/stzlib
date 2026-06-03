# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #77.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "*", "*", "*",  "*" ])

o1.ReplaceOccurrencesByManyXT([ 3, 4, 5, 6 ], [ "#1", "#2" ])

? @@( o1.Content() )
#--> [ "A", "B", "#1", "#2", "#1", "#2" ]

pf()
# Executed in 0.07 second(s)
