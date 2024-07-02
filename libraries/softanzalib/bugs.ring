load "stzlib.ring"

/*====

pron()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitAtCharsW( 'Q(This[@i]).IsLowercase()' ) )
	#--> [ "MMM", "AA", "NN" ]
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitAtCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMM", "AA", "NN" ]
	# Executed in 0.24 second(s)

proff()
# Executed in 0.34 second(s)

/*-----

pron()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitAfterCharsW( 'Q(This[@i]).IsLowerCase()' ) ) + NL
	#--> [ "MMMi", "AAi", "NN" ]
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitAfterCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMMi", "AAi", "NN" ]
	# Executed in 0.24 second(s)

proff()
# Executed in 0.33 second(s)

/*-----

pron()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitBeforeCharsW( 'Q(This[@i]).IsLowerCase()' ) ) + NL
	#--> v
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitBeforeCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMM", "iAA", "iNN" ]
	# Executed in 0.24 second(s)

proff()
# Executed in 0.33 second(s)

/*====

pron()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive : you can use the QSubString keyword

	//? @@( o1.PartsWXT('Q(@SubString).IsLowercase()'))
	#--> [ "iii", "mmm", "ee" ]
	# Takes 0.29 second(s)

# More performant : you use only This[@i]-like keywords

	? @@( o1.PartsW(' Q(This[@i]).IsLowercase() ') )
	# Takes 0.22 second(s)

proff()
# Executed in 0.49 second(s)

/*------

pron()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive (takes 0.82 seconds)

	? @@( o1.PartsWXT('Q(@SubString).IsLowercase()') ) + NL
	#--> [ "iii", "mmm", "ee" ]
	
	? @@( o1.FindPartsWXT('Q(@SubString).IsLowercase()')) + NL
	#--> [ 4, 10, 16 ]
	
	? @@( o1.FindPartsWXTZZ('Q(@SubString).IsLowercase()')) + NL
	#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 17 ] ]

# More performant (takes 0.65 seconds)

	? @@( o1.PartsW('Q(This[@i]).IsLowercase()') ) + NL
	#--> [ "iii", "mmm", "ee" ]
	
	? @@( o1.FindPartsW('Q(This[@i]).IsLowercase()')) + NL
	#--> [ 4, 10, 16 ]
	
	? @@( o1.FindPartsWZZ('Q(This[@i]).IsLowercase()'))
	#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 17 ] ]

proff()
# Executed in 1.35 second(s)

/*------

pron()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive #NOTE the use of natural keyword ~> @SubString
# ~> requires transpiling of @SubString (and others like @NextSubString,
# @PreviousSubString, etc) in the background to This[@i] keyword

	? @@( o1.SplitAtSubStringsWXT( :where = 'Q(@SubString).IsLowercase()' ) ) + NL
	#--> [ "III", "MMM", "AAA" ]
	# Executed in 0.35 second(s)

# More performant (takes 0.36 second) #NOTE difference will be more relevant with large data
# You can use only This[@i] keyword to express the conditional expression

	? @@( o1.SplitAtSubStringsW( :where = 'Q(This[@i]).IsLowercase()' ) )
	#--> [ "III", "MMM", "AAA" ]
	# Executed in 0.31 second(s)

proff()
# Executed in 0.54 second(s)

/*------

pron()
                   
#                     ✁|   ✁|
o1 = new stzString( "ABCabcEFGijHI" )
#                    \_/\____/\__/

# More expressive

	? o1.SplitBeforeSubStringsWXT( 'Q(@SubString).IsLowercase()' )
	#--> [ "ABC", "abcEFG", "ijHI" ]
	# Executed in 0.35 second(s)

# More performant (in large strings and comlex split conditions)

	? o1.SplitBeforeSubStringsW( 'Q(This[@i]).IsLowercase()' )
	#--> [ "ABC", "abcEFG", "ijHI" ]
	# Executed in 0.26 second(s)

proff()
# Executed in 0.48 second(s)

/*-----

*/
pron()
                   
#                        ✁|  ✁|
o1 = new stzString( "ABCabcEFGijHI" )
#                    \____/\___/\/

# More expressive

	? o1.SplitAfterSubStringsWXT( 'Q(@SubString).IsLowercase()' )
	#--> [ "ABCabc", "EFGij", "HI" ]
	# Executed in 0.39 second(s)

# More performant (in large strings and comlex split conditions)

	? o1.SplitAfterSubStringsW( 'Q(This[@i]).IsLowercase()' )
	#--> [ "ABCabc", "EFGij", "HI" ]
	# Executed in 0.26 second(s)

proff()
# Executed in 0.49 second(s)

/*-----
*/

