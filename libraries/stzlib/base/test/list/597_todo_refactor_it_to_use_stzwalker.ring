# Narrative
# --------
# TODO: refactor it to use stzWalker
#
# Extracted from stzlisttest.ring, block #597.
#ERR Error (R24) : Using uninitialized variable: @awalkers

load "../../stzBase.ring"


pr()

? Q(5).IsBetween(2, 7)

StzListQ( "A":"J" ) {
	AddWalker( :Named = :Walker1, :StartingAt = 1, :EndingAt = 10, :NStep = 1 )
	? WalkedItems( :By = :Walker1 )
	? WalkedPositions( :By = :Walker1 )
	? WalkedLastItem( :By = :Walker1 )
	? WalkedLastPosition( :By = :Walker1 )
	? NumberOfWalkedItems( :By = :Walker1 )

	? Yield( 'type(@item)', :WhileWalkingListBy = :Walker1 )
}

pf()
