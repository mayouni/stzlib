# Narrative
# --------
# FindAll and FindFirst locate a nested-list element by deep value-equality.
#
# The host list holds compound items, including the nested element
# [3, [1], 4] which appears twice (at positions 2 and 6). FindAll
# returns every matching position as a list ([2, 6]), while FindFirst
# returns only the earliest one (2). The match is by full structural
# value, so the inner [1] sublist must line up exactly -- Softanza
# compares items as whole values rather than by identity or by a
# flattened scan, which is what lets a list-shaped needle be found
# inside a list of lists.
#
# Extracted from stzlisttest.ring, block #377.

load "../../stzBase.ring"

pr()

o1 = new stzList([ [1,2], [3, [1], 4], [5,6], [ 2, 10 ], [3,4], [3, [1], 4] ])

? o1.FindAll( [3, [1], 4] )
#--> [2, 6]

? o1.FindFirst( [3, [1], 4] )
#--> 2

pf()
# Executed in 0.02 second(s).
