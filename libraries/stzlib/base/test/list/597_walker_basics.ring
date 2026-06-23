# Narrative
# --------
# Named walkers: register a traversal over a list, then query it by name.
#
# AddWalker stores a NAMED walker on the list -- a start position, an end
# position, and a step. Once registered, the walk is queried by name:
#   WalkedItems / WalkedPositions     -- the items / positions it visits,
#   WalkedLastItem / WalkedLastPosition,
#   NumberOfWalkedItems,
#   YieldWhileWalking(yielder, name)  -- evaluate a yielder ("@item" is the
#                                        current value) at each visited slot.
# Here Walker1 walks all of "A":"J" one step at a time.
#
# Extracted from stzlisttest.ring, block #597.

load "../../stzBase.ring"

pr()

StzListQ( "A":"J" ) {
	AddWalker( :Named = :Walker1, :StartingAt = 1, :EndingAt = 10, :NStep = 1 )

	? WalkedItems( :By = :Walker1 )
	#--> [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" ]

	? WalkedPositions( :By = :Walker1 )
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

	? WalkedLastItem( :By = :Walker1 )
	#--> J

	? WalkedLastPosition( :By = :Walker1 )
	#--> 10

	? NumberOfWalkedItems( :By = :Walker1 )
	#--> 10

	? YieldWhileWalking( 'type(@item)', :Walker1 )
	#--> [ "STRING", "STRING", "STRING", "STRING", "STRING",
	#     "STRING", "STRING", "STRING", "STRING", "STRING" ]
}

pf()
# Executed in 0.02 second(s).
