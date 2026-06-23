# Narrative
# --------
# Several named walkers over one list, configured three different ways.
#
# AddWalker accepts its parameters positionally (name, start, end, step) or
# via readable helpers in any mix:
#   * Walker1 -- StartingAt/EndingAt + NStepsATime(1): every position 1..10.
#   * Walker2 -- positional 6, 10 + [:NStepsATime, 3]: every 3rd from 6 -> 6, 9.
#   * Walker3 -- TakingNEqualMoves(3): 3 evenly-spaced stops over 1..10 ->
#     1, 5, 10.
# Walkers() lists all registered walkers. YieldWhileWalking(yielder, name)
# evaluates a yielder ("item"/"@item" is the current value) at each visited
# slot -- so different walkers feed different projections of the same list.
#
# Extracted from stzlisttest.ring, block #598.

load "../../stzBase.ring"

pr()

StzListQ([ "ring", "python", "ruby", "go", "rust", "lua", "perl", "php", "dart", "nim" ]) {

	AddWalker( :Walker1, StartingAt(1), EndingAt(10), NStepsATime(1) )
	AddWalker( :Walker2, 6, 10, [ :NStepsATime, 3 ] )
	AddWalker( :Walker3, StartingAt(1), EndingAt(10), TakingNEqualMoves(3) )

	? WalkedPositions( :By = :Walker2 )
	#--> [ 6, 9 ]

	? WalkedPositions( :By = :Walker3 )
	#--> [ 1, 5, 10 ]

	? NumberOfWalkedItems( :By = :Walker1 )
	#--> 10

	? YieldWhileWalking( '{ upper(item) }', :Walker2 )
	#--> [ "LUA", "DART" ]

	? YieldWhileWalking( '{ [ upper(item), StringContains(item, "r") ] }', :Walker3 )
	#--> [ [ "RING", 1 ], [ "RUST", 1 ], [ "NIM", 0 ] ]
}

pf()
# Executed in 0.03 second(s).
