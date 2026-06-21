# Narrative
# --------
# Removing an item from a stzList by value using the "-" operator.
#
# Softanza overloads the minus operator on stzList so that subtracting
# a string removes every matching item by value (not by position). Here
# "TWO" is dropped from [ "ONE", "TWO", "THREE" ], leaving the other two
# entries in their original order. This is the operator-sugar form of
# RemoveItem / Remove, giving list arithmetic a natural, set-like feel.
#
# Extracted from stzlisttest.ring, block #368.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ONE", "TWO", "THREE" ])
? o1 - "TWO"
#--> [ "ONE", "THREE" ]

pf()
# Executed in almost 0 second(s).
