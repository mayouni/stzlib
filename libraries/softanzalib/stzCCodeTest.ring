load "stzlib.ring"


/*----------
*/
StartProfiler()

	o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.ExecutableSection()
	#--> [ 4, -4 ]

StopProfiler()
#--> Executed in 0.27 seconds seconds.

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.Transpiled()
	#--> This[ @i - 3 ] = This[ @i + 3 ] and @i = 10

StopProfiler()
#--> Executed in 0.05 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ @item = @NextItem }')
	
	? o1.Transpiled()
	#-->  This[@i] = This[@i + 1] 

? ElapsedTime()
#--> 0.05 second(s)

	? o1.ExecutableSection()
	#--> [ 1, -2 ]

StopProfiler()
#--> Executed in 0.15 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
	? o1.Transpiled()
	#--> This[@i] = This[@i - 1] + 1
	
? ElapsedTime()
#--> 0.05 second(s)

	? o1.ExecutableSection()
	#--> [ 2, :Last ]

StopProfiler()
#--> Executed in 0.16 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 5 ] = This[ @i - 3 ] }')
	? o1.Transpiled()
	#--> This[ @i - 5 ] = This[ @i - 3 ] 
	
? ElapsedTime()
#--> 0.05 second(s)

	? o1.ExecutableSection()
	#--> [ 5, :Last ]

StopProfiler()

/*----------

StartProfiler()

	o1 = new stzCCode('{ @number = -@number }')
	? o1.Transpiled()
	#--> This[@i] = - This[@i]

? ElapsedTime()
#--> 0.05 second(s)

	? o1.ExecutableSection()
	#--> [ 1, :Last ]

StopProfiler()
#--> Executed in 0.14 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('Q( @EachChar ).IsUppercase()')
	? o1.Transpiled()
	#-->Q( This[@i] ).IsUppercase()

? ElapsedTime()
#--> 0.06 second(s)

	? o1.ExecutableSection()
	#--> [ 1, :Last ]

StopProfiler()
#--> Executed in 0.14 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @NextPosition ] = This[ @CurrentPosition ] + "O" }')
	? o1.Transpiled()
	#--> This[ @i + 1 ] = This[ @i ] + "O"
	
? ElapsedTime()
#--> 0.06 second(s)

	? o1.ExecutableSection()
	#--> [ 1, -2 ]

StopProfiler()
#--> Executed in 0.27 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{
		Q(This[ @NextPosition ]).HasDifferentCaseAs( This[ @CurrentPosition ] )
	}')

	? o1.Transpiled()
	#--> Q(This[ @i + 1 ]).HasDifferentCaseAs( This[ @i ] )
	
? ElapsedTime()
#--> 0.06 second(s)

	? o1.ExecutableSection()
	#--> [ 1, -2 ]

StopProfiler()
