# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #26.
#ERR Error (R14) : Calling Method without definition: itemsoccurringntimes

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "A", "B", "C", "A", "C" ])
? o1.ItemsOccurringNTimes(2)
#--> [ "A", "C" ]

? o1.ItemsOccurringExactlyNTimes(2)
#--> [ "C" ]

? o1.ItemsOccurringLessThanNTimes(3)
#--> [ "B", "C" ]

? o1.ItemsOccurringNTimesOrLess(3)
#--> [ "A", "B", "C" ]

? o1.ItemsOccurringNTimesOrMore(3)
#--> [ "A" ]

pf()
