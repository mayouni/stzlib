# Narrative
# --------
# Two membership checks: ContainsThese on a single list, and
# EachContainsThese broadcast over a list of lists.
#
# ContainsThese([ ... ]) returns TRUE when every item of the
# argument list is present somewhere in the host list. Here the
# host [ "a", "♥", "*" ] contains both "♥" and "*", so the answer
# is TRUE. EachContainsThese is the "for-all" lifting of that test:
# given a list whose members are themselves lists, it returns TRUE
# only when each inner list independently contains all the requested
# items. All three inner lists carry "♥" and "*", hence TRUE.
#
# Extracted from stzlisttest.ring, block #112.

load "../../stzBase.ring"

pr()

? Q([ "a", "♥", "*" ]).ContainsThese([ "♥", "*"])
#--> TRUE

o1 = new stzList([ [ "a", "♥", "*" ], [ "♥", "*"], [ "a", "b", "♥", "*" ] ])
? o1.EachContainsThese([ "♥", "*" ])
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.21
