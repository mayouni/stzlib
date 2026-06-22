# Narrative
# --------
# RemoveW(condition): delete every item matching a W condition.
#
# 'Not isNumber(@item)' selects the non-numbers in [ "a", 1, "b", 2, "c", 3 ];
# RemoveW deletes them all in one pass, leaving the clean numeric list
# [ 1, 2, 3 ]. W is the single performant + expressive conditional form
# (the old WXT is retired); braces around the block are optional for a
# simple expression.
#
# Extracted from stzlisttest.ring, block #543.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", 1, "b", 2, "c", 3 ])
o1.RemoveW('Not isNumber(@item)')
? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.12 second(s).
