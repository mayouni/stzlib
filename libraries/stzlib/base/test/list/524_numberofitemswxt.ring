# Narrative
# --------
# Counting how many items in a list satisfy a condition.
#
# NumberOfItemsW(cCondition) evaluates an engine condition-code string
# against every element, where @item stands for the current element; here it
# counts the numbers (3), then the single-letter strings (3) in a mixed
# list. NumberOfItemsWF(func) does the same with a Ring anonymous function as
# predicate, counting the values divisible by 2 in [1..6] (also 3). W is the
# compact engine form, WF the reusable-Ring-logic form; both return the tally.
#
# Extracted from stzlisttest.ring, block #524.

load "../../stzBase.ring"

pr()

? StzListQ([ "A", 1, "B", 2, "C", 3 ]).NumberOfItemsW(' isNumber(@item) ')
#--> 3

? StzListQ([ "A", 1, "B", 2, "C", 3 ]).NumberOfItemsW(' isString(@item) ')
#--> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsWF( func x { return Q(x).IsDividableBy(2) } )
#--> 3

pf()
# Executed in 0.20 second(s).
