# Narrative
# --------
# ItemsW: filter a list by a where-condition, returning the matching VALUES.
#
# ItemsW('{ @item >= 8 }') reads "items where the current item is >= 8" and
# projects back to the values themselves (vs FindW, which returns their
# positions). From the source list every item >= 8 -- 8, 11, 11, 10, 8, 8 --
# is kept, in list order. W is the single conditional form: the predicate
# uses @item directly and is engine-evaluated (no eval); the WF family is
# the anonymous-function alternative for full Ring logic.
#
# Extracted from stzlisttest.ring, block #473.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? o1.ItemsW( '{ @item >= 8 }' )
#--> [ 8, 11, 11, 10, 8, 8 ]

pf()
# Executed in 0.15 second(s).
