# Narrative
# --------
# The (-) operator on a stzList -- and the Q() "elevator" that decides
# the RETURN type.
#
# Softanza's opinionated rule: an operator never mutates the object, and
# the shape of the RIGHT operand decides what you get back:
#   - a RAW operand  (3, or the list 1:3)  -> a plain Ring list
#   - a Q()-wrapped operand (Q(3), Q(1:3)) -> a chainable stzList object
# so you can keep calling methods (.Content() here). Either way the
# removed value is matched by CONTENT, so the sublist [1,2,3] is removed
# deep-equal, not by Ring's shallow `=`.
#
# Extracted from stzlisttest.ring, block #400.

load "../../stzBase.ring"

pr()

? Q(1:5) - 3
#--> [ 1, 2, 4, 5 ]

? ( Q(1:5) - Q(3) ).Content()
#--> [ 1, 2, 4, 5 ]

? Q([ "A", "B", 1:3, "C" ]) - 1:3
#--> [ "A", "B", "C" ]

? ( Q([ "A", "B", 1:3, "C" ]) - Q(1:3) ).Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.02 second(s)
