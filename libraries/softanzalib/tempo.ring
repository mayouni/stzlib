load "stzlib.ring"

pron()

o1 = new stzString("ABCDE")
? o1.CharAt(2)
? "--"

proff()

/*----------------

pron()

? Q(["A", "B", "C", "D", "E"])[-3]
#--> "C"

proff()

/*==============

pron()

for i = 1 to 3
	Vr([ :x, :y, :z ]) '=' Vl([ 1*i, 2*i, 3*i ])
next

? @@( DataVarsXT() )
#--> [ [ "x", 3 ], [ "y", 6 ], [ "z", 9 ] ]

proff()

/*-------------

pron()

Vr([ :x, :y, :z ]) '=' Vl([ -1, 0, 1 ])
? v([ :x, :y, :z ])
#--> [ -1, 0, 1 ]

proff()
# Executed in 0.06 second(s)

/*-------------

pron()

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])
? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

proff()
# Executed in 0.06 second(s)

/*=============

str = "ring"
for i = 1 to 10000
	str += "ring"
next

pron()

oQStr = new QString2()
oQStr.append(str)

c1 = oQStr.mid(0, 1)
#--> "r"

c2 = oQStr.mid(oQStr.count()-1, 1)
#--> "g"

? c1
? c2

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzlist(1:120_000)

? o1.FindNext(3, :StartingAt = 10)
#--> 0

? o1.FindNext(10, :StartingAt = 10)
#--> 0

? o1.FindNext(11, :StartingAt = 10)
#--> 11

? o1.FindNext(100_000, :StartingAt = 70_000)
#--> 100_000

#--

? o1.FindPrevious(10, :StartingAt = 5)
#--> 0

? o1.FindPrevious(10, :StartingAt = 10)
#--> 0

? o1.FindPrevious(7, :StartingAt = 10)
#--> 7

? o1.FindPrevious(110_000, :StartingAt = 112_000)
#--> 110000

//

proff()
# Executed in 0.52 second(s)

/*-------------

pron()

o1 = new stzlist(1:120_000)
o1.Stringified()

proff()
# Executed in 0.75 second(s)

/*-------------

pron()

oQLocale = new QLocale("C")
? oQLocale.toLower("RING")
#--> "ring"

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

aLargeList = []
for i = 1 to 1_000
	aLargeList + "R_ING"
next

o1 = new stzList(aLargeList)
o1.StringifyLowercaseAndReplace("_", "♥")

? o1.FirstNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

? o1.LastNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

proff()
Executed in 0.12 second(s)

/*-------------

pron()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplaceXT("_", "♥")
? @@( o1.Content() )
#--> [
#	[ "--♥--", "[ 12, "--♥--", 10 ]", "--♥--", "9" ],
#	[ 1, 3 ]
# ]

proff()
# Executed in 0.03 second(s)

*-------------

pron()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplace("_", "♥")
? @@( o1.Content() )
#--> [ "--_--", [ 12, "--_--", 10 ], "--_--", 9 ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000
	aLargeList + "ring"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "*")
? o1.Content()[2]
#--> [1, 3]

proff()

/*-------------

pron()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplaceXT("_", :With = AHeart())
o1.Show()
#--> [ [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ], [ 2, 4, 6 ] ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplace("_", :With = AHeart())
o1.Show()
#--> [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000
	aLargeList + "_--_"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplace("_", "♥")

? o1.FirstNItems(5)
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9", "♥--♥" ]

? o1.LastNItems(3)
#--> [ "♥--♥" ], "♥--♥" ], "♥--♥" ]

proff()
# Executed in 0.09 second(s)

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 10_000
	aLargeList + "ring"
next
aLargeList + "--_--" + "--_--"

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "♥")
? o1.Content()[2]
#--> [1, 3, 1005, 1006]

proff()
# Executed in 0.37 second(s)

/*-------------

pron()

# TODO: General note on performance
# For all loops on large data (tens of thousands of times and more)
# don't relay on stzString services, but use Qt directly instead!

oQStr = new QString2()
oQStr.append("I talk in Ring language!")

? oQStr.contains("ring", FALSE)
#--> TRUE

oQStr.replace_2("ring", "RING", FALSE)
? oQStr.mid(0, oQStr.count())
#--> I talk in RING language!

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

# ComputableForm() function, abreviated with @@(), is not intended to
# be used inside large loops like this:

aList = ["_", "_", "♥"]

for i = 1 to 100_000
	@@(aList)
next
#--> Takes more then 20 seconds!

# Instead, you shoud do this:

cList = @@(aList)
for i = 1 to 100_000
	cList
next
# Takes only 0.05 seconds!
#--> 400 times more performant.

proff()
# Executed in 21.3657 second(s)

/*-------------
*/
pron()

# In this example, the large list contains +160K items...

	aLargeList = ["_", "_", "♥"]
	for i = 1 to 100_000
		aLargeList + "_"
	next
	
	aLargeList + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeList + "_"
	next i
	
	aLargeList + "♥" + "_" + "_" + "♥"
	

	# ElapseTime: 0.08s

	o1 = new stzList(aLargeList)

	# ElapsedTime: 0.11

	o1.StringifyAndReplace("♥", :With = "*")

	# ElapsedTime: 12.83s

	o1.LastNItems(40_000)
	#--> [ "*", "_", "_", "*" ]

proff()
# Executed in 12.80 second(s)

/*==============

StartProfiler()

o1 = new stzList([ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "🌞"] ] ])

? o1.DeepContains("🌞")
#--> TRUE

? @@( o1.DeepFind("🌞") )

StopProfiler()

/*=======

pron()

o1 = new stzString("ABC")
o1.ExtendTo(5)
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.03 second(s)

/*=======

pron()

o1 = new stzList("A" : "E")
? o1.ItemsAtPositions([2, 3])
#--> [ "B", "C" ]

proff()
#--> Executed in 0.03 second(s)

/*========

pron()

o1 = new stzString("okay one pepsi two three ")

# Declaring a condition in a string

cMyConditionIsVerified = '
	Q(This[@i]).ContainsAnyOfThese( Q("vwto").Chars() )
'

# Using the condition to find the words verifying it (using FindW())
# after the string is splitted (using Split())

? o1.SplitQ(" ").FindWhere(cMyConditionIsVerified) # Or .FindW() for short!
#--> [ 1, 2, 4, 5 ]

# Getting the words themselves using ItemsW()

? o1.SplitQ(" ").ItemsWhere(cMyConditionIsVerified)
#--> [ "okay", "one", "two", "three" ]

# In general, any function in Softanza, like Find() and Items() here,
# can be used as they are, or exented with the W() letter, so we can
# instruct them to their job upon a given condition.

proff()
# Executed in 0.24 second(s)

/*----------

pron()

o1 = new stzString("okay one pepsi two three ")
? o1.SplitQ(" ").FindWXT(' Q(@item).ContainsAnyOfThese( Q("vwto").Chars() ) ')

proff()
# Executed in 0.58 second(s)

/*----------

pron()

? Q([ [], [] ]).AllItemsAreEmptyLists()
#--> TRUE

? @@( Association([ [], [] ]) )
#--> Error: Can't associate empty lists!

proff()

/*----------

pron()

? Q(:stzPairOfNumbers).IsStzClassName()
#--> TRUE

proff()
# Executed in 0.02 second(s)

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

/*=========

pron()

? @@( Association([ :of = [ :one, :two, :three ], :with = [1, 2, 3] ]) )
#--> [ [ "one", 1 ], [ "two", 2 ], [ "three", 3 ] ]

proff()
# Executed in 0.05 second(s)

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
	
		AddXT([ "/", "\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
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

