load "stzlib.ring"

/*=====

emm = [

	:Uppercase = [
		:Uppercase, :Uppercased, :IsUppercased, :InUppercase, :Uppercasing
	]
]

BeforeQ("ring").IsUppercasedFQ()//RemoveFFQ("i").FromIt()
? @@(Future())

//? BeforeQ().UppercasingFQ("ring").RemoveFF("i")


class stzBefore
	obj

	def init(value)
		obj = Q(value)


/*=====

pron()

? Q("AnnIE").NumberOfVowels() # same as ? Q("AnnIE").VowelN()
#--> 3

? Q("AnnIE").Vowels()
#--> [ "A", "I", "E" ]

? Q("AnnIE").Vowel() # A random vowel from the string
#--> E

? Q("AnnIE").VowelN() # N ~> Number of...
#--> 3

proff()

/*----

pron()

SetLastValue(3)

? Q("AnnIE").VowelNB()
#--> TRUE

SetLastValue(2)

? Q("AnnIE").VowelNB()
#--> FALSE

SetLastValue(["A", "I", "E"])
? Q("AnnIE").VowelsB()
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*=====

pron()

Q("hi")
? MainObject().Content()
#--> "hi"

proff()
# Executed in 0.01 second(s)


/*======= #natural-coding #semantic-eloquence

pron()

? Q("ring").IsAString()
#--> TRUE

? Q("ring").IsStzString()
#--> TRUE

? Q("ring").IsAXT([ :Lowercase, :Latin, :String ])
#--> TRUE

? Q("ring").IsAXT([ :String ])
#--> TRUE

? Q("ring").IsA(:String)
#--> TRUE

? Q("ring").IsAXTQ([ :Lowercase, :Latin, :String ]).WhichQ().HasQ().ItsQ().LengthQ().EqualTo(4)
#--> TRUE

? TheStringQ("ring").IsAQ([ :Lowercase, :Latin, :String ]).WithQ().LengthQ().Of(4)
#--> TRUE

? TheWordQ("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WithAQ().LengthQ().OfXT(4, :Letters)
#--> TRUE

? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).
  WithQ().ALengthQ().OfQ(4)._Q(:Letters).AndQ().OnlyQM(1).VowelNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LowercaseBQ().LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNBQ().ThatAreQ().InLowercase()
#--> TRUE

? Q("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WhichQ().HasTheNumberQ(4).AsAQ().NumberOfCharsB()
#--> TRUE

? Q("ring").IsTheQ([ :Lowercase, :string ]).WhichQ().IsTheReverseOf("gnir")
#--> TRUE

proff()
# Executed in 0.19 second(s)

/*-----------

pron()

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegative()
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).WhichQ().CanBeDividedBy(10)
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*-----------

pron()

# Two misspelled forms of InLowercase()

? Q("ring").IsAQ(:String).InLowarcase() #--> TRUE
? Q("ring").IsAQ(:String).InLowercase() #--> TRUE

proff()
# Executed in 0.02 second(s)

/*------

pron()

? Q("ring").IsAQ(:String).InLowercase() 		#--> TRUE
? Q("ring").IsAQ(:String).WhichIs().InLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsInLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsLowercase()		#--> TRUE

proff()
# Executed in 0.03 second(s)

/*------

pron()

? PluralToStzType("stzstrings")
#--> stzstring

proff()
# Executed in 0.01 second(s)

/*------

pron()

o1 = new stzListOfStrings([ "Ring", "Ruby" ])
? o1.FirstChar()
#--> "R"

o1 = new stzListOfStrings([ "Ring", "Bing" ])
? o1.LastChar()
#--> "g"

proff()
# Executed in 0.03 second(s)

/*------

pron()

? Q([ "Ring", :and = "Ruby" ]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE

? Q([ "Ring", :and = "ruby" ]).AreTwoQ(:strings).HavingQ().TheirQ().FirstCharCSQ(WhatEverCaseItHas).EqualTo(TheLetter("R"))
#-> TRUE


? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().AllTheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().AllTheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

proff()
# Executed in 0.07 second(s)

/*------

pron()

? QM("ring").IsAQ(:String).
	InLowercaseQ().
	ContainingQ( TheLetter("i") ).
	HavingQ().TheQ().FirstCharQ().EqualToQ("r").
	AndQM().TheQ().Lastchar() = "g"
#--> TRUE

? QM("RING").IsAQ(:String).
	InUppercaseQ().
	ContainingQ( TheLetter("N") ).
	HavingQ().ItsQ().FirstCharQ().EqualToQ("R").
	AndQM().ItsQ().Lastchar() = "G"
#--> TRUE

proff()
# Executed in 0.05 second(s)


/*=====

pron()

aList = [ [1,2,3], [4,5,6], 7:9 ]

? "List content: " + NL + @@(aList) # Or ListToCode()
#--> List content: 
# [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

proff()

/*------

pron()

o1 = new stzTable([
	[ :Company, :Username, :Active, :Email, :EmailValid, :Firstname, :Infix, :Lastname,
	  :Gender, :2FA_Status, :Last_Login, :Creation_Date, :Accounts, :Roles ]
])



o1.FromCSV(str) # Or LoadCSVString()
o1.FromCSV(file) # Or LoadCSVFile

o1.FromJSON(str) # Or LoadJSONString()
o1.FromJSONXT(file) # Or LoadJSONFile()


o1.Show()
give any
proff()

/*----------------- #TODO: Check output error "R in g"
pron()

o1 = new stzString("IbelieveinRingfutureandengageforit!")

o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()
#--> I believe in Ring future and engage for it!

proff()

/*-----------------

pron()

o1 = new stzHashList([
	[ "#1", [ 12, 66 ] ],
	[ "#2", [ 26 ] ],
	[ "#3", [ 44, 66 ] ]
])

? @@( o1.FindKeysByValue(66) )
#--> [ 1, 3 ]

? @@( o1.KeysByValue(66) )
#--> [ "#1", "#3" ]

? o1.KeyByValue(66)
#--> #1

proff()

/*-----------------

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

? QQ("🔻").Name() #TODO: Correct this
#!--> QUESTION MARK

proff()

/*================ #TODO: check error in :uppercase valyes
		   #~> they must be in uppercase!

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

#NOTE: Conditional code will be quicker of you replace Q(@Char) with Q(This[@i])

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

#=======

/*--------

pron()

o1 = new stzList(1:8)
? @@( o1.SplitToListsOfNItems(2) )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ] ]

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList([ [ 1, 3 ], [ 8, 10 ], [ 12, 13 ], [ 18, 19 ], [ 21, 21 ], [ 26, 26 ] ])
? @@( o1.SplitToListsOfNItems(2) )
#--> [ 
#	[ [ 1, 3 ], [ 8, 10 ] ],
#	[ [ 12, 13 ], [ 18, 19 ] ],
#	[ [ 21, 21 ], [ 26, 26 ] ]
# ]

proff()

/*========

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.StringBounds() ) # Or simply Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.StringBoundsZZ() ) # Or simply BoundsZZ()
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

? @@( o1.FindStringBoundsAsSections() )  + NL # Or Simply FindBoundsAsSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBoundsAsSections("***", "***") )
#--> []

? @@( o1.FindTheseBoundsAsSections("<<<", "***") )
#--> [ [ 1, 3 ] ]

? @@( o1.FindTheseBoundsAsSections("***", ">>>") )
#--> [ [ 8, 10 ] ]

? @@( o1.FindTheseBoundsAsSections("<<<", ">>>") ) + NL
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBounds("***", "***") )
#--> []

? @@( o1.FindTheseBounds("<<<", "***") )
#--> [ [ 1, 3 ] ]

? @@( o1.FindTheseBounds("***", ">>>") )
#--> [ [ 8, 10 ] ]

? @@( o1.FindTheseBounds("<<<", ">>>") ) + NL

#--

? @@( o1.TheseBoundsZ("***", "***") )
#--> []

? @@( o1.TheseBoundsZ("<<<", "***") )
#--> [ [ "<<<", 1 ] ]

? @@( o1.TheseBoundsZ("***", ">>>") )
#--> [ [ ">>>", 8 ] ]

? @@( o1.TheseBoundsZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

#--

? @@( o1.TheseBoundsZZ("***", "***") )
#--> []

? @@( o1.TheseBoundsZZ("<<<", "***") )
#--> [ [ "<<<", [ 1, 3 ] ] ]

? @@( o1.TheseBoundsZZ("***", ">>>") )
#--> [ [ ">>>", [ 8, 10 ] ] ]

? @@( o1.TheseBoundsZZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]


proff()
# Executed in 1.82 second(s)

/*============

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([ [8,10], [1,3] ])
? o1.Content()
#--> word
proff()
# Executed in 0.06 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([])
? o1.Content()
#--> <<<word>>>
proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
? o1.FindLeadingChars()
#--> 0

? @@( o1.FindLeadingCharsAsSection() )
#--> [ ]

proff()
# Executed in 0.04 second(s)

/*---------

pron()

o1 = new stzList([ [ ], [ 5, 7 ] ])
? o1.IsListOfPairsOfNumbers()
#--> FALSE

proff()


/*--------- TODO: add _ for more readable numbers

? @@(1587345327)
#--> '1_587_345_327'

? @@([ 1, 2, 999997, 999998, 1000000 ])
#--> [ 1, 2, 999_997, 999_998, 1_000_000 ]

/*---------

pron()

o1 = new stzList( 1 : 1_000_000 )
o1.RemoveSection(5, 999_996)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 999_997, 999_998, 999_999, 1_000_000 ]

proff()
# Executed in 0.73 second(s)

/*---------

pron()

o1 = new stzList([ "w", "o", "r", "d", ">", ">", ">" ])
o1.RemoveSection(1, 4)
? @@( o1.Content() )
#--> [ ">", ">", ">" ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([ "<", "<", "w", "o", "r", "d", ">", ">", ">" ])

o1.RemoveSections([ [ 1, 2 ], [ 7, 9 ] ])
? @@( o1.Content() )
#--> [ "w", "o", "r", "d" ]

proff()
# Executed in 0.06 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
o1.RemoveSections([ [ ], [ 5, 7 ] ])
? o1.Content()
#--> word

proff()
# Executed in 0.05 second(s)

/*---------

pron()

o1 = new stzString("<<<word")
o1.RemoveSections([ [ 1, 3 ], [ ] ])
? o1.Content()
#--> word

proff()
# Executed in 0.05 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
? @@( o1.Bounds() )
#--> []

? o1.ContainsBounds() # Or ? o1.IsBounded()
#--> FALSE

proff()
# Executed in 0.04 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
o1.RemoveBounds() # Has no effect because the string is not bounded
? o1.Content()
#--> word>>>
proff()
# Executed in 0.03 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")

o1.RemoveTheseBounds("***", "***") # Nothiong happens
? o1.Content()
#--> <<<word>>>

o1.RemoveTheseBounds("<<<", "***") # Remove only the first bound
? o1.Content()
#--> word>>>

o1.RemoveBounds() # Has no effect because the string is no longer bounded
#--> word>>>
? o1.Content()

proff()
# Executed in 0.33 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveFirstBound()
? o1.Content()
#--> word>>>

proff()
# Executed in 0.09 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveLastBound() # Or o1.RemovesecondBound()
? o1.Content()
#--> <<<word

proff()
# Executed in 0.09 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

? @@( o1.FirstBounds(:Of = "word") )
#--> [ "<<<", "<<", "<" ]

? @@( o1.SecondBounds(:Of = "word") )
#--> [ ">>>", ">>", ">" ]

proff()
# Executed in 0.09 second(s)

/*=======

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveBoundsOf("word")
? o1.Content()
#--> word word word

proff()
# Executed in 0.09 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveFirstBounds(:Of = "word") # Or o1.RemoveLeftBounds(:Of = "word")
#--> word>>> word>> word>

? o1.Content()


proff()
# Executed in 0.08 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveLastBounds(:Of = "word") # Or o1.RemoveRightBounds(:Of = "word")
? o1.Content()
#--> <<<word <<word <word

proff()
# Executed in 0.08 second(s)

/*========= SWAPPING TWO SECTIONS

pron()

o1 = new stzString(">>>word<<<")
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? o1.Content()
#--> <<<word>>>

proff()
# Executed in 0.06 second(s)

/*----------

pron()

o1 = new stzList([ ">", ">", ">", "w", "o", "r", "d", "<", "<", "<" ])
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? @@( o1.Content() )
#--> [ "<", "<", "<", "w", "o", "r", "d", ">", ">", ">" ]

proff()
# Executed in 0.06 second(s)

/*---------

pron()
#                   12345678901234567
o1 = new stzString("...>>>word<<<....")

? o1.Section(4, 6)
#--> >>>

? o1.Section(11, 13)
#--> <<<

o1.SwapSections([4, 6], [11, 13])
? o1.Content()
#--> ...<<<word>>>....

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzString(">>>word<<< >>word<< >word<")
o1.SwapBoundsOf("word")
? o1.Content()
#--> <<<word>>> <<word>> <word>

proff()
# Executed in 0.07 second(s)

/*=========

pron()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
? o1.NumberOfSectionsBetween("word", "<<", ">>")
#--> 3
	
? @@( o1.FindSubStringBetweenAsSections("word", "<<", ">>") )
#--> [ [11, 14], [28, 31], [41, 44] ]
	
? @@( o1.FindNthBetweenAsSection(2, "word", "<<", ">>") )
#--> [28, 31]
	
? @@( o1.FindFirstBetweenAsSection("word", "<<", ">>") )
#--> [11, 14]
	
? @@( o1.FindLastBetweenAsSection("word", "<<", ">>") )
#--> [41, 44]

proff()
# Executed in 0.11 second(s)

/*---------

pron()

o1 = new stzString("123 ABC 901 DEF")
o1.ReplaceSections([ [1, 3], [9, 11] ], "***")
? o1.Content()
#--> *** ABC *** DEF

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 123 DEF")

o1.ReplaceSection( 11, 13, :With@ = ' Q("*").RepeatedNTimes( Q(@Section).Size() ) ' )
? o1.Content()
#--> 12345 ABC *** DEF

o1.ReplaceSection( 1, 5, :With@ = ' Q("*").RepeatedNTimes( Q(@Section).Size() ) ' )
? o1.Content()
#--> ***** ABC *** DEF

proff()
# Executed in 0.36 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 1234 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 14] ],

	:With = '***'
)

? o1.Content()
#--> *** ABC *** DEF

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 123 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 13] ],

	:With@ = '{
		Q("*").RepeatedNTimes( Q(@Section).Size() )
	}'
)

? o1.Content()

#--> *** ABC *** DEF

proff()
# Executed in 0.22 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.FirstItems()
#--> [ 4, 3, 8 ]

? o1.SecondItems()
#--> [ 7, 1, 9 ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [9, 8] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 9 ] ]

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@( o1.Content() )
#--> [ [ 9, 8 ], [ 7, 4 ], [ 3, 1 ] ]

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.IsSortedInAscending()
#--> FALSE

o1 = new stzListOfPairs([ [1,3], [4, 7], [8, 9] ])
? o1.IsSortedInAscending()
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.IsSortedInDescending()
#--> FALSE

o1 = new stzListOfPairs([ [9,8], [7,4], [3,1] ])
? o1.IsSortedInDescending()
#--> TRUE

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.FindPair([3, 1])
#--> 2

proff()

/*======================

pron()

o1 = new stzList("A":"J")

? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ [ "C", "D", "E" ], [ "G", "H" ] ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "F" ], [ "I", "J" ] ]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "C", "D", "E" ], [ "F" ], [ "G", "H" ], [ "I", "J" ] ]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.13 second(s)

/*----------------

pron()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ "CDE", "GH" ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "F", "IJ"]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "CDE", "F", "GH", "IJ"]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.15 second(s)

/*=================

pron()

? @@( SectionToRange([3, 4]) )
#--> [3, 2]

? @@( RangeToSection([3, 2]) )
#--> [3, 4]

? @@( SectionsToRanges([ [3, 4], [8, 10] ]) )
#--> [ [3, 2], [8, 3] ]

? @@( RangesToSections([ [3, 2], [8, 3] ]) )
#--> [ [3, 4], [8, 10] ]

proff()
# Executed in 0.03 second(s)

/*=================

pron()

o1 = new stzList([ [ "ONE", "TWO" ], [ "THREE", "FOUR" ], [ "FIVE", "SIX" ] ])
? o1.IsListOfLists()
#--> TRUE

? o1.IsListOfPairs()
#--> TRUE

? o1.IsListOfPairsOfStrings()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList([ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ])
? o1.IsListOfLists()
#--> TRUE

? o1.IsListOfPairs()
#--> TRUE

? o1.IsListOfPairsOfNumbers()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*=================

pron()

o1 = new stzString("AB♥CD♥EF♥GH")

? @@( o1.Split("♥") )
#--> [ "AA", "CD", "EF", "GH" ]

? @@( o1.SplitAfter("♥") )
#--> [ "AB♥", "CD♥", "EF♥", "GH" ]

? @@( o1.SplitBefore("♥") )
#--> [ "AB", "♥CD", "♥EF", "♥GH" ]

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzString("AB♥♥C♥♥D♥♥E")

? o1.SplitToPartsOfNChars(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥", "E" ]

? o1.SplitToPartsOfExactlyNChars(2) # OR SplitToPartsOfNCHarsXT(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

proff()
# Executed in 0.06 second(s)

/*=================

pron()

o1 = new stzString("ABCDE")
? @@( o1.SubStrings() )
#--> [
#	"A", "AB", "ABC", "ABCD", "ABCDE", "B",
#	"BC", "BCD", "BCDE", "C", "CD", "CDE",
#	"D", "DE", "E"
# ]

proff()
# Executed in 0.17 second(s)

/*================ LEADING AND TRAILING CHARS

pron()

o1 = new stzString("<<<word>>>")

? o1.ContainsLeadingChars()
#--> TRUE

? o1.NumberOfLeadingChars()
#--> 3

? o1.LeadingChars() + NL
#--> "<<<"

#--

? o1.ContainsTrailingChars()
#--> TRUE

? o1.NumberOfTrailingChars()
#--> 3

? o1.TrailingChars()
#--> ">>>"

proff()
# Executed in 0.12 second(s)

/*================ WORKING WITH BOUNDS OF THE STRING

pron()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.FindBounds() )
#--> [ 1, 8 ]

? @@( o1.FindBoundsAsSections() )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? o1.LeftBound()
#--> <<<

? o1.FindLeftBound()
#--> 1

? @@( o1.FindLeftBoundAsSection() )
#--> [ 1, 3 ]

? @@( o1.LeftBoundZ() )
#--> [ "<<<", 1 ]

? @@( o1.LeftBoundZZ() ) + NL
#--> [ "<<<", [ 1, 3 ] ]

#--

? o1.RightBound()
#--> >>>

? o1.FindRightBound()
#--> 8

? @@( o1.FindRightBoundAsSection() )
#--> [ 8, 10 ]

? @@( o1.RightBoundZ() )
#--> [ ">>>", 8 ]

? @@( o1.RightBoundZZ() ) + NL
#--> [ ">>>", [ 8, 10 ] ]

proff()
# Executed in 0.35 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.FindBounds() ) # Same as o1.FindFirstAndLastBounds()
			# You can also use Riht and Left instead of First and Last
#--> [ 1, 8 ]

	? @@( o1.FindLastAndFirstBounds() )
	#--> [ 8, 1 ]

? @@( o1.FindBoundsAsSections() ) # Same as o1.FindFirstAndLastBoundsSasSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

	? @@( o1.FindLastAndFirstBoundsAsSections() )
	#--> [ [ 8, 10 ], [ 1, 3 ] ]

proff()

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.Bounds() )
#--> [ "<<<", ">>>" ]

	? @@( o1.FirstAndLastBounds() )
	#--> [ "<<<", ">>>" ]

	? @@( o1.LastAndFirstBounds() ) + NL
	#--> [ ">>>", "<<<" ]

#--

? @@( o1.BoundsZ() )
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.FirstAndLastBoundsZ() )
	#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.LastAndFirstBoundsZ() ) + NL
	#--> [ [ ">>>", 8 ], [ "<<<", 1 ] ]

#--

? @@( o1.BoundsZZ() )
#--> .BoundZ

	? @@( o1.FirstAndLastBoundsZZ() )
	#--> .BoundZ

	? @@( o1.LastAndFirstBoundsZZ() )
	#--> [ [ ">>>", [ 8, 10 ] ], [ "<<<", [ 1, 3 ] ] ]


proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzString(">>word<<")
o1.SwapBounds()
? o1.Content()
#--> <<word>>

proff()
# Executed in 0.07 second(s)

/*================ WORKING WITH BOUNDS INSIDE THE STRING

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")
? @@( o1.FindSubStringBoundsAsSections("word") )
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindSubStringBounds("word") )
#--> [ 1, 8, 13, 20, 28, 35 ]

proff()

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Bounds of the entire string

? @@( o1.FindStringBoundsAsSections() ) + NL
#--> [ [ 1, 3 ], [ 35, 37 ] ]

# Bounds of a particular substring inside the string

? @@( o1.FindSubStringBoundsAsSections("word") ) + NL
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindFirstBoundsOfAsSections("word") ) + NL
#--> [ [ 1, 3 ], [ 13, 15 ], [ 28, 30 ] ]

? @@( o1.FindFirstBoundsOf("word") ) + NL
#--> [ 1, 13, 28 ]

proff()
# Executed in 0.18 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

? @@( o1.FindSubStringSecondBoundsAsSections("word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

? @@( o1.FindSubStringSecondBounds("word") )
#--> [ 8, 20, 35 ]

proff()
/*=============

pron()

o1 = new stzString("123♥^♥789")

? o1.Sit( :OnSection = [4, 6], :AndYield = [ 20, 30 ] )
#--> [ "123", "789" ]

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")
		
? o1.SubStringIsBoundedBy("♥♥", "aa")
#--> TRUE

? o1.SubStringIsBoundedBy("♥♥", "bb")
#--> TRUE
	
? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] )
#--> TRUE

proff()
# Executed in 0.16 second(s)

/*================

pron()

o1 = new stzList([ Q(4), Q("Ring"), Q(1:3) ])
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

o1 = new stzList([ 6, "hi!", 1:3 ])
o1.Objectify()
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

proff()

/*---------------

pron()

o1 = new stzList([ 5, "12", 1:3, "Ring" ])
o1.Numberify()
? @@(o1.Content())
#--> [ 5, 12, 3, 4 ]

proff()
# Executed in 0.05 second(s)

/*---------------

pron()

o1 = new stzList([ 1, "hi", [], NULL ])
o1.Listify()
? @@( o1.Content() )
#--> [ [ 1 ], [ "hi" ], [ ], [ "" ] ]

proff()
# Executed in 0.02 second(s)

/*---------------

# Personal note :This sample has been porposed by Teeba (my daughther). She helped me
# identify the [] case and solve it.

pron()
#			vv
o1 = new stzList([ 957, [], [ 1:3, 4:5, 9:12 ], "Hussein", ["Haneen"] ])
o1.Pairify()
? @@( o1.Content() )
#--> [
#	[ 957, "" ],
#	[ "", "" ],
#	[ [ 1, 2, 3 ], [ 4, 5 ] ],
#	[ "Hussein", "" ],
#	[ "Haneen", "" ]
# ]

proff()
# Executed in 0.02 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], "__", [ "--", "--", "--" ] ])
o1.Pairify() # transform all items to pairs
? @@( o1.Content() )
#--> [
#	[ "<<", ">>" ],
#	[ "__", "__" ],
#	[ "--", "--" ]
# ]

proff()
# Executed in 0.02 second(s)

/*--------------

pron()

o1 = new stzList(["<<", ">>"])
o1.Pairify()
#--> [ [ "<<", "" ], [ ">>", "" ] ]

? @@( o1.Content() )

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzList([ ["<<", ">>"] ])
o1.Pairify()
#--> [ [ "<<", "" ], [ ">>", "" ] ]

? @@( o1.Content() )
#--> [ [ "<<", ">>" ] ]

proff()

/*--------------

pron()

? @@( Q([ ["<<", ">>"], "__" ]).Pairified() )
#--> [ [ "<<", ">>" ], [ "__", "" ] ]

proff()

/*==============

pron()

o1 = new stzString("<<word>> and __word__")

? o1.SubStringIsBoundedBy("word", ["<<", ">>"])
#--> TRUE

? o1.SubStringIsBoundedBy("word", "__")
#--> TRUE

? o1.SubStringIsBoundedByMany("word", [ ["<<", ">>"], "__" ])
#--> TRUE

proff()
# Executed in 0.11 second(s)

/*------ #TODO: check it

pron()

? o1.SubStringQ( "word" ).IsBoundedBy(["<<", ">>"])
#--> TRUE

proff()
# Executed in 0.27 second(s)

/*----------------

pron()

	o1 = new stzList([ "<<", ">>" ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> TRUE


	o1 = new stzList([ [ "<<", ">>" ], [ "__", "__" ] ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> TRUE

proff()
# Executed in 0.08 second(s)

/*----------------

pron()

o1 = new stzList([ "<<", ">>" ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__ @word@")
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> FALSE

proff()
# Executed in 0.10 second(s)

/*----------------

pron()

? Q("_").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

? Q("<").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> FALSE

? Q([ "<", ">" ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

? Q([ ["<",">"], ["_","_"] ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

proff()
# Executed in 0.10 second(s)

/*----------------

pron()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")

? o1.SubStringIsBoundedBy("♥♥", "aa") #--> TRUE
? o1.SubStringIsBoundedBy("♥♥", "bb") #--> TRUE

? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] ) #--> TRUE
? o1.SubStringIsBoundedBy("♥♥", [ [ "aa","aaa" ], ["bb","bbb"] ]) #--> TRUE

proff()
# Executed in 0.14 second(s)

/*================= POSSIBLE SUBSTRINGS IN THE STRING

pron()

o1 = Q("ABAAC")
? @@( o1.SubStrings() ) + NL
#--> [
# 	"A", "AB", "ABA", "ABAA",
# 	"ABAAC", "B", "BA", "BAA",
# 	"BAAC", "A", "AA", "AAC", "A", "AC", "C"
# ]

? @@( o1.SubStringsZ() ) + NL
#--> [
# 	[ "A", [ 1, 3, 4 ] ],
# 	[ "AB", [ 1 ] ],
# 	[ "ABA", [ 1 ] ],
#	[ "ABAA", [ 1 ] ],
#	[ "ABAAC", [ 1 ] ],
#	[ "B", [ 2 ] ],
#	[ "BA", [ 2 ] ],
#	[ "BAA", [ 2 ] ],
#	[ "BAAC", [ 2 ] ],
#	[ "AA", [ 3 ] ],
#	[ "AAC", [ 3 ] ],
#	[ "AC", [ 4 ] ],
#	[ "C", [ 5 ] ]
# ]

? @@( o1.SubStringsZZ() )
#--> [
#	[ "A", [ [ 1, 1 ], [ 3, 3 ], [ 4, 4 ] ] ],
#	[ "AB", [ [ 1, 2 ] ] ],
#	[ "ABA", [ [ 1, 3 ] ] ],
#	[ "ABAA", [ [ 1, 4 ] ] ],
#	[ "ABAAC", [ [ 1, 5 ] ] ],
#	[ "B", [ [ 2, 2 ] ] ],
#	[ "BA", [ [ 2, 3 ] ] ],
#	[ "BAA", [ [ 2, 4 ] ] ],
#	[ "BAAC", [ [ 2, 5 ] ] ],
#	[ "AA", [ [ 3, 4 ] ] ],
#	[ "AAC", [ [ 3, 5 ] ] ],
#	[ "AC", [ [ 4, 5 ] ] ],
#	[ "C", [ [ 5, 5 ] ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*=================

pron()

? Q([ "abc", 120, "cdef", 14, "opjn", 988 ]).ToString()

#-->
#	"abc
#	120
#	cdef
#	14
#	opjn
#	988"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

? Q(["abc","cdef","opjn"]).ToString() + NL # Q() creates a stzList object
#-->
#	abc
#	cdef
#	opjn

proff()
# Executed in 0.03 second(s)

/*================= #Todo: check after including SubstringsBetween()

pron()

o1 = new stzList(["A", "AA", "B", "BB", "C", "CC", "CC" ])
? o1.ItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC", "CC" ])

? o1.UniqueItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC" ]

proff()

/*---------------- #Todo: check after including SubstringsBetween()

pron()

o1 = new stzListOfStrings([
	"A", "v", "♥", "c",
	"Av", "♥♥", "c♥", "Av♥",
	"♥c♥",
	"Av♥♥", "Av♥♥c",
	"Av♥♥c♥",
	"Av♥♥c♥♥"
])

? o1.StringsW(' Q(@String).NumberOfChars() = 2 ')
#--> [ "Av", "♥♥", "c♥" ]

? o1.StringsW('
	Q(@String).BeginsWith("A") and Q(@String).NumberOfChars() > 4
')
#--> [ "Av♥♥c", "Av♥♥c♥", "Av♥♥c♥♥" ]

proff()

/*================ #Todo: check after including SubstringsBetween()

pron()

o1 = new stzString("Av♥♥c♥♥")
? o1.FindAll("♥♥") #--> [ 3, 6 ]
? o1.FindSubStringsW('{ @SubString = "♥♥" }') #--> [ 3, 6 ]

proff()

/*=============== #Todo: check after including SubstringsBetween()

pron()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBetween("<<", ">>")
#--> [ "word1", "word2" ]

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? o1.SubstringsBetween('"', '"')
#--> [ "    value ", " 12   " ]

proff()

/*---------------- #Todo: check after including SubstringsBetween()
pron()

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? @@( o1.SubStringsBetween('"','"') )
#--> [ " value ", " 12 " ]

? @@( o1.SubStringsBetweenIB('"','"') )
#--> [ [ " value ", [ 16, 25 ] ], [ " 12 ", [ 42, 47 ] ] ]

? @@( o1.FindSubStringsBetween('"','"') )
#--> [ 16, 42 ]

? @@( o1.FindSubStringsBetweenIB('"','"') )
#--> [ [ 16, " value " ], [ 42, " 12 " ] ]

proff()

/*================

pron()

o1 = new stzString("blabla bla <<word>> bla bla <<word>>")
? o1.FindAsSections("word") # Or FindSubStringAsSections() or FindZZ()
#--> [ [14, 17], [31, 34] ]

proff()
# Executed in 0.03 second(s)

/*---------------- #Todo: Check after including findanybetween()

pron()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetween("<<", ">>")
#--> [ 14, 32 ]

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetweenAsSections("<<", ">>")
#--> [ [14, 18], [32, 36] ]

proff()

/*---------------- #Todo: Check after including findanybetween()

o1 = new stzString(' this code:   txt1  = "    withspaces    "   and txt2="nospaces"  ')
aSections = o1.FindAnyBetweenAsSections('"', '"')
#--> [ [24 ,41], [56, 63] ]

aAntiSections = o1.FindAntiSections(aSections)
#--> [ [1, 23], [42, 55], [64, 66] ]

? o1.Sections(aAntiSections)
#--> [
#	' this code:   txt1  = "',
#	'"   and txt2="',
#	'"  '
#    ]

/*---------------- #Todo: Check after including findanybetween()

o1 = new stzString(' this code:   txt1  = "    withspaces    "   and txt2="nospaces"  ')
aBetween = o1.FindAnyBetweenAsSections('"', '"')
#--> [ [24 ,41], [56, 63] ]

? o1.Sections( aBetween )
#--> [ '    withspaces    ', 'nospaces' ]

? o1.SectionsXT( aBetween )
#--> [
#	[ '    withspaces    ', [24 ,41] ],
#	[ ''nospaces', [56, 63] ]
#    ]

? o1.AntiSections( aBetween )
#--> [
#	' this code:   txt1  = "',
#	'"   and txt2="',
#	'"  '
#    ]

? o1.AntiSectionsXT( aBetween )
#--> [
#	[ ' this code:   txt1  = "', [1, 23] ],
#	[ '"   and txt2="', [42, 55] ],
#	[ '"  ', [64, 66] ]
#    ]

? o1.SectionsAndAntiSections( aBetween )
#--> [
#	' this code:   txt1  = "',
#	'    withspaces    ',
#	'"   and txt2="',
#	'nospaces',
#	'"  '
#    ]

? o1.SectionsAndAntiSectionsXT( aBetween )
#--> [
#	[ ' this code:   txt1  = "', [1, 23] ],
#	[ '    withspaces    ', [24, 41] ],
#	[ '"   and txt2="', [42, 55] ],
#	[ 'nospaces', [56, 63] ],
#	[ '"  ', [64, 66] ]
#    ]

/*---------------

pron()

? Q(" this code:   txt1  = ").Simplified()
#--> "this code: txt1 ="

proff()
# Executed in 0.01 second(s)

/*--------------- #Todo: Check after including findanybetween()

pron()

o1 = new stzString(' this code:   txt1  = "<    withspaces    >"   and txt2="<nospaces>"  ')
aAntiSections = o1.FindAntiSections( o1.FindAnyBetweenAsSections('"','"') )

o1.ReplaceSections(aAntiSections, :With = '|***|')
? o1.Content()
#--> '|***|<    withspaces    >|***|<nospaces>|***|'

proff()

/*---------------- #Todo: Check after including findanybetween()

pron()

o1 = new stzString(' this code    :   txt1  = "<    leave spaces    >"   and this    code:  txt2 =   "< leave spaces >"  ')
aAntiSections = o1.FindAntiSections( o1.FindAnyBetweenAsSections('"','"') )

o1.ReplaceSections(aAntiSections, :With@ = ' Q(@Section).Simplified() ')
? o1.Content()
#--> this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"

proff()

/*==============

pron()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***THREE")
#--> TRUE

? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***THREE")
#--> FALSE

proff()
# Executed in 0.01 second(s)

/*----------------

pron()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> TRUE

? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> FALSE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzNumber(10)
? o1.Occures( :Before = "TEN", :In = [ 2, "TWO", 10, "TEN" ] ) # NOTE: OccurEs is misspelled!
#--> TRUE

o1 = new stzList(1:3)
? o1.Occurs( :Before = 1:7, :In = [ 1:2, "TWO", 1:3, 1:7, "THREE" ] )

o1 = new stzObject(ANullObject())
? o1.Comes( :Before = "NULL", :In = [ 1, 2, ANullObject(), "NULL" ] )

o1 = new stzString("one")
? o1.Happens( :Before = "two", :In = [ "one", "two", "three" ] )

proff()
# Executed in 0.06 second(s)

/*----------------

pron()

? Q("*").OccursNTimes(3, :In = "a*b*c*d")
#--> TRUE

? Q("*").OccursNTimes(3, :In = [ "a", "*", "b", "*", "c", "*", "d" ])
#--> TRUE

proff()

/*----------------

pron()

? Q("*").OccursForTheFirstTime( :In = "a*b*c*d", :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheLastTime( :In = "a*b*c*d", :AtPosition = 6 )
#--> TRUE

? Q("*").OccursForTheLastTime( :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 ) #--> TRUE
#--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheNthTime( 2, :In = "a*b*c*d", :AtPosition = 4 )
#--> TRUE

? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 )
#--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheNthTime( 2, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 4 )
#--> TRUE

? Q("*").OccursForTheNthTime( 3, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 )
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 1 )
#--> TRUE

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 2 )
#--> TRUE

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 3 )
#--> FALSE

? Q("bag").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 4 )
#--> TRUE

? Q("hat").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 5 )
#--> TRUE

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 6 )
#--> FALSE

proff()
# Executed in 0.04 second(s)

/*---------------- #TODO: check it after including substringsbetween()

pron()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q(aShoppingCart).FindW('{
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )
}')
#--> [ 1, 2, 4, 5 ]

proff()

/*================ #TODO: check it after including substringsbetween()

pron()

  # Suppose a customer added all these items to his shopping cart in an
  # ecommerce website:

  aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

  # You are asked, as a programmer of the website, to extract the number of times
  # each item has been added...

  # In Softanza, using the Yielder Metaphor, you can solve it naturally like this:

  ? Q(aShoppingCart).YieldW('
	[ @item, This.NumberOfOccurrence( :Of = @item ) ]',

	:Where = '
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )'
  )

  #--> [ [ "Shirt", 2 ], [ "shoes", 2 ], [ "bag", 1 ], [ "hat", 1 ] ]

proff()

/*=========

pron()

? ComputableForm('len    var1 = "    value "  and var2 =  " 12   " ') + NL
#--> 'len var1 = "    value " and var2 = " 12   "'

? ComputableForm("len    var1 = '    value '  and var2 =  ' 12   ' ")
#--> "len    var1 = '    value '  and var2 =  ' 12   ' "

proff()
# Executed in 0.02 second(s)

/*================= CHECK PERFORMANCE
#TODO: check it after including FindSubStringsW()

pron()

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.FindSubStringsW('{
	Q(@SubString).NumberOfChars() = 2	
}') )
#--> [
#	[ "Av", [ 1 ] 	],
#	[ "♥♥", [ 3, 6] ],
#	[ "c♥", [ 5 ] 	],
#	[ "v♥", [ 2 ] 	],
#	[ "♥c", [ 4 ] 	]
# ]

proff()

/*------------- # TODO: check ERROR
#TODO: check it after including FindSubStringsW()

pron()

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.FindSubStringsW('{
	Q(@SubString).NumberOfChars() = 2 and NOT Q(@SubString).Contains("♥")
}') )

#--> ERROR
# Line 11126 Error (R3) : Calling Function without definition !: 2andnotq 
# In method findallitemsw() in file D:\GitHub\SoftanzaLib\libraries\softanzalib\stzList.ring

# The problem is that the evaluated code has spaces removed, like this:
# bOk = ( Q( @item ).NumberOfChars()=2andNOTQ( @item ).Contains("♥") )

proff()

/*=================

pron()

o1 = new stzString("I love ")
o1.AddSubString("Ring")
? o1.Content()
#--> I love Ring

proff()

#-----------------

pron()

o1 = new stzString("Ring")
o1.ExtendToNCharsXT(10, :Using = ".")
? o1.Content()
#--> "Ring.........."

proff()
# Executed in 0.01 second(s)

/*=================

pron()

? Q("-♥-").IsBoundedBy("-")
#--> TRUE

? Q("♥").IsBoundedByIB("-", :In = "... -♥- ...")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*---------------- #TODO: check it again after including findsubstringsbetween()

pron()

o1 = new stzString("Av♥♥c♥♥")

? o1.FindW('{
	Q(@SubString).NumberOfChars() = 2 and
	Q(@SubString).IsBoundedBy@_( "Q(@Char).IsLowercase()", "_" ) 

}')

proff()

/*----------------

pron()

? StzCharQ(1049).Content() + NL
#--> Й

? @@( StzListOfCharsQ(1000 : 1009).Content() ) + NL
#--> [ "Ϩ", "ϩ", "Ϫ", "ϫ", "Ϭ", "ϭ", "Ϯ", "ϯ", "ϰ", "ϱ" ]

Q("℺℻ℚ") {

	? Unicodes() 	#--> [ 8506, 8507, 8474 ]
	? UnicodesXT() 	// Or alternatively UnicodesAndChars()
	#--> [ [ 8506, "℺" ], [ 8507, "℻" ], [ 8474, "ℚ" ] ]

	? CharsAndUnicodes()
	#--> [ [ "℺", 8506 ], [ "℻", 8507 ], [ "ℚ", 8474 ] ]

	? CharsNames()
	#--> [ "ROTATED CAPITAL Q", "FACSIMILE SIGN", "DOUBLE-STRUCK CAPITAL Q" ]

}

proff()
# Executed in 0.23 second(s)

/*-------------- #TODO: Use the normal way (ExecutableSection) and check for perf

pron()

? @@( Q("℺℻ℚ").Yield('[ @char, Q(@char).Unicode(), Q(@char).CharName() ]') )
#--> [
# 	[ "℺", 8506, "ROTATED CAPITAL Q" ],
# 	[ "℻", 8507, "FACSIMILE SIGN" ],
# 	[ "ℚ", 8474, "DOUBLE-STRUCK CAPITAL Q" ]
#    ]

proff()
# Executed in 0.22 second(s)

/*============== #TODO: check it again after including substringsbetween()

pron()

# What are the unique letters in this sentence?
# "sun is hot but fun"

# To solve it, you can usz stzString and say:

? @@( Q("sun is hot but fun").RemoveSpacesQ().UniqueChars() )
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# Or you can use stzList and stzListOfStrings and say:

? @@( Q([ "sun", "is", "hot", "but", "fun" ]).
	YieldQR('{ Q(@String).Chars() }', :stzListOfLists).
	MergeQ().UniqueItems()
)
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# The solutions above uses "strings" and "chars" concepts which both
# belong to the stzString domain. But if you want to solve it in
# a higher semantic level, you can rely on "text" and "letter" concepts
# from the stzText domain:

? TQ("sun is hot but fun").UniqueLetters()
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]
# Which turns out to be more natural, isn't it?

proff()

/*----------------

pron()

? len("طيبة") #--> 8

? StzStringQ("طيبة").NumberOfChars()
#--> 4

? StzStringQ("طيبة").NumberOfBytes()
#--> 8

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = Q("TAYOUBAAOOAA")
? o1.LastAndFirstChars()
#--> [ "A", "T" ]

proff()

/*---------------- #TODO: Check it after including between()

pron()

o1 = new stzList([ "A", "B", "♥", "♥", "C", "♥", "♥", "D", "♥","♥" ])
? o1.FindWXT('{ @CurrentItem = @NextItem }')	#--> [ 3, 6, 9 ]

? o1.FindFirstWXT(' @CurrentItem = @NextItem ')	#--> 3
? o1.FindLastWXT(' @CurrentItem = @NextItem ')	#--> 9
? o1.FindNthWXT(2, ' @CurrentItem = @NextItem ')	#--> 6

proff()

/*----------------

pron()

o1 = new stzList("A":"E")
? @@( o1 / 3 )
#--> [ [ "A", "B" ], [ "C", "D" ], [ "E" ] ]

proff()
# Executed in 0.04 second(s)

/*-------

pron()

aList = []
for i = 1 to 5
	aList + [1]
next

? @@(aList)

proff()

/*=======

pron()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(0) ) + NL
#--> [ ]

? @@( o1.SplitToNParts(1) ) + NL
#--> [ [ 1, 12 ] ]

? @@( o1.SplitToNParts(2) ) + NL
#--> [ [ 1, 6 ], [ 7, 12 ] ]

? @@( o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 12 ] 

? @@( o1.SplitToNParts(4) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 12 ] ]

? @@( o1.SplitToNParts(5) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(6) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(7) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(8) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(9) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(10) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(11) ) + NL
#--> [ [ 1, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(12) ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(13) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

? @@( o1.SplitToNParts(-2) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

proff()

/*---------

pron()

o1 = new stzSplitter(10)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 7 ], [ 8, 10 ] ]

o1 = new stzSplitter(11)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ] ]

o1 = new stzSplitter(17)
? @@(o1.SplitToNParts(5) ) + NL
# [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ], [ 12, 14 ], [ 15, 17 ] ]

o1 = new stzSplitter(78)
? @@(o1.SplitToNParts(12) )
#--> [
# 	[  1,  7 ], [  8, 14 ], [ 15, 21 ],
# 	[ 22, 28 ], [ 29, 35 ], [ 36, 42 ],
#	[ 43, 48 ], [ 49, 54 ], [ 55, 60 ],
#	[ 61, 66 ], [ 67, 72 ], [ 73, 78 ]
# ]

o1 = new stzSplitter(0)
? @@(o1.SplitToNParts(5) )
#--> []

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzString("ABCDEFGHIJ")

? @@( o1 / 10 ) + NL
#--> [ "A" ,"B", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 9 ) + NL
#--> [ "AB", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 8 ) + NL
#--> [ "AB", "CD", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 7 ) + NL
#--> [ "AB", "CD", "EF", "G", "H", "I", "J" ]

? @@( o1 / 6 ) + NL
#--> [ "AB", "CD", "EF", "GH", "I", "J" ]

? @@( o1 / 5 ) + NL
#--> [ "AB", "CD", "EF", "GH", "IJ" ]

? @@( o1 / 4 ) + NL
#--> [ "ABC", "DEF", "GH", "IJ" ]

? @@( o1 / 3 ) + NL
#--> [ "ABCD", "EFG", "HIJ" ]

? @@( o1 / 2 ) + NL
#--> [ "ABCDE", "FGHIJ" ]

o1 = new stzString("ABCDEFGHIJ") + NL
? @@( o1 / 1 ) + NL
#--> [ "ABCDEFGHIJ" ]

? @@( o1 / 0 )
#--> [ ]

proff()

/*---------

pron()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1 / 89 )
#--> Error message: Incorrect value! n must be between 0 and 10 (the size of the list).

proff()

/*=============

pron()

o1 = Q("AB♥♥C♥♥D♥♥")
? o1.FindCharsW(' @Char = "♥" ')
#--> [ 3, 4, 6, 7, 9, 10 ]

? o1.FindCharsW(' @CurrentChar = @NextChar ')
#--> [ 3, 6, 9 ] 

? o1.FindNthCharW(2, '@CurrentChar = @NextChar') + NL
#--> 6

? o1.FindFirstCharW('@CurrentChar = @NextChar') + NL
#--> 3

? o1.FindLastCharW('@CurrentChar = @NextChar')	 #--> 9
#--> 9

proff()
# Executed in 1.38 second(s)

/*----------------

pron()

@T = Q("TAYOUBA")
? @T.Section( :From = "A", :To = "B" )
#--> AYOUB

? @T.Section( :From = :FirstChar, :To = @T.First("A") )
#--> TA

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("SOFTANZA")

? o1.Section( :From = o1.PositionOfFirst("A"), :To = :LastChar )
#--> ANZA

? o1.Section( :From = o1.First("A"), :To = :LastChar )
#--> ANZA

proff()
# Executed in 0.02 second(s)


/*----------------

pron()

o1 = Q([ "T","A","Y","T","O", "A", "U", "B", "T", "A" ])
? o1.Section(:From = "A", :To = "T")

? @@( o1.SectionsBetween( "T", :And = "A" ) )
#--> [
#	[ "T", "A" ],
#	[ "T", "A", "Y", "T", "O", "A" ],
#	[ "T", "A", "Y", "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "O", "A" ], [ "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "A" ]
# ]

proff()
# Executed in 0.02 second(s)

/*---------------- #TODO: Implement these functions

pron()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])
? o1.ContainsInEachList("♥")

? o1.ContainsInJustOneList("♥")

? o1.ContainsInNLists(3, "♥")
? o1.ContainsNOccurrencesInAllLists(3, "♥")
? o1.ConatinsNOccurrencesInEachList(1, "♥")
? o1.ContainsNOccurrencesInNLists(1, 3, "♥")
? o1.ContainsNOccurrencesInTheseLists([ [1, 1], [3, 2] ])

proff()

/*---------------- #todo: add these functions

pron()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])

aListOfLists = [ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ]
? Q("♥").ExistsIn( aListOfLists  )
? Q("♥").ExistsInLists( aListOfLists  )
? Q("♥").ExistsInOnlyOneList( aListOfLists )
? Q("♥").ExistsInNLists(2, aListOfLists )
? Q("♥").ExistsNTimesInAllLists(3, aListOFLists )
? Q("♥").ExistsNTimesInEachList(3, aListOFLists )
? Q("♥").ExistsNTimesInNLists(3, 2, aListOFLists )
? Q("♥").ExistsNTimesInTheseLists([ [1, 1], [3, 2] ])

proff()

/*----------

pron()

? 3Hearts() #--> ♥♥♥
? 5Stars()  #--> ★★★★★

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindFirstNOccurrences(2, :Of = "ring")
#--> [ 2, 4 ]

? o1.FindLastNOccurrences(2, :Of = "ring")
#--> [ 4, 6 ]

? o1.FindTheseOccurrences([2, 3], :Of = "ring")
#--> [ 4, 6 ]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindNthOccurrence(3, "ring")
#--> 5

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
#--> [ 1, 7 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 7 ]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

anPos = o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
#--> [ 1, 7 ]

o1.RemoveItemsAtPositions(anPos)
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindTheseOccurrences([1, 4], "ring")
o1.RemoveItemsAtPositions([1, 7])
? @@( o1.content() )

proff()
# Executed in 0.01 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.RemoveOccurrences([ :First, :Last ], :Of = "ring" )
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceOccurrences([ :First, :And = :Last ], :Of = "ring", :With = 3Hearts() )
? @@( o1.Content() )
#--> [ "♥♥♥", "__", "ring", "__", "ring", "__", "♥♥♥" ]

proff()
# Executed in 0.11 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceFirstNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() )
#--> [ "★★", "__", "★★", "__", "ring", "__", "ring" ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceLastNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() ) #--> [ "ring", "__", "ring", "__", "★★", "__", "★★" ]

proff()
# Executed in 0.03 second(s)

/*==============

pron()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.FindTheseOccurrences([ :First, :And = :Last ], "ring")
#--> [ 1, 25 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 25 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # or FindNthOccurrence(2, "ring")
#--> 9

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring") #--> [ 1, 9, 17 ]

o1.ReplaceSubStringAtPositions(anPos, "ring", Heart())

? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.ReplaceFirstNOccurrences(3, "ring", Heart())
? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveSubStringAtPosition(1, "ring")
? o1.Content()
#-->  __ ring __ ring __ ring

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
o1.RemoveSubStringAtPositions(anPos, "ring")
? o1.Content()
#--> " __  __  __ ring"

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.FindOccurrences([ 2, 3 ], "ring")
#--> [ 9, 17 ]

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveOccurrences([2, 3], "ring")
? o1.Content() + NL
#--> ring __  __  __ ring

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveFirstNOccurrences(3, "ring")
? o1.Content() + NL
#--> " __  __  __ ring"

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveLastNOccurrences(3, "ring")
? o1.Content()
#--> "ring __  __  __ "

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # o1.FindNthOccurrence(2, "ring")
#--> 9

proff()
# Executed in 0.01 second(s)

/*========

pron()

o1 = new stzHashList([ [ "hussein", 3 ], [ "haneen", 1 ], [ "teeba", 3 ] ])
? o1.ValuesQR(:stzListOfNumbers).sum()
#--> 7

proff()
# Executed in 0.03 second(s)

/*----

pron()

? sum(1:10)
#--> 55

proff()
# Executed in 0.02 second(s)

/*================ @narration

pron()

# In Softanza, you can divide the content of a string into 3 parts
cLetters = "ABCDEFG"

? Q(cNumbers) / 3
#--> [ "ABC", "DE", "FG" ]

# Those 3 parts can be "named" parts:

? Q(cLetters) / [ "Hussein", "Haneen", "Teeba" ]
#--> [ :Hussein = "ABC", :Haneen = "DE", :Teeba = "FG" ]

# And you can configure the share of each part at your will:
? Q(cLetters) / [ :Hussein = 3, :Haneen = 1, :Teeba = 3 ]
#--> [ :Hussein = "ABC", :Haneen = "D", :Teeba = "EFG" ]

proff()
#--> Executed in 0.03 second(s)

/*====================

pron()

o1 = new stzSplitter(10)

? @@( o1.SplitBeforepositions([3,7]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :atPosition = 15) ) # Note that position 15 is out of the string
#-->[ "1234567890" ]

proff()
# Executed in 0.06 second(s)

/*------

pron()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ "1234", "67890" ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ "12", "456", "890" ]

? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ "1234", "567890" ]

? @@( o1.SplitXT( :before = [3, 7] ) ) + NL
#--> [ "12", "3456", "7890" ]

? @@( o1.SplitXT( :after = 5 ) ) + NL
#--> [ "12345", "67890" ]

? @@( o1.SplitXT( :after = [3, 7] ) ) + NL
#--> [ "123", "4567", "890" ]

? @@( o1.SplitXT( :ToPartsOfNChars = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ "123", "456", "789" ]

? @@( o1.SplitXT( :ToPartsOfNCharsXT = 3 ) ) + NL # remaining part is added
#--> [ "123", "456", "789", "0" ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ "123", "456", "78", "90" ]

proff()
# Executed in 0.39 second(s)

/*------

pron()

o1 = new stzList(1:10)

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
# List is returned as-is (no split) because the item [3, 7] does not exist in 1:10

# If you want to say by [3, 7] the positions 3 and 7, be explicit and write:
? @@( o1.SplitXT( :atPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 4, 5, 6 ], [ 8, 9, 10 ] ]


? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :beforePositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 3, 4, 5, 6 ], [ 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPosition = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6, 7 ], [ 8, 9, 10 ] ]

? @@( o1.SplitXT( :ToPartsOfNItems = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? @@( o1.SplitXT( :ToPartsOfNItemsXT = 3 ) ) + NL # remaining part is added
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.39 second(s)

*================

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAt(4) )	# or SplitAtPosition(4)
#--> [ "ONE", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAt([ 4, 8 ]) ) # or SplitAtPositions([4, 8])
#--> [ "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitBefore(4) ) # or SplitBeforePosition(4)
#--> [ "ONE", "_TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitBefore([ 4, 8 ]) ) # or SplitBeforePositions([ 4, 8 ])
#--> [ "ONE", "_TWO", "_THREE" ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAfter(4) ) # or SplitAfterPosition(4)
#--> [ "ONE_", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAfter([ 4, 8 ]) ) # or SplitAfterPositions([ 4, 8 ])
#--> [ "ONE_", "TWO_", "THREE" ]

proff()
# Executed in 0.06 second(s)

/*==================

pron()

o1 = new stzString("ABCDE")
? @@( o1.SplitToNParts(5) ) + NL
#--> [ "A", "B", "C", "D", "E" ]

o1 = new stzString("AB12CD34")
? @@( o1.SplitToPartsOfNChars(2) ) + NL
#--> [ "AB", "12", "CD", "34" ]

o1 = new stzString("ABC123DEF456")
? @@( o1.SplitToPartsOfNChars(3)) + NL
#--> [ "ABC", "123", "DEF", "456" ]

o1 = new stzString("ABCD1234EF")
? @@( o1.SplitToPartsOfNChars(4)) + NL # SplitToPartsOfExactlyNChars
#--> [ "ABCD", "1234" ]

? @@( o1.SplitToPartsOfNCharsXT(4)) # The remaining part is also returned
#--> [ "ABCD", "1234", "EF" ]

proff()
# Executed in 0.03 second(s)

/*===================

pron()

? Q(0).IsMultipleOf(3) #--> FALSE

proff()
# Executed in 0.02 second(s)

/*------------------
*/
pron()

o1 = new stzString("123456789012")
? @@( o1.SplitW( 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitW( :At = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

proff()
# Executed in 1.31 second(s)

/*------------------

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :Before = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

/*------------------

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :After = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

/*==================

pron()

o1 = new stzList([ "a", "abcde", "abc", "ab", "b", "abcd" ])

o1.SortInAscendingBy('len(@item)')
? o1.Content()

proff()

/*------------------

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortInDescendingBy('len(@item)')
? o1.Content()

#--> [ "abcde", "abcd", "abc", "ab", "a" ]

/*==================

o1 = new stzList([ "a", "b", "c", "d", "ab", "cd", "abc", "abcd", "bc", "bcd" ])
? o1.SortedBy(' Q(@item).NumberOfChars() ')
/*
o1 = new stzString("abcd")
? o1.SubStrings()

/*------------------


o1 = new stzString( "ABCabcEFGijHI" )
? o1.SplitW( 'Q(@SubString).IsLowercase()' )

#===========


/*-----------

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.SectionCS(:From = "RING", :To = :LastChar, :CaseSensitive = FALSE))
#--> Ring programming language

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.Section(:From = "Ring", :To = "language")
# Ring programming language

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

# Softanza make programming in Ring more expressive.

# To showcase this, let's consider how substr() function
# is used in Ring, and how Softanza offers a better way.

# In Ring, the substr() function does many things:
#	--> Finding a substring
#	--> Getting the substring starting at a given position
#	--> Getting the substring made of n given chars starting at a given position
#	--> Replacing a sbstring by an other substring (with or without casesensitivity)

# We are going to perform all these actions, using substr() and then Softanza,
# side by side, so you can make sense of the expressiveness of the library...

# Finding a substring

	cStr = "Welcome to the Ring programming language"
	? substr(cStr,"Ring")
	#--> 16

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.FindFirst("Ring")
	#--> 16

	# In Softanza, we can also return all the occurrences of cSubStr

	? oStr.Find("Ring") # equivalent to FindAll("Ring")
	#--> [ 16 ]

# Getting the substring starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr, "Ring") # gives 16
	? substr(cStr, nPos)
	#--> Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Section(:From = "RING", :To = :LastChar) # Or simply Section("Ring", :End)
	#--> Ring programming language

# Getting the substring made of n given chars starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr,"Ring") # Gives nPos = 16
	? substr(cStr, nPos, 4)
	#--> Ring

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Range("Ring", 4)
	#--> Ring

# Replacing a sbstring by an other substring

	cStr = "Welcome to Python programming language"
	? substr(cStr, "Python", "Ring") # Replaces 'Python' with 'Ring'
	#--> Welcome to the Ring programming language

	# In Softanza we say:
	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content()
	#--> Welcome to Ring programming language

# Replacing a sbstring by an other substring with Case Sensitivity

	cStr = "Welcome to the Python programming language"
	? substr(cStr,"PYTHON", "Ring", 0) #WARNING: This is should be 1 and not 0!
	#--> Welcome to the Python programming language
	
	cStr = "Welcome to the Python programming language"
	? substr(cStr, "PYTHON", "Ring", 1) #WARNING: This is should be 0 and not 1!
	#--> Welcome to the Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", :CaseSensitive = FALSE)
	? oStr.Content()
	#--> Welcome to Ring programming language

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", TRUE)
	? oStr.Content()
	#--> Welcome to Python programming language
	
proff()
# Executed in 0.11 second(s)

/*---------

# Performance of stzString (using QString2 in background) is astonishing!


# Ket's compose a large string

str = "1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

for i = 1 to 1_000_000
	str += "SomeStringHereAndThere"
next
# Executed in 13.31 second(s)

pron()

str += "|1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"
o1 = new stzString(str)
? @@(o1.FindThisBoundedBy("1", "|"))

#TODO: Try to compose the string by pushing the first part in the middle or a the end,
# and if stzString is still as performant!

proff()
# Executed in 0.15 second(s)

/*--------- TODO: review sort in stztable (I may use this Ring native solution)

pron()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

aSorted = sort(aList, 1)
? @@(aSorted) + NL
#--> [ [ "ahmed", 14000 ], [ "ibrahim", 11000 ], [ "mahmoud", 15000 ], [ "mohammed", 12000 ], [ "samir", 16000 ] ]

aSorted = sort(aList, 2)
? @@(aSorted)
#--> [ [ "ibrahim", 11000 ], [ "mohammed", 12000 ], [ "ahmed", 14000 ], [ "mahmoud", 15000 ], [ "samir", 16000 ] ]

proff()
# Executed in 0.03 second(s)

/*---------

pron()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

o1 = new stzListOfPairs(aList) # Or stzListOfLists() if you want

? @@( o1.Sorted() ) + NL
#--> [ [ "ahmed", 14000 ], [ "ibrahim", 11000 ], [ "mahmoud", 15000 ], [ "mohammed", 12000 ], [ "samir", 16000 ] ]

? @@( o1.SortedBy(2) )
#--> [ [ "ibrahim", 11000 ], [ "mohammed", 12000 ], [ "ahmed", 14000 ], [ "mahmoud", 15000 ], [ "samir", 16000 ] ]

proff()

#--> Executed in 0.05 second(s)

/*---------

pron()

o1 = new QString2()
o1.append("tunis * tunis * tunis")
? o1.count()
#--> 17

? o1.indexof("*", 6, 0) # Params --> str, startat, casesensitive
#--> 6

proff()

/*--------

pron()

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

o1 = new stzList(aList)
? o1.FindNext("*", :startingat = 2)
#--> 5

proff()
#--> Executed in 28.26 second(s)

/*-----------

pron()

# Preparing the large list to work on
	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 1.20 seconds

	o1 = new stzList(aList)
	# takes 1 second

	aHash = []
	aSeen = []

	for i = 1 to 1_900_008
		n = o1.FindNext(aList[i], i)
		
		if n = 0
			aSeen + aList[i]
			aHash + [ aList[i], [i] ]
		ok
	next

proff()

/*-----------

pron()

# Preparing the large list to work on
	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 1.20 seconds


	# Creating the stzList object

	o1 = new stzList(aList)
	
	? ELpasedTime()
	# Takes 1.32 seconds

	# Concatenating the items of the list
	
	aContent = aList
	nLen = len(aList)

	cSep = " "
	cResult = ""

	for i = 1 to nLen - 1
		cResult += aContent[i] + cSep
	next



proff()
# Executed in 13.00 second(s)

/*--------------------


pron()

# Initializing the large list of strings

	o1 = new QStringList()
	for i = 1 to 1_900_000
		o1.append("sometext")
	next
	aList = [ "A", "*", "B", "C", "*", "D", "*", "E" ]
	nLen = len(aList)
	for i = 1 to nLen
		o1.append(aList[i])
	next
	
	? ElpasedTime()
	# (takes 11.87 seconds)

# Concatenating the strings in one string

	str = o1.join("")
	# Takes 0.05 seconds

proff()
# (takes 11.63 seconds)


#======

/*----------

pron()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
?: @@( o1.FindXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ 6, 14 ]

proff()

/*----------

pron()

# 		           8
o1 = new stzString("...<<--*-->>...")
? @@( o1.FindXT( "*", :InBetween = [ "<<", ">>" ]) ) # or :InSubStringsBetween

proff()

/*----------

pron()

o1 = new stzString('..."*"..."*"...')

//? o1.FindXT( "*", :BoundedBy = '"' )

/*----------

o1 = new stzString('..."*"..."*"...')

? o1.FindXT( "*", :InSection = [4 , 14 ] )
#--> [ 5, 11 ]

? o1.FindInSection("*", 4, 14)

proff()
# Executed in 0.03 second(s)

/*---------- #TODO: Check errors

pron()

o1 = new stzString("~*~~*--")
? o1.FindBefore( "*", "--")
? o1.FindXT( "*", :Before = "--")

proff()

/*---------- #TODO: Check errors

pron()

o1 = new stzString("~*~~*--")
? o1.FindXT( "*", :BeforePosition = 10)

proff()

/*---------- #TODO: Check erros

pron()

o1 = new stzString("~--*~~*~~")
? o1.FindXT( "*", :After = "--")

proff()

/*----------

# FindXT( "*", :AfterPosition = 3)

/*----------

# FindXT( :3rd = "*", :Between = [ "<<", ">>" ])

/*----------

# FindXT( :3rd = "*", :BoundedBy = '"' ])

/*----------

# FindXT( :3rd = "*", :InSection = [5, 24] ])

/*----------

# FindXT( :3rd = "*", :Before = '!' ])

/*----------

# FindXT( :3rd = "*", :BeforePosition = 12 ])

/*----------

# FindXT( :3rd = "*", :After = '!' ])

/*----------

# FindXT( :3rd = "*", :AfterPosition = 12 ])

/*----------

# FindXT( :AnySubString, :Between = ["<<", ">>" )

/*----------

# FindXT( :Any, :BoundedBy = '"' )

/*----------

# FindXT( "*", :InSection = [5, 24] )
