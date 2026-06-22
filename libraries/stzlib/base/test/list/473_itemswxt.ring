# Narrative
# --------
# ItemsWXT: filter a list by a Where-condition lambda, returning the matching
# VALUES -- currently a BUG STUB.
#
# The idiom: ItemsWXT('{ @item >= 8 }') reads "items where the current item is
# >= 8", projecting back to the values (vs FindAllItemsWXT, which returns
# positions), so the intended result is [ 8, 11, 11, 10, 8, 8 ]. As written this
# currently CRASHES: the WXT path's @i-cursor detection matches the "@i" prefix
# of "@item", wrongly entering the positional branch, which then calls a regex
# matchxt with bad options ("pacOptions must be a list of strings"). Root cause
# is in the W-conditional ExecutableSection/@i handling -- the same W-evaluator
# subsystem as the FindWXT @NextItem gap. Left as a documented stub pending that
# fix (the WF-function form works -- see 475/476).
#
# Extracted from stzlisttest.ring, block #473.
#ERR Incorrect param type! pacOptions must be a list of strings.  (WXT @i-vs-@item detection bug)

load "../../stzBase.ring"

pr()

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWXT( '{ @item >= 8 }' )
#--> [ 8, 11, 11, 10, 8, 8 ]

pf()
# Executed in 0.15 second(s).
