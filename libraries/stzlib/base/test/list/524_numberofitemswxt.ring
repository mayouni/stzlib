# Narrative
# --------
# Counting how many items in a list satisfy a condition.
#
# NumberOfItemsWXT(cCondition) evaluates an engine condition-code
# string against every element, where @item stands for the current
# element; here it counts the numbers (3), then the single-letter
# strings (3) in a mixed list. NumberOfItemsWF(func) does the same
# with a Ring anonymous function as predicate, counting the values
# divisible by 2 in [1..6] (also 3). WXT favors a compact inline
# expression, WF favors reusable Ring logic; both return the tally.
#
# Extracted from stzlisttest.ring, block #524.

load "../../stzBase.ring"

pr()

? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsWXT('isNumber(@item)')
#--> 3

? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsWXT('
	isString(@item) and IsLetter(@item)
')
#--> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsWF( func x { return Q(x).IsDividableBy(2) } )
#--> 3

pf()
# Executed in 0.21s second(s).
