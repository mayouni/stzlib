# Narrative
# --------
# Scanning a list with a boolean anonymous function via the WF family.
#
# Each *WF method walks the list and keeps the items where the supplied
# func returns TRUE -- here the predicate Q(x).IsOneOfThese([2,4,6]) marks
# values that belong to a target set. FindWF reports the matching positions,
# ItemsWF the matching values (with repeats), UniqueItemsWF the distinct
# matches, and ItemsAndTheirPositionsWF groups each distinct matched value
# with the list of positions where it occurs. The shared predicate keeps the
# four views consistent: same filter, four different projections of the hit set.
#
# Extracted from stzlisttest.ring, block #475.

load "../../stzBase.ring"

pr()

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 8 ])

? o1.FindWF( func x { return Q(x).IsOneOfThese([ 2, 4, 6]) } )
#--> [ 1, 3, 5, 8, 9, 12 ]

? o1.ItemsWF( func x { return Q(x).IsOneOfThese([ 2, 4, 6]) } )
#--> [ 2, 2, 2, 4, 2, 2 ]

? o1.UniqueItemsWF( func x { return Q(x).IsOneOfThese([ 2, 4, 6]) } )
#--> [ 2, 4 ]

? @@NL( o1.ItemsAndTheirPositionsWF( func x { return Q(x).IsOneOfThese([ 2, 4, 6]) } ) )
#--> [
#	[ 2, [ 1, 3, 5, 9, 12 ] ], 
#	[ 4, [ 8 ] ]
#    ]

pf()
# Executed in 0.56 second(s) in Ring 1.21
# Executed in 0.69 second(s) in Ring 1.19
