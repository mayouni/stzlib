load "stzlib.ring"

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<♥♥♥>>...")

/*
? @@S( o1.FindAnyBetweenAsSectionsS("<<", ">>", :StartingAt = 10) )
#--> [ [ 16, 17 ], [ 25, 27 ] ]

? @@S( o1.FindAnyBetweenS("<<", ">>", :StartingAt = 10) )
#--> [ 16, 25 ]

? @@S( o1.BetweenS("<<", ">>", :StartingAt = 10) )
#--> [ "★★", "♥♥♥" ]
*/
? @@S( o1.FindAnyBetweenAsSectionsSD( "<<", ">>", :StartingAt = :LastChar, :Backward ) )
#--> [ [ 25, 27 ], [ 16, 17 ], [ 6, 8 ] ]

//? @@S( o1.BetweenSD("<<", ">>", :StartingAt = 10, :Forward) )

//? @@S( o1.BetweenSZ("<<", ">>", :StartingAt = 10) )

proff()
