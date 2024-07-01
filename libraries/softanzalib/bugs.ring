load "stzlib.ring"

/*====

pron()

o1 = new stzString( "MMMiAAiNN" )
? @@( o1.SplitAtCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
#--> [ "MMM", "AA", "NN" ]

proff()
# Executed in 0.23 second(s)

/*-----

pron()

o1 = new stzString( "MMMiAAiNN" )
? @@( o1.SplitAfterCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
#--> [ "MMMi", "AAi", "NN" ]

proff()
# Executed in 0.23 second(s)

/*-----

pron()

o1 = new stzString( "MMMiAAiNN" )
? @@( o1.SplitBeforeCharsWXT( :where = 'Q(@Char).IsLowercase()' ) )
#--> [ "MMM", "iAA", "iNN" ]

proff()
# Executed in 0.27 second(s)

/*====

pron()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive : you can use the QSubString keyword

? @@( o1.PartsWXT('Q(@SubString).IsLowercase()'))
#--> [ "iii", "mmm", "ee" ]
# Takes 0.29 second(s)

# More performant : you use only This[@i]-like keywords

? @@( o1.PartsW(' Q(This[@i]).IsLowercase() ') )
# Takes 0.23 second(s)

proff()
# Executed in 0.53 second(s)

/*------
*/
pron()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

? @@( o1.PartsWXT('Q(@SubString).IsLowercase()') ) + NL
#--> [ "iii", "mmm", "ee" ]

? @@( o1.FindPartsWXT('Q(@SubString).IsLowercase()')) + NL
#--> [ 4, 10, 16 ]

? @@( o1.FindPartsWXTZZ('Q(@SubString).IsLowercase()'))
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 17 ] ]

proff()
# Executed in 0.82 second(s)

/*------

//? @@( o1.SplitAtSubStringsWXT( :where = 'Q(@SubString).IsLowercase()' ) )
#--> [ "III", "MMM", "AAA" ]

proff()

/*------

o1 = new stzString( "ABCabcEFGijHI" )
? o1.SplitBeforeSubStringsWXT( 'Q(@SubString).IsLowercase()' )
#--> [ "ABC", "EFG", "HI" ]

proff()

/*-----


/*-----
*/

