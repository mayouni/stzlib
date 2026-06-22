# Narrative
# --------
# Removing several items at once from a list with the These(...) helper.
#
# The "-" operator on a stzList subtracts items. Wrapping the items to
# remove in These([...]) reads as plain English: take the list and drop
# THESE values. Here the four string labels "A".."D" are removed from a
# mixed list, leaving only the numeric elements 1..5 in their original
# order. These() is a thin readability wrapper around a list of values;
# it carries no extra semantics beyond making the call site self-document.
#
# Extracted from stzlisttest.ring, block #425.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These([ "A", "B", "C", "D" ])
#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in almost 0 second(s).
