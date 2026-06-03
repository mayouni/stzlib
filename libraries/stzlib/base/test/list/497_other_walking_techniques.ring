# Narrative
# --------
# OTHER WALKING TECHNIQUES
#
# Extracted from stzlisttest.ring, block #497.
#ERR Error (R3) : Calling Function without definition: walkwhen

load "../../stzBase.ring"

pr()

StartProfiler()

StzListQ([ "A", "B", "C", "D", "E", "F", "G" ]) {

	// Walking the list from the position where a condition is verified

		? @@( WalkWhen( ' @item = "D" ' ) )
		#--> [ 4, 5, 6, 7 ]

		? @@( WalkWhenXT( ' @item = "D" ', :Forward, :WalkedItems ) )
		#--> [ "D", "E", "F", "G" ]

		? @@( WalkWhenXT( ' @item = "D" ', :Backward, :WalkedItems ) )
		#--> [ "D", "C", "B", "A" ]

	// Walking the list from the position where a condition is verified

		? @@( WalkBetween( 3, 5 ) )
		#--> [ 3, 4, 5 ]

		? @@( WalkBetweenIB( 3, 5, :WalkedItems ) )
		#--> [ "C", "D", "E" ]

		? @@( WalkBetweenIB( 5, 3, :WalkedItems ) )
		#--> [ "E", "D", "C" ]

	// Walking the list forth and back
		? @@( WalkForthAndBack() ) + NL
		#--> [ 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1 ]

		? @@( WalkForthAndBackXT(:Return = :WalkedItems) ) + NL
		#--> [ "A", "B", "C", "D", "E", "F", "G", "F", "E", "D", "C", "B", "A" ]


	// Walking the list back and forth
		? @@( WalkBackAndForth() ) + NL
		#--> [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7 ]

		? @@( WalkBackAndForthXT(:Return = :WalkedItems) ) + NL
		#--> [ "G", "F", "E", "D", "C", "B", "A", "B", "C", "D", "E", "F", "G" ]

	// Walking n steps forward
		? @@( WalkNForward(2) ) + NL
		#--> [ 1, 3, 5, 7 ]

		? @@( WalkNForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "E", "G" ]

	// Walking n steps backward
		? @@( WalkNBackward(2) ) + NL
		#--> [ 7, 5, 3, 1 ]

		? @@( WalkNBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "C", "A" ]

	// Walking n progressive steps forward
		? @@( WalkNMoreForward(2) ) + NL
		#--> [ 1, 3, 7 ]

		? @@( WalkNMoreForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "G" ]

	// Walking n progressive steps backward
		? @@( WalkNMoreBackward(2) ) + NL
		#--> [ 7, 5, 1 ]

		? @@( WalkNMoreBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "A" ]

	// Walking n steps forward and then n steps backward

		? @@( WalkForwardBackward(1, 1) )
		#--> [ ]

		? @@( WalkForwardBackward(1, 2) )
		#--> [ 2 ]

		? @@( WalkForwardBackwardXT(1, 2, :Return = :WalkedItems) )
		#--> [ "B" ]

		#--

		? @@( WalkForwardBackward(3, 1) )
		#--> [ 1, 4, 3, 6, 5 ]

		? @@( WalkForwardBackwardXT(3, 1, :Return = :WalkedItems) )
		#--> [ "A", "D", "C", "F", "E" ]

	// Walking n steps backward n steps forward

		? @@( WalkBackwardForward(1, 2) )
		#--> [ 6 ]

		? @@( WalkBackwardForwardXT(1, 2, :WalkedItems) )
		#--> [ "F" ]

		#--

		? @@( WalkBackwardForward(3, 2) )
		#--> [ 7, 4, 6, 3, 5, 2, 4 ]

		? @@( WalkBackwardForwardXT(3, 2, :WalkedItems) )
		#--> [ "G", "D", "F", "C", "E", "B", "D" ]

	// Walking n steps from the start and n steps from the end

		? @@( WalkNStartNEnd(1, 1) )
		#--> [ 1, 2, 6, 3, 5, 4 ]

		? @@( WalkNStartNEnd(2, 3) )
		#--> [ 1, 3, 4 ]

		? @@( WalkNStartNEndXT(2, 3, :WalkedItems) )
		#--> [ "A", "C", "D" ]

		#--

		? @@( WalkNEndNStart(1, 1) )
		#--> [ 7, 6, 1, 5, 2, 4, 3 ]

		? @@( WalkNEndNStartXT(1, 1, :WalkedItems) )
		#--> [ "G", "F", "A", "E", "B", "D", "C" ]

}

StopProfiler()

pf()
# Executed in 0.28 second(s) in Ring 1.21
