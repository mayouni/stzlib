nReste = 128920 % 12
nResult = (128920 - nReste) / 12

? nResult
? nReste

/*
load "stzlib.ring"

StzStringQ("Ringorialand") {
	# Get the default returned value if we provide
	# no params at all
	? dftRange() # --> "Ringorialand"
	? ""

	# How many params are required?
	? infRange()[:NumberOfParams] # --> 2

	# Show me these params please
	ListShow( infRange()[:Params] ) # --> See output window

	# Give me an example in using this function
	? expRange() # --> See output window
	? ""

	# Call the function with random params
	? rndRange()
	? ""
	# Run the test suite
	? tstRange() # --> SUCCESS! (3/3)
	? ListShow( tstRangeXT()[ :TestCases ] )
}

/* TODO --> More general Show() function for all types:
	- numbers
	- strings
	- lists, hashlists, sets, grids, tables, etc
	- objects
*/

/*
StzStringQ("ring programming language") {
	? Range(6, 11)
	? nmdRange([])
	? ""
	? nmdRange([ :Start = 6, :Range = 11 ])
	? nmdRange([ :Range = 11, :Start = 6 ])
	? ""
	? nmdRange([ :Range = 4 ])
	? nmdRange([ :Start = 6 ])
	? ""
	? infRange()[:Syntax]
	? infRange()[:Description]
	? ""
	? infRange()[:NumberOfParams]
	? ListShow( infRange()[:Params][1] )
}

//? IsRangeParamList([ :Start = 1, :Range = 3 ])
