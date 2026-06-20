# Narrative
# --------
# ItemsOccurringNTimesCS(n, bCaseSensitive): which items appear at LEAST
# n times, with a case-sensitivity dial.
#
# In [ "A","B","A","C","D","B","b" ] with n = 3 and case folding OFF,
# "A" appears twice and "B"/"b" appears three times (B, B, b). So only
# the "b" family clears the n = 3 bar, and the item is reported as "b".
#
# (Method spelled with one "r" -- "Occuring" -- a deliberate near-natural
# alias kept alongside the correct "Occurring" form.)
#
# Extracted from stzlisttest.ring, block #25.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? o1.ItemsOccuringNTimesCS(3, FALSE) #NOTE this is a misspelled form (one r instead of 2)
#--> [ "b" ]

pf()
# Executed in almost 0 second(s)
