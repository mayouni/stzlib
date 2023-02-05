load "stzlib.ring"

/*----------

pron()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
? o1.Between("<<<",">>>")
#--> [ "ring", "softanza" ]

proff()

/*----------

pron()

o1 = new stzString('{ This[@i] = This[@i + 1] + 5 }')
? @@S( o1.FindBetweenAsSectionsXT("[", :And = "]") )
#--> [ [ 7, 10 ], [ 18, 25 ] ]

? @@S( o1.BetweenXT("[", :And = "]") )
#--> [ "[@i]", "[@i + 1]" ]

? @@S( o1.FindBetweenAsSections("[", "]") )
#--> [ [8, 9], [19, 24] ]

? @@S( o1.Between("[", :And = "]") )
#--> [ "@i", "@i + 1" ]

? o1.NumbersAfter("@i")
#--> [ +1, +5 ]

proff()
# Executed in 0.32 second(s)

/*----------

pron()

o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
? o1.NumbersAfter("@i")
#--> [ "-3", "+3", "10" ]

proff()
# Executed in 0.26 second(s)

/*---------- TODO: Add stzTest class

StartProfiler()

StzTestQ() {

	@Class       = :stzCCode
	@Function    = :ExecutableSection
	@Description = ''

	@Code = '

	o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.ExecutableSection()'

	@Result = '
	#--> [ 4, -4 ]
	'

	Run()

	? Output()
	#--> [ 4, -4 ]

	? Succeed()
	#--> TRUE

	? Failed()
	#--> FALSE
}

StopProfiler()
# Executed in 0.35 seconds seconds.

/*----------

StartProfiler()
	
	o1 = new stzCCode('{ This[ @i-3 ] = This[ @i + 3 ] and @i = 10 }')
	? o1.ExecutableSection()
	#--> [4, -4]
	
StopProfiler()
# Executed in 0.14 second(s)

/*----------

StartProfiler()

o1 = new stzString('This[@i] = This[@i + 1] + @i - 2')
? o1.NumbersAfter("@i")
#--> [ "+1", "-2" ]

StopProfiler()
# Executed in 0.16 second(s)

/*----------

StartProfiler()

# When you use keywords other then This[@i] an alike in your
# conditional code, then you must use ExecutableSectionXT()
# and not ExecutableSection(). Otherwise results are not
# guaranteed to be correct. Here is an example:

	o1 = new stzCCode('{ @item = @NextItem + 5 }')
	? o1.ExecutableSection()
	#--> [ 1, :Last ] Which is wrong!

# To be accurate, and because we used @item and @NextItem in
# our conditional code above, we can get the correct executable
# section by using the ...XT() form like this:

	? o1.ExecutableSectionXT()
	#--> [ 1, -2 ]

# We can check this visually by seeing the transpiled code
# made by ExecutableSectionXT() in the background:

	? o1.Transpiled()
	#--> This[@i] = This[@i + 1] + 5

StopProfiler()
# Executed in 0.20 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
	? o1.ExecutableSectionXT()
	#--> [ 2, :Last ]

StopProfiler()
# Executed in 0.18 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 5 ] = This[ @i - 3 ] }')
	? o1.ExecutableSection()
	#--> [ 5, :Last ]

StopProfiler()
# Executed in 0.16 second(s)

/*----------

StartProfiler()

# Whenever possible, write a conditional code using only the This[]
# and @i keywords. This will always lead to a better performance:

	o1 = new stzCCode('{ This[@i] = -This[@i] }')
	? o1.ExecutableSection()
	#--> [ 1, :Last ]
	# Executed in 0.06 second(s)

	o1 = new stzCCode('{ @number = -@number }')
	? o1.ExecutableSectionXT()
	#--> [ 1, :Last ]
	# Executed in 0.16 second(s)

StopProfiler()
# Executed in 0.21 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('Q(@EachChar).IsUppercase()')
	? o1.Transpiled()
	#-->Q( This[@i] ).IsUppercase()

	? o1.ExecutableSection()
	#--> [ 1, :Last ]

StopProfiler()
# Executed in 0.21 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @NextPosition ] = This[ @CurrentPosition ] + "O" }')
	? o1.ExecutableSectionXT()
	#--> [ 1, -2 ]

StopProfiler()
# Executed in 0.25 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('{
		Q(This[ @NextPosition ]).HasDifferentCaseThen( This[ @CurrentPosition ] )
	}')

	? o1.ExecutableSectionXT()
	#--> [ 1, -2 ]

StopProfiler()
# Executed in 0.26 second(s)
