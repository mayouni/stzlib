# Narrative
# --------
# The frequency-filter family: select items by HOW OFTEN they occur.
#
# For [ A, A, B, C, A, C ] (A:3, B:1, C:2):
#   ItemsOccurringNTimes(2)         -- n or MORE  -> [ "A", "C" ]
#   ItemsOccurringExactlyNTimes(2)  -- exactly n  -> [ "C" ]
#   ItemsOccurringLessThanNTimes(3) -- fewer than -> [ "B", "C" ]
#   ItemsOccurringNTimesOrLess(3)   -- n or fewer -> [ "A", "B", "C" ]
#   ItemsOccurringNTimesOrMore(3)   -- n or more  -> [ "A" ]
# A precise vocabulary for the four count comparisons (>=, =, <, <=, >=).
#
# Extracted from stzlisttest.ring, block #26.

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
# Executed in almost 0 second(s)
