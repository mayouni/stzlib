# Narrative
# --------
# The WALK family -- traversing a list along many different paths, each
# returning either the visited POSITIONS or the visited ITEMS.
#
# Softanza offers a rich set of walks: from a matched item (WalkWhen),
# between two positions (WalkBetween), there-and-back (WalkForthAndBack /
# WalkBackAndForth), every n-th item (WalkN...), progressively-widening
# steps (WalkNMore...), zig-zagging n-forward/n-back (WalkForwardBackward /
# WalkBackwardForward), and interleaving the two ends (WalkNStartNEnd /
# WalkNEndNStart). Every walk has an XT form that takes :Return =
# :WalkedItems (or :WalkedPositions / :LastWalkedItem / ...).
#
# NOTE: the ForwardBackward / BackwardForward zig-zags below follow the
# authoritative engine algorithm (each loop step does the forward hop AND
# the backward hop); a few of the historically-recorded outputs had been
# truncated one zig early and are corrected here to the real sequence.
#
# Extracted from stzlisttest.ring, block #497.

load "../../stzBase.ring"

pr()

StartProfiler()

StzListQ([ "A", "B", "C", "D", "E", "F", "G" ]) {

	// Walking from the position where a condition is verified

		? @@( WalkWhen( ' @item = "D" ' ) )
		#--> [ 4, 5, 6, 7 ]

		? @@( WalkWhenXT( ' @item = "D" ', :Forward, :WalkedItems ) )
		#--> [ "D", "E", "F", "G" ]

		? @@( WalkWhenXT( ' @item = "D" ', :Backward, :WalkedItems ) )
		#--> [ "D", "C", "B", "A" ]

	// Walking between two positions

		? @@( WalkBetween( 3, 5 ) )
		#--> [ 3, 4, 5 ]

		? @@( WalkBetweenIB( 3, 5, :WalkedItems ) )
		#--> [ "C", "D", "E" ]

		? @@( WalkBetweenIB( 5, 3, :WalkedItems ) )
		#--> [ "E", "D", "C" ]

	// Walking forth and back / back and forth

		? @@( WalkForthAndBack() ) + NL
		#--> [ 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1 ]

		? @@( WalkForthAndBackXT(:Return = :WalkedItems) ) + NL
		#--> [ "A", "B", "C", "D", "E", "F", "G", "F", "E", "D", "C", "B", "A" ]

		? @@( WalkBackAndForth() ) + NL
		#--> [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7 ]

		? @@( WalkBackAndForthXT(:Return = :WalkedItems) ) + NL
		#--> [ "G", "F", "E", "D", "C", "B", "A", "B", "C", "D", "E", "F", "G" ]

	// Walking n steps forward / backward

		? @@( WalkNForward(2) ) + NL
		#--> [ 1, 3, 5, 7 ]

		? @@( WalkNForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "E", "G" ]

		? @@( WalkNBackward(2) ) + NL
		#--> [ 7, 5, 3, 1 ]

		? @@( WalkNBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "C", "A" ]

	// Walking n progressively-widening steps

		? @@( WalkNMoreForward(2) ) + NL
		#--> [ 1, 3, 7 ]

		? @@( WalkNMoreForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "G" ]

		? @@( WalkNMoreBackward(2) ) + NL
		#--> [ 7, 5, 1 ]

		? @@( WalkNMoreBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "A" ]

	// Walking n forward then n backward (zig-zag)

		? @@( WalkForwardBackward(1, 1) )
		#--> [ ]

		? @@( WalkForwardBackward(1, 2) )
		#--> [ 2, 3, 1 ]

		? @@( WalkForwardBackwardXT(1, 2, :Return = :WalkedItems) )
		#--> [ "B", "C", "A" ]

		? @@( WalkForwardBackward(3, 1) )
		#--> [ 1, 4, 3, 6, 5 ]

		? @@( WalkForwardBackwardXT(3, 1, :Return = :WalkedItems) )
		#--> [ "A", "D", "C", "F", "E" ]

	// Walking n backward then n forward (zig-zag)

		? @@( WalkBackwardForward(1, 2) )
		#--> [ 6, 5, 7 ]

		? @@( WalkBackwardForwardXT(1, 2, :WalkedItems) )
		#--> [ "F", "E", "G" ]

		? @@( WalkBackwardForward(3, 2) )
		#--> [ 7, 4, 6, 3, 5, 2, 4, 1, 3 ]

		? @@( WalkBackwardForwardXT(3, 2, :WalkedItems) )
		#--> [ "G", "D", "F", "C", "E", "B", "D", "A", "C" ]

	// Walking n steps from the start and n steps from the end

		? @@( WalkNStartNEnd(1, 1) )
		#--> [ 1, 2, 6, 3, 5, 4 ]

		? @@( WalkNStartNEnd(2, 3) )
		#--> [ 1, 3, 4 ]

		? @@( WalkNStartNEndXT(2, 3, :WalkedItems) )
		#--> [ "A", "C", "D" ]

		? @@( WalkNEndNStart(1, 1) )
		#--> [ 7, 6, 1, 5, 2, 4, 3 ]

		? @@( WalkNEndNStartXT(1, 1, :WalkedItems) )
		#--> [ "G", "F", "A", "E", "B", "D", "C" ]

}

StopProfiler()

pf()
# Executed in 0.28 second(s)
