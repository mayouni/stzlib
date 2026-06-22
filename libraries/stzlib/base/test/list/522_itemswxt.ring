# Narrative
# --------
# Filters a list with ItemsWXT, the "items where, with @item access" closure form.
#
# ItemsWXTQ runs a conditional-code block ('{ ... }') against every element,
# exposing the current element as @item so the predicate can both type-test it
# (isNumber(@item)) and route it through a Stz query (Q(@item).IsDividableBy(2)).
# Here the 'W' marks a where-filter and the 'XT' (extended) marks that the block
# is full conditional code rather than a simple expression. Of [1..6] only the
# even numbers 2, 4, 6 survive, so NumberOfItems() on the filtered result is 3.
#
# Extracted from stzlisttest.ring, block #522.

load "../../stzBase.ring"

pr()

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWXTQ('{

	isNumber(@item) and
	Q(@item).IsDividableBy(2)

}').NumberOfItems()
#--> 3

pf()
# Executed in 0.14 second(s).
