load "stzlib.ring"


/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.ExecutableSection()
	#--> [ 4, -4 ]

StopProfiler()
#--> Executed in 0.29 seconds seconds.

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.TranspiledFor(:stzList)
	#--> This[ @i - 3 ] = This[ @i + 3 ] and @i = 10

? NL + "--- " + ELapsedTime() + NL
#--> Transpiling takes more than 0.35s
#--> TODO: should be optimised

	? o1.ExecutableSection()
	#--> [ 4, -4 ]

StopProfiler()

/*----------
*/
o1 = new stzCCode('{ This[ @i ] = This[ @i + 3 ] }')
? o1.TranspiledFor(:stzList)
#--> This[ @i ] = This[ @i + 3 ]

? o1.ExecutableSection()
#--> [ 1, -4 ]

/*----------

o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.TranspiledFor(:stzList)
#--> This[ @i - 3 ] = This[ @i + 3 ]

? o1.ExecutableSection()
#--> [ 4, -4 ]

/*----------

o1 = new stzCCode('{ @item = @NextItem }')

? o1.TranspiledFor(:stzList)
#--> @item = This[ @i+1 ]

? o1.ExecutableSection()
#--> [ 1, -2 ]

/*----------

o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
? o1.TranspiledFor(:stzListOfNumbers)
#--> @number = This[ @i - 1 ] + 1

? o1.ExecutableSection()
#--> [ 2, :Last ]

/*----------

o1 = new stzCCode('{ This[ @i - 5 ] = This[ @i - 3 ] }')
? o1.TranspiledFor(:stzListOfNumbers)
#--> @number = This[ @i - 1 ] + 1

? o1.ExecutableSection()
#--> [ 5, :Last ]

/*----------

o1 = new stzCCode('{ @number = -@number }')
? o1.TranspiledFor(:stzListOfStrings)
#--> @string = - @string
? o1.ExecutableSection()
#--> [ 1, :Last ]

/*----------

o1 = new stzCCode('Q( @EachChar ).IsUppercase()')
? o1.TranspiledFor(:stzListOfNumbers)
#--> Q( @number ).IsUppercase()
? o1.ExecutableSection()
#--> [ 1, :Last ]

/*----------

o1 = new stzCCode('{ This[ @NextPosition ] = This[ @CurrentPosition ] + "O" }')
? o1.TranspiledFor(:stzList)
#--> This[ ( @i + 1 ) ] = This[ @i ] + "O"

? o1.ExecutableSection()
#--> [ 1, -2 ]

/*----------
*/
o1 = new stzCCode('{ Q(This[ @NextPosition ]).HasDifferentCaseAs( This[ @CurrentPosition ] ) }')
? o1.TranspiledFor(:stzString)
#--> Q(This[ ( @i + 1 ) ]).HasDifferentCaseAs( This[ @i ] )

? o1.ExecutableSection()
#--> [ 1, -2 ]
