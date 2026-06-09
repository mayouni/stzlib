# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #475.
#ERR exit 1

load "../../stzBase.ring"

pr()

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 8 ])

? o1.FindWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 1, 3, 5, 8, 9, 12 ]

? o1.ItemsWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 2, 2, 4, 2, 2 ]

? o1.UniqueItemsWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 4 ]

? @@NL( o1.ItemsAndTheirPositionsWXT(:Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }') )
#--> [
#	[ 2, [ 1, 3, 5, 9, 12 ] ], 
#	[ 4, [ 8 ] ]
#    ]

pf()
# Executed in 0.56 second(s) in Ring 1.21
# Executed in 0.69 second(s) in Ring 1.19
