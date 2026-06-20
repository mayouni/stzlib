# Narrative
# --------
# IsListOfNumbersAndPairsOfNumbers(): a shape predicate -- is every item
# either a number or a pair (2-list) of numbers?
#
# Useful for validating mixed numeric structures like a series of scalars
# interleaved with [x, y] points before feeding them to a chart or a
# geometry routine. Here [ 0, 2, 0, 3, [1,2] ] qualifies: four plain
# numbers and one number-pair.
#
# Extracted from stzlisttest.ring, block #357.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 0, 2, 0, 3, [1,2] ])
? o1.IsListOfNumbersAndPairsOfNumbers()
#--> TRUE

pf()
# Executed in almost 0 second(s)
