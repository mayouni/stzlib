load "../stzmax.ring"

/*---
*/
pr()

rx = new stzRegex("@i[+-]\d+|@i")
? rx.Match("@i-2 @i+1 @i")
? @@( rx.Matches() ) + NL
#--> [ "@i-2", "@i+1", "@i" ]

rx = new stzRegex("(?<=@i)([+-]\d+)")
? rx.Match("@i-2 @i+1 @i")
? @@( rx.Matches() ) + NL
#--> [ "@i-2", "@i+1", "@i" ]

pf()

/*--------
*/
pr()

? @@( Q("This[@i+1]").NumbersAfter("@i") )
#--> [ "1" ]

? @@( Q("@i-2@i+1]").NumbersAfter("@i") )

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--------
*/
pr()

? StzCCodeQ(' This[@i] = This[@i+1] ').ExecutableSection()
#--> [ 1, -1 ]
#ERROR : returned [ 1 : "last" ]

pf()
# Executed in 0.03 second(s) in Ring 1.21

/*-------- #narration BETWEEN vs BOUNDEDBY

pr()
#                         7  10
# BETWEEN ~>           xxx[--v----------------]xxx
o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
# BOUNDEDBY ~>         xxx[--]xxx   xxx[------]xxx
        
# In Softanza, BETWEEN returns the substring between
# two substrings or positions

? o1.Between("<<<", ">>>") # Or SubStringBetween()
#--> "ring>>>___<<<softanza"

? o1.Between(6, 11) + NL # Equivalent to Section(7, 10)
#--> "ring"

# But BOUNDEDBY returns the substrings bounded by
# two other substrings, like this:

? o1.BoundedBy([ "<<<", ">>>" ])
#--> [ "ring", "softanza" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*----------

pr()

o1 = new stzString('{ This[@i] = This[@i + 1] + 5 }')
? @@( o1.FindSubStringsBoundedByIBZZ([ "[", "]" ]) )
#--> [ [ 7, 10 ], [ 18, 25 ] ]

? @@( o1.SubStringsBoundedByIB([ "[", "]" ]) )
#--> [ "[@i]", "[@i + 1]" ]

? @@( o1.FindAnySubStringBoundedByZZ([ "[", "]" ]) )
#--> [ [8, 9], [19, 24] ]

? o1.NumbersAfter("@i")
#--> [ "+1", "+5" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.07 second(s) in ring 1.21
# Executed in 0.29 second(s) in ring 1.17

/*----------

pr()

o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
? o1.NumbersAfter("@i")
#--> [ "-3", "+3", "10" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.11 second(s) in ring 1.21
# Executed in 0.18 second(s) in Ring 1.17

/*----------
*/
StartProfiler()

o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
? o1.ExecutableSection()
#--> [4, -3]

StopProfiler()
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.22 second(s) in ring 1.17

/*----------

StartProfiler()

o1 = new stzString('This[@i] = This[@i + 1] + @i - 2')
? o1.NumbersAfter("@i")
#--> [ "+1", "-2" ]

StopProfiler()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.16 second(s) in ring 1.17

/*---------- #narration

StartProfiler()

# When you use keywords other then This[@i] and alike in your
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
	#--> [ 1, -1 ]

# We can check this visually by seeing the transpiled code
# made by ExecutableSectionXT() in the background:

	? o1.Transpiled()
	#--> This[@i] = This[@i + 1] + 5

# In fact, when we check it directly:
	? StzCCodeQ('This[@i] = This[@i + 1] + 5').ExecutableSection()
	#--> [ 1, -1 ]

StopProfiler()
# Executed in 0.17 second(s) in ring 1.21
# Executed in 0.43 second(s) in Ring 1.17

/*----------

StartProfiler()

	o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
	? o1.ExecutableSectionXT()
	#--> [ 2, :Last ]

StopProfiler()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.26 second(s) in Ring 1.17

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @i - 5 ] = This[ @i - 3 ] }')
	? o1.ExecutableSection()
	#--> [ 5, :Last ]

StopProfiler()
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.17

/*---------- #narration #perf

StartProfiler()

# Whenever possible, write a conditional code using only the This[]
# and @i keywords. This will always lead to a better performance:

	o1 = new stzCCode('{ This[@i] = -This[@i] }')
	? o1.ExecutableSection()
	#--> [ 1, :Last ]
	# Executed in 0.04 second(s)

	o1 = new stzCCode('{ @number = -@number }')
	? o1.ExecutableSectionXT()
	#--> [ 1, :Last ]
	# Executed in 0.14 second(s)

StopProfiler()
# Executed in 0.12 second(s)

/*----------

StartProfiler()

	o1 = new stzCCode('Q(@EachChar).IsUppercase()')
	? o1.Transpiled()
	#--> Q( This[@i] ).IsUppercase()

	? o1.ExecutableSectionXT()
	#--> [ 1, :Last ]

StopProfiler()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 0.36 second(s) in Ring 1.17

/*----------

StartProfiler()

	o1 = new stzCCode('{ This[ @NextPosition ] = This[ @CurrentPosition ] + "O" }')
	? o1.ExecutableSectionXT()
	#--> [ 1, -1 ]

StopProfiler()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.17

/*----------
*/
StartProfiler()

	o1 = new stzCCode('{
		Q(This[ @NextPosition ]).HasDifferentCaseThen( This[ @CurrentPosition ] )
	}')

	? o1.ExecutableSectionXT()
	#--> [ 1, -1 ]

StopProfiler()
# Executed in 0.13 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.17
