# Narrative
# --------
# Removing a set of values from a stzList with the - operator and These().
#
# Softanza overloads the minus operator on a stzList so that subtracting
# a value-set deletes every matching element. Wrapping the values in
# These([3,5]) reads as a small fluent phrase -- "this list minus these
# values" -- and yields the remaining items in their original order.
# Here [1,2,3,4,5] - These([3,5]) drops 3 and 5, leaving [1,2,4].
#
# Extracted from stzlisttest.ring, block #313.

load "../../stzBase.ring"

pr()

o1 = new stzList([1,2,3,4,5])
? o1 - These([3,5])
#--> [ 1, 2, 4 ]

pf()
# Executed in almost 0 second(s).
