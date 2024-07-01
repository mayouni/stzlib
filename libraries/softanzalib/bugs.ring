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

/*-----
*/
pron()

o1 = new stzString( "IIIiiiMMMmmmAAA" )
? @@( o1.FindPartsWXTZZ('Q(@SubString).IsLowercase()'))

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

