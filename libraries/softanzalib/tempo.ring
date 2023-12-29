load "stzlib.ring"

pron()

o1 = new stzString("{{ring}}")
? o1.Bounds()

? @@( o1.FindTheseBoundsAsSections("{{","}") )
#--> [ [ 1, 2 ], [ 8, 8 ] ]

? @@( o1.FindTheseBounds("{{", "}") )
#--> [ 1, 8 ]

o1.RemoveTheseBounds("{{","}")
? o1.Content()
#--> ring}

proff()
# Executed in 0.12

/*------------

pron()

o1 = new stzString("Abc285XY&من")

? o1.PartsAsSubstrings( :Using = 'Q(@char).IsLetter()' )
#--> [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

? o1.PartsAsSubstrings( :Using = 'Q(@char).Orientation()' )
#--> [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? o1.PartsAsSubstrings( :Using = 'Q(@char).IsUppercase()' )
#--> [ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

? o1.PartsAsSubstrings(:Using = 'Q(@char).CharCase()' )
#--> [ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

proff()
# Executed in 0.57 second(s)

/*------------

pron()

o1 = new stzString("abc")
? o1.CharCase()
#--> ERROR: Can't proceeed. You must provide a char.
#    To get the case of a string, use StringCase().

proff()

/*------------

pron()

o1 = new stzString("Abc285XY&من")

? o1.PartsAsSubstrings( :Using = 'Q(@char).IsLetter()' )
#--> [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

proff()
#--> Executed in 0.25 second(s)

/*------------

pron()

o1 = new stzList([ "A", "B", "A", "A", "B", "B", "C" ])

? o1.NumberOfItemsU() # Or NumberOfUniqueItems()
#--> 3

? o1.ItemsU()
#--> [ "A", "B", "C" ]

proff()

/*------------

pron()

o1 = new stzString("ABCAAB")

? o1.CharsQ().WithoutDuplicates()

? o1.CharsU()

? U( o1.Chars() )

proff()
# Executed in 0.04 second(s)

/*-------- TODO: erronous char name

pron()

? StzCharQ(63).Content()

? Q("🔻").Unicode()

? QQ("🔻").Name() # TODO: Correct this
#!--> QUESTION MARK

proff()

/*================
*/
pron()

o1 = new stzString("mmmMMMaaAAAiii")
? @@( o1.Classify(:Using = 'Q(@char).CharCase()') )
#--> [
#	[ "lowercase", [ "mmm", "aa", "iii" ] ],
#	[ "uppercase", [ "mmm", "aaa" ] ]
# ]

proff()
# Executed in 0.42 second(s)

/*================

pron()

o1 = new stzString("---,---;---[---]---:---")

? @@( o1.SplitAt([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", "---", "---", "---", "---", "---" ]

? @@( o1.SplitBefore([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", ",---", ";---", "[---", "]---", ":---" ]

? @@( o1.SplitAfter([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---,", "---;", "---[", "---]", "---:", "---" ]

proff()
# Executed in 0.15 second(s)

/*================

pron()

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :Position = 3, :AndPosition = 5)
#--> TRUE

? Q("^^♥♥♥^^").ContainsInSection("♥♥♥", 3, 5)
#--> TRUE

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenPositions = [ 3, :And = 5])
#--> TRUE

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :InSection = [3, 5])
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", "^^", "^^")
#--> TRUE

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :SubString = "^^", :AndSubString = "^^")
#--> TRUE

proff()
# Executed in 0.49 second(s)

/*--------------

pron()

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :Between = [ "^^", "^^" ] )

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenSubStrings = [ "^^", :And = "^^" ] )
#--> TRUE

proff()
#--> Executed in 0.48 second(s)

/*--------------

? Q("..<<--♥♥♥-->>..").ContainsXT("♥♥♥", :InBetween = ["<<", ">>"])
#--> TRUE

StopProfiler()
# Executed in 0.05 second(s)

/*==================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")
? o1.FindNthAsSection(2, "♥♥♥")
#--> [9, 11]

StopProfiler()

/*================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")

? o1.Sit(
	:InSection = o1.FindNthAsSection(2, "♥♥♥"),

	:AndYield = [
		:NCharsBefore = 3,
		:NCharsAfter  = 3
	]
)
#--> [ "__/", "\__" ]

StopProfiler()
# Executed in 0.04

/*========= CHECKING BOUNDS - XT
	
StartProfiler()
		
	o1 = new stzString("♥")
	? o1.IsBoundedByIB("-", :In = "...-♥-...") # You can use :Inside instead of :In
	#--> TRUE
	
	? o1.IsBoundedByIB(["/", "\"], :InSide = "__/♥\__")
	#--> TRUE
		
	? o1.IsBetweenIB(["/", "\"], :InSide = "__/♥\__")
	#--> TRUE
	
	? o1.IsBetweenIB(["/", :And = "\"], :InSide = "__/♥\__")
	#--> TRUE
	
StopProfiler()
# Executed in 0.20 second(s)

/*====  FINDING SUBSTRING, BASIC & EXTENDED

StartProfiler()

	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])
	
	? @@( o1.FindSubString("name") )
	#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

	? @@( o1.FindSubstringXT("name") )
	#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

StopProfiler()
# Executed in 0.04 second(s)

/*========== CHECKING CONTAINMENT

StartProfiler()
	
	? Q("\__♥__/").Contains("♥")
	#--> TRUE
	
	? Q("\__♥__/").ContainsMany("_") # Or .ContainsMoreThenOne("_")
	#--> TRUE
	
	? Q("\__♥__/").ContainsThese(["_","♥"])
	#--> TRUE
	
	? Q("\__♥__/").IsMadeOf(["\", "_", "♥", "/" ])
	#--> TRUE
	
StopProfiler()
# Executed in 0.04 second(s)

/*======== CHECKING CONTAINMENT - EXTENDED

StartProfiler()

	? Q("__♥__").ContainsXT("♥", "_")
	#--> TRUE

	? Q("__♥__♥__").ContainsXT(2, "♥")
	#--> TRUE

	? Q("__♥__").ContainsXT("♥", [])
	#--> TRUE

	? Q("_-♥-_").ContainsXT("♥", :BoundedBy = "-")
	#--> TRUE

	? Q("_/♥\_").ContainsXT("♥", :Between = ["/", :And = "\"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(["_", "-", "♥"], [])
	#--> TRUE

	? Q("__-♥-__-•-__").ContainsXT(["♥", "•"], :BoundedBy = "-")
	#--> TRUE
	
	? Q("__/♥\__/•\__").ContainsXT(["♥", "•"], :Between = ["/", :And = "\"])
	#--> TRUE

	? Q("__♥__").ContainsXT([], "♥")
	#--> TRUE

	? Q("__/♥\__/^^^\__").ContainsXT( [], :BoundedBy = ["/", :And = "\"] )
	#--> TRUE

	? Q("__/♥\__/^^\__").ContainsXT( [], :Between = ["/", "\"] )	
	#--> TRUE

StopProfiler()
# Executed in 0.04 second(s)

/*----------

StartProfiler()

	? Q("").ContainsXT(:Chars, []) # You can use NULL or FALSE instead of []
	#--> FALSE
	? Q("").ContainsXT([], :Chars) # You can use NULL or FALSE instead of []
	#--> FALSE

	? Q("__-♥-__").ContainsXT(:Chars, ["_", "-"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:TheseChars, ["♥", "-"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:SomeOfTheseChars, ["_", "-", "_"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:OneOfTheseChars, ["A", "♥", "B"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:NoneOfTheseChars, ["A", "*", "B"])
	#--> TRUE

	? Q("__---_^_").ContainsXT(:CharsWhere, 'Q(@char).IsEither("A", :Or = "^")' )
	#--> TRUE
	? Q("__---__").ContainsXT(:CharsW, 'Q(@Char).IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, :Where = 'Q(@Char).IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, Where(' Q(@Char).IsEither("_", :Or = "-") ') )
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, W('Q(@Char).IsEither("_", :Or = "-")'))
	#--> TRUE

# NOTE: Conditional code will be quicker of you replace Q(@Char) with Q(This[@i])

StopProfiler()
# Executed in 9.14 second(s)

/*------

StartProfiler()
	
Pron()

	? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, ["softanza", "ring"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:TheseSubStrings, ["softanza", "ring"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfTheseSubStrings, ["ring", "php", "softanza"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfThese, ["ring", "php", "softanza"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:OneOfTheseSubStrings, ["python", "php", "ring"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:OneOfThese, ["python", "php", "ring"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfTheseSubStrings, ["python", "php", "ruby"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfThese, ["python", "php", "ruby"])
	#--> TRUE
Proff()
# Executed in 0.08 second(s)

/*------------ TODO: Check performance! Rethink the subStrings() design

StartProfiler()

	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsWhere, 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, :Where = 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, Where('Q(@SubString).IsUppercase()') )
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, W('Q(@SubString).IsUppercase()') )
	#--> TRUE

StopProfiler()
# Executed in 144.36 second(s)

/*======== USING ADDXT() - EXTENDED

StartProfiler()
	
	Q("Ring programmin guage.") {
	
		AddXT("g", :After = "programmin") # You can use :To instead of :After
		? Content()
		#--> Ring programming guage.
	
	}

StopProfiler()
#--> Executed in 0.04 second(s)
	
/*-----------

StartProfiler()
	
	Q("__(♥__(♥__(♥__") {
	
		AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
StopProfiler()
# Executed in 0.05 second(s)

/*-----------

StartProfiler()
	
	Q("__♥__(♥__♥__") {
	
		AddXT( ")", :AfterNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()
	
	Q("__(♥__♥__♥__") {
	
		AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
		? Content()
		#-->__(♥)__♥__♥__
	}
	
StopProfiler()
# Executed in 0.07 second(s)
	
/*-----------------

StartProfiler()
	
	Q("__♥__♥__(♥__") {
	
		AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
		? Content()
		#--> __♥__♥__(♥)__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

/*===------------

StartProfiler()
	
	Q("Ring programming guage.") {	
		AddXT("lan", :Before = "guage")
		? Content()
		#--> Ring programming language.
	}
	
StopProfiler()
# Executed in 0.09 second(s)

/*---------

StartProfiler()
	
	Q("__♥)__♥)__♥)__") {
	
		AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
StopProfiler()
# Executed in 0.09 second(s)

/*---------

StartProfiler()
	
	Q("__♥__♥)__♥__") {
	
		AddXT( "(", :BeforeNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.10 second(s)

/*---------

StartProfiler()
	
	Q("__♥)__♥__♥__") {
	
		AddXT( "(", :BeforeFirst = "♥" )
		? Content()
		#--> __(♥)__♥__♥__
	}
	
StopProfiler()
# Executed in 0.10 second(s)

/*---------

StartProfiler()
	
	Q("__♥__♥__♥)__") {
	
		AddXT( "(", :BeforeLast = "♥" )
		? Content()
		#--> __♥__♥__(♥)__
	}
	
StopProfiler()
# Executed in 0.10 second(s)

/*===------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT(" ", :AroundEach = "♥")
		? Content()
		#--> __ ♥ __ ♥ __ ♥ __
	}
	
StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/", "\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	# Executed in 0.11 second(s)
	
StopProfiler()

/*-----------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/","\" ], :AroundNth = [2, "♥"])
		? Content()
		#--> __♥__/♥\__♥__
	}
	
StopProfiler()
# Executed in 0.12 second(s)


/*-----------------

StartProfiler()
	
	Q("__♥__/♥\__/♥\__") {
	
		AddXT( [ "/","\" ], :AroundFirst = "♥" )
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	
StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()
	
	Q("__/♥\__/♥\__♥__") {
	
		AddXT( [ "/","\" ], :AroundLast = "♥" )
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	
StopProfiler()
# Executed in 0.14 second(s)

