load "stzlib.ring"

/*=========== TODO:ERROR

pron()

? StzCharQ("0x10481").Content() #--> ERR, should be "𐒁"

? Q("Schöne Grüße").Length() # means "Kind Regards" in german
#--> 12

? StzUnicodeDataQ().CharByName("OSMANYA LETTER BA")
#--> 0x10481
#--> 66689

? StzCharQ("ҁ").Name()
#--> CYRILLIC SMALL LETTER KOPPA

? StzCharQ("𐒁") # TODO-ERROR
#--> Can't create char object!

? Q("𐒁").CharName() # TODO-ERROR: correct it to be OSMANYA LETTER BA
#--> QUESTION MARK

? StzCharQ("OSMANYA LETTER BA").Content()
#--> ҁ

proff()

#------

pron()

? Smile()
#--> 😆

? Heart()
#--> ♥

? Flower()
#--> ❀

? Sun()
#--> 🌞

? Moon()
#--> 🌔

? Handshake()
#--> 🤝

? Dot()
#--> •

? Tick()
#--> ✓

proff()
# Executed in 0.02 second(s)

/*================

pron()

? Q("SOFTANZA").Section(:From = "F", :To = "A") #--> "FTA"

? Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A")
#--> ["F", "T", "A"]

proff()
# Executed in 0.10 second(s)

/*--------------

pron()

o1 = new stzString("1234567")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 543

? o1.Section(3, -3)
#--> 345

? o1.Section(-3, 3)
#--> 543

? o1.Range(3, 3)
#--> 345

? o1.Range(3, -3)
#--> 123

? o1.Range(-5, -3)
#--> 123

proff()
# Executed in 0.04 second(s)

/*===============
*/
StartProfiler()
/*
? Q("^^♥^^").ContainsAt(3, "♥")
#--> TRUE

? Q("^^♥^^").ContainsAt("♥", :Position = 3)
#--> TRUE

? Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)
#--> TRUE

? Q("^^♥^^").ContainsInSection("♥", 2, 4)
#--> TRUE

? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4)
#--> TRUE

? Q("^^♥^^").ContainsBoundedBy("♥", :Positions = [ 2, :And = 4])
#--> TRUE
*/

? Q("^^♥^^").ContainsInSection("♥", 1, 3)

? Q("^^♥^^").ContainsBefore("♥", 4)

/*
? Q("^^♥^^").ContainsBefore("♥", "^^")

? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3)
#--> TRUE

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 3)
#--> TRUE
*/

StopProfiler()
# Executed in 0.07 second(s)
 
/*---------

pron()

? Q("^♥^^♥^^♥^").ContainsAtPositions([2, 5, 8], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsAtPosition("♥", 1)

proff()

/*---------

pron()

? Q("♥^^♥^^♥").ContainsAt([1, 4, 7], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [1, 4, 7])
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*=========

pron()

? @@S( Association([ :of = [ :one, :two, :three ], :with = [1, 2, 3] ]) )
#--> [ [ "one", 1 ], [ "two", 2 ], [ "three", 3 ] ]

proff()
# Executed in 0.05 second(s)

/*=========

pron()

o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")
? @@S( o1.BetweenZ("<<", ">>") ) + NL
#--> [ [ "teeba", 5 ], [ "rined", 16 ], [ "teeba", 27 ] ]

? @@S( o1.BetweenZZ("<<", ">>") )
#--> [ [ "teeba", [ 5, 9 ] ], [ "rined", [ 16, 20 ] ], [ "teeba", [ 27, 31 ] ] ]

proff()
#--> Executed in 0.17

/*---------

pron()

o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")
? @@S( o1.BetweenZZ("<<", ">>") ) + NL
#--> [	[ "hi!", [3, 5] ],
#	[ "--♥♥♥--♥♥♥--", [ 12, 23 ] ],
#	[ "hi!", [ 12, 32 ] ]
# ]

? @@S( o1.BetweenUZZ("<<", ">>") )
#--> [
#	[ "hi!", [ [ 3, 5 ], [ 30, 32 ] ] ],
#	[ "--♥♥♥--♥♥♥--", [ [ 12, 23 ] ] ]
# ]

proff()
#--> Executed in 0.20 second(s)

/*================

pron()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@S( o1.SubStringsBetween("<<", ">>") )
#--> [ "--hi!--", "--", "hi!" ]

? @@S( o1.BetweenZZ("<<", ">>") )
#--> [
#	[ "--hi!--", 	[  6, 12 ] ],
#	[ "--", 	[ 20, 21 ] ],
#	[ "hi!", 	[ 29, 31 ] ]
#]

proff()
#--> Executed in 0.14 second(s)

/*================
*/
pron()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@S( o1.FindInBetweenAsSections( "hi!", "<<", ">>" ) )
#--> [ [ 8, 10 ], [ 29, 31 ] ]

? @@S( o1.FindInBetween( "hi!", "<<", ">>" ) )
#--> [ 8, 29 ]

proff()
# Executed in 0.16 second(s)

/*-----------------

pron()

? @@S( Q("..<<--♥♥♥--♥♥♥-->>..<<---♥♥♥>>..").
	FindInBetweenAsSections("♥♥♥", "<<", ">>") )
#--> [ [ 7, 9 ], [ 12, 14 ], [ 26, 28 ] ]

proff()
# Executed in 0.12 second(s)

/*================

StartProfiler()

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :Position = 3, :And = 5)
#--> TRUE

? Q("^^♥♥♥^^").ContainsInSection("♥♥♥", 3, 5)
#--> TRUE

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :Between = [3, 5])
#--> TRUE

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :InSection = [3, 5])
#--> TRUE

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

? o1.Enclose(
	:Section = o1.FindNthAsSection(2, "♥♥♥"),

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
	
	? @@S( o1.FindSubString("name") )
	#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

	? @@S( o1.FindSubstringXT("name") )
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

	? Q("__---_^_").ContainsXT(:CharsWhere, '@charQ.IsEither("A", :Or = "^")' )
	#--> TRUE
	? Q("__---__").ContainsXT(:CharsW, '@charQ.IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, :Where = '@charQ.IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, Where('@charQ.IsEither("_", :Or = "-")'))
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, W('@charQ.IsEither("_", :Or = "-")'))
	#--> TRUE

StopProfiler()
# Executed in 0.58 second(s)

/*------

StartProfiler()
	
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

	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsWhere, '@SubStringQ.IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, '@SubStringQ.IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, :Where = '@SubStringQ.IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, Where('@SubStringQ.IsUppercase()') )
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, W('@SubStringQ.IsUppercase()') )
	#--> TRUE

StopProfiler()

/*======== USING ADDXT() - EXTENDED

	StartProfiler()
	
	Q("Ring programmin guage.") {
	
		AddXT("g", :After = "programmin") # You can use :To instead of :After
		? Content()
		#--> Ring programming guage.
	
	}
	
	StopProfiler()
	#--> Executed in 0.02 second(s)
	
/*-----------

	StartProfiler()
	
	Q("__(♥__(♥__(♥__") {
	
		AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
	StopProfiler()
	# Executed in 0.02 second(s)

/*-----------

	StartProfiler()
	
	Q("__♥__(♥__♥__") {
	
		AddXT( ")", :AfterNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
	StopProfiler()
	# Executed in 0.03 second(s)

/*-----------------

	StartProfiler()
	
	Q("__(♥__♥__♥__") {
	
		AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
		? Content()
		#--> __♥__(♥)__♥__
	}
	
	StopProfiler()
	# Executed in 0.04 second(s)
	
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
	# Executed in 0.04 second(s)

/*---------

	StartProfiler()
	
	Q("__♥)__♥)__♥)__") {
	
		AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
	StopProfiler()
	# Executed in 0.02 second(s)

/*---------

	StartProfiler()
	
	Q("__♥__♥)__♥__") {
	
		AddXT( "(", :BeforeNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
	StopProfiler()
	# Executed in 0.05 second(s)

/*---------

	StartProfiler()
	
	Q("__♥)__♥__♥__") {
	
		AddXT( "(", :BeforeFirst = "♥" )
		? Content()
		#--> __(♥)__♥__♥__
	}
	
	StopProfiler()
	# Executed in 0.04 second(s)

/*---------

	StartProfiler()
	
	Q("__♥__♥__♥)__") {
	
		AddXT( "(", :BeforeLast = "♥" )
		? Content()
		#--> __♥__♥__(♥)__
	}
	
	StopProfiler()
	# Executed in 0.05 second(s)

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
*/
	StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/","\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	# Executed in 0.06 second(s)
	
	StopProfiler()

/*-----------------

	StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/","\" ], :AroundNth = [2, "♥"])
		? Content()
		#--> __♥__/♥\__♥__
	}
	
	StopProfiler()
	# Executed in 0.06 second(s)


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
	# Executed in 0.07 second(s)

