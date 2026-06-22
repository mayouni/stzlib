# Narrative
# --------
# Filtering a list with ItemsW, the "items where" conditional-code form.
#
# ItemsWQ runs a conditional-code block ('{ ... }') against every element,
# exposing the current element as @item so the predicate can both type-test
# it (isNumber(@item)) and route it through a Stz query
# (Q(@item).IsDividableBy(2)). W is the single performant + expressive
# conditional form (the old WXT is retired). Of [1..6] only the even numbers
# 2, 4, 6 survive, so NumberOfItems() on the filtered result is 3.
#
# Extracted from stzlisttest.ring, block #522.

load "../../stzBase.ring"

pr()

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWQ('{ isNumber(@item) and Q(@item).IsDividableBy(2) }').NumberOfItems()
#--> 3

pf()
# Executed in 0.12 second(s).
