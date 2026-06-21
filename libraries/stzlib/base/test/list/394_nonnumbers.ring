# Narrative
# --------
# Keeping only the numeric items of a mixed list by subtracting the non-numbers.
#
# NonNumbers() returns every element of the list that is not a number
# (here the strings "A", "B", "C", "D"). Wrapping that set in These()
# turns it into a removal spec, and the stzList "-" operator subtracts
# those exact items from the original list. What remains is the numeric
# core [ 1, 2, 3, 4, 5 ] -- a declarative "drop the non-numbers" idiom
# that reads as plainly as the intent.
#
# Extracted from stzlisttest.ring, block #394.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These( o1.NonNumbers() )
#-->  [ 1, 2, 3, 4, 5 ]

pf()
# Executed in almost 0 second(s).
