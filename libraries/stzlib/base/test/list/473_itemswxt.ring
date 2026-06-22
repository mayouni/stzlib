# Narrative
# --------
# ItemsWXT: filter a list by a Where-condition lambda, returning the matching
# VALUES.
#
# ItemsWXT('{ @item >= 8 }') reads "items where the current item is >= 8" and
# projects back to the values themselves (vs FindAllItemsWXT, which returns the
# positions). From the source list every item >= 8 -- 8, 11, 11, 10, 8, 8 -- is
# kept, in list order. The WXT (eXTended) conditional-code form lets the
# predicate use @item directly; the lighter W form and the WF anonymous-function
# form (blocks 475/476) express the same idea.
#
# Extracted from stzlisttest.ring, block #473.

load "../../stzBase.ring"

pr()

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWXT( '{ @item >= 8 }' )
#--> [ 8, 11, 11, 10, 8, 8 ]

pf()
# Executed in 0.15 second(s).
