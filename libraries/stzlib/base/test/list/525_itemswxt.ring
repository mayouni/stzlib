# Narrative
# --------
# Selecting items that satisfy a condition, via two interchangeable predicate styles.
#
# ItemsWXT takes a Softanza condition expressed as a string-DSL where @item is
# the current element placeholder; the engine evaluates it against every item and
# keeps the ones for which it is true. The first call keeps numbers, the second
# keeps single-letter strings (note Q(@item) wraps the item so list-of-string
# checks like IsLetter() are available inside the expression). ItemsWF does the
# same selection but takes an anonymous Ring function (func x { ... }) instead of
# a DSL string, here keeping the even numbers via IsDividableBy(2). Both return a
# fresh filtered list, leaving the source untouched.
#
# Extracted from stzlisttest.ring, block #525.

load "../../stzBase.ring"

pr()

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT(' isNumber(@item) ')
#--> [ 1, 2, 3 ]

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT('
	isString(@item) and Q(@item).IsLetter()
') #--> [ "A", "B", "C" ]

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWF( func x { return Q(x).IsDividableBy(2) } )
#--> [ 2, 4, 6 ]

pf()
# Executed in 0.22 second(s).
