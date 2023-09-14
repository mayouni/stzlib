load "stzlib.ring"

/*------------- TODO: fix errors of @@() with objects
*/
pron()

? @@( StzNullObjectQ() )
#--> NULL

? @@([ StzNullObjectQ() ])
#--> [ @noname ]

? @@([ 1:3, StzNullObjectQ(), "a":"b", StzFalseObjectQ() ])
#!--> [ [ 1, 2, 3 ], @noname, [ "a", "b" ], @noname ]

proff()

/*-------------
*/
pron()

o1 = new stzList([ 1, 1:5, "hi!", StzNullObjectQ(), [ "a", "b" ] ])

? @@( o1.NListified(3) )
#--> [
#	[ 1, NULL, NULL ],
#	[ 1, 2, 3 ],
#	[ "hi!", NULL, NULL ],
#	[ @noname, NULL, NULL ],
#	[ "a", "b", NULL ]
# ]

proff()

/*-------------

pron()

? Q(['alone']).IsSingle()
#--> TRUE

o1 = new stzList([ 1, ['alone1'], 3, ['alone2'], 5, ['alone2'], 7:9 ])

? o1.ContainsSingles()
#--> TRUE

? @@( o1.FindSingles() )
#--> [ 2, 4, 6 ]

? @@( o1.Singles() )
#--> [ [ "alone1" ], [ "alone2" ], [ "alone2" ] ]

? @@( o1.SinglesU() )
#--> [ [ "alone1" ], [ "alone2" ] ]

? @@( o1.SinglesZ() ) + NL
#--> [
#	[ [ "alone1" ], [ 2 ] ],
#	[ [ "alone2" ], [ 4, 6 ] ]
# ]

? @@( o1.Singlified() )
#--> [ [ 1 ], [ "alone1" ], [ 3 ], [ "alone2" ], [ 5 ], [ "alone2" ], [ 7 ] ]

proff()

/*-------------

pron()

o1 = new stzList([ 1, 2, [ "a", "b" ], 4, [ "c", "d"], [ "a", "b" ] ])
? o1.ContainsPairs()
#--> TRUE

//? o1.FindThem()

? @@( o1.FindPairs() )
#--> [ 3, 5, 6 ]

? @@( o1.Pairs() )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "a", "b" ] ]

? @@( o1.PairsU() )
#--> [ [ "a", "b" ], [ "c", "d" ] ]

? @@( o1.PairsZ() ) + NL
#--> [
#	[ [ "a", "b" ], [ 3, 6 ] ],
#	[ [ "c", "d" ], [ 5 ] ]
# ]

? @@( o1.Pairified() )
#--> [
#	[ 1, NULL ], [ 2, NULL ], [ "a", "b" ],
#	[ 4, NULL ], [ "c", "d" ], [ "a", "b" ]
# ]

proff()

/*-------------

pron()

o1 = new stzString("---♥♥...**---")

? o1.SubStringComesBetween("...", "♥♥", "**")
#--> TRUE

? o1.SubStringComesBetween("...", "**", "♥♥")
#--> TRUE

proff()

/*-------------
*/
pron()

o1 = new stzString("123♥♥678**123♥♥678")

? o1.SubStringComesBefore("♥♥", :Position = 6)
#--> TRUE

? o1.SubStringComesBeforePosition("♥♥", 6)
#--> TRUE

? o1.SubStringComesBefore("♥♥", :SubString = "**")
#--> TRUE

? o1.SubStringComesBeforeSubString("♥♥", "**")
#--> TRUE

#--

? o1.SubStringComesAfter("♥♥", :Position = 3)
#--> TRUE

? o1.SubStringComesAfterPosition("♥♥", 3)
#--> TRUE

? o1.SubStringComesAfter("**", :SubString = "♥♥")
#--> TRUE

? o1.SubStringComesAfterSubString("**", "♥♥")
#--> TRUE

#--

? o1.SubStringComesBetween("♥♥", :Positions = 3, :And = 6)
#--> TRUE

? o1.SubStringComesBetweenPositions("♥♥", 3, 6)
#--> TRUE

? o1.SubStringComesBetween("678", :SubStrings = "♥♥", :And = "**")
#--> TRUE

? o1.SubStringComesBetweenSubStrings("678", "**", "♥♥")
#--> TRUE

#--

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> TRUE

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> TRUE

proff()

/*-----

pron()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----


pron()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

proff()
# Executed in 0.05 second(s)
