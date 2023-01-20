load "stzlib.ring"


/*===================

StartProfiler()

	o1 = new stzString("Ring programming♥ language")
	o1.RemoveXT("♥", :From = "programming♥")

	? o1.Content()
	#--> Ring programming language

StopProfiler()
# Executed in 0.02 second(s)

/*----------------

StartProfiler()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Each = "*", :From = "*progr*amming*")

	? o1.Content()
	#--> Ring programming language

StopProfiler()
# Executed in 0.02 second(s)

/*----------------

StartProfiler()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ 2, "*" ], :From = "*progr*amming*")

	? o1.Content()
	#--> Ring *programming* language

StopProfiler()
# Executed in 0.02 second(s)

/*----------------

StartProfiler()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :First = "*", :From = "*progr*amming*")

	? o1.Content()
	#--> Ring progr*amming* language

StopProfiler()
# Executed in 0.02 second(s)

/*----------------

StartProfiler()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Last = "*", :From = "*progr*amming*")

	? o1.Content()
	#--> Ring *progr*amming language

StopProfiler()
# Executed in 0.02 second(s)

/*----------------

StartProfiler()

	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1,3], "*" ], :From = "*progr*amming*")

	? o1.Content()
	#--> Ring progr*amming language

StopProfiler()
# Executed in 0.02 second(s)

/*==---------

StartProfiler()

o1 = new stzString("programming*")
o1.RemoveFromEnd("*")
? o1.Content()

StopProfiler()

/*======== REMOVING AFTER

StartProfiler()

Q("Ring programming* language.") {

	RemoveXT("*", :After = "programming")
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.02 second(s)

/*-----------

StartProfiler()

Q("__♥)__♥)__♥)__") {

	RemoveXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

StartProfiler()

Q("__♥__♥)__♥__") {

	RemoveXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__♥)__♥__♥__") {

	RemoveXT( ")", :AfterFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__♥)__") {

	RemoveXT( ")", :AfterLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*========== REMOVING BEFORE

StartProfiler()

Q("Ring ***programming language.") {

	RemoveXT("***", :Before = "programming")
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.05 second(s)

/*-----------

StartProfiler()

Q("__(♥__(♥__(♥__") {

	RemoveXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*-----------

StartProfiler()

Q("__♥__(♥__♥__") {

	RemoveXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}

StopProfiler()
# Executed in 0.05 second(s)

/*-----------------

StartProfiler()

Q("__(♥__♥__♥__") {

	RemoveXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.05 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__(♥__") {

	RemoveXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.05 second(s)

/*========= REMOVE AROUND

	StartProfiler()
	
		o1 = new stzString("♥")
		? o1.IsBoundedByXT("-", :In = "...-♥-...")
		#--> TRUE

		? o1.IsBoundedByXT(["/", "\"], :InSide = "__/♥\__")
		#--> TRUE
	
		? o1.IsBetweenXT(["/", "\"], :InSide = "__/♥\__")
		#--> TRUE

		? o1.IsBetweenXT(["/", :And = "\"], :InSide = "__/♥\__")
		#--> TRUE

	StopProfiler()
	# Executed in 0.20 second(s)

/*----------

	StartProfiler()

	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])
	
	? @@S( o1.FindSubstring("name") )
	#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

	? @@S( o1.FindSubstringXT("name") )
	#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

	StopProfiler()
	# Executed in 0.04 second(s)

/*----------

	StartProfiler()

	? Q("__♥__♥__♥__").ContainsXT("♥", :BoundedBy = "_")
	#--> TRUE

	? Q("__/♥\__").ContainsXT("♥", :Between = [ "/", :And = "\"] )
	#--> TRUE

	? Q("_-♥-__-♥-__-♥-__").ContainsXT([3, "♥"], :BoundedBy = "-")
	#--> TRUE

	StopProfiler()

/*----------

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

/*----------

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

/*----------
*/
StartProfiler()

	? Q("__-♥-__").ContainsXT(:Chars, ["_", "-"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:TheseChars, ["♥", "-"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:SomeOfTheseChars, ["_", "-", "_"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:SomeOfThese, ["_", "-", "_"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:OneOfTheseChars, ["A", "♥", "B"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:OneOfThese, ["_", "-", "_"])
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

	? Q("").ContainsXT(:Chars, [])
	#--> FALSE
	? Q("").ContainsXT([], :Chars)
	#--> FALSE

# Same for :SubStrings

	
	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, ["softanza", :And = "ring"])
	# ? Q("_softanza_loves_ring_").ContainsXT(:TheseSubStrings, ["softanza", :And = "ring"])

	# ? Q("_softanza_loves_ring_").ContainsXT(:SomeOfTheseSubStrings, ["ring", "php", :Or = "softanza"])
	# ? Q("_softanza_loves_ring_").ContainsXT(:SomeOfThese, ["ring", "php", "softanza"])
	
	# ? Q("_softanza_loves_ring_").ContainsXT(:OneOfTheseSubStrings, ["python", "php", :Or = "ring"])
	# ? Q("_softanza_loves_ring_").ContainsXT(:OneOfThese, ["python", "php", :Or = "ring"])

	# ? Q("_softanza_loves_ring_").ContainsXT(:NoneOfTheseSubStrings, ["python", "php", :Nor = "ring"])
	# ? Q("_softanza_loves_ring_").ContainsXT(:NoneOfThese, ["python", "php", :Or = "ring"])

	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStringsWhere, '@SubStringQ.IsUppercase()')
	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStringsW, '@SubStringQ.IsUppercase()')
	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, :Where = '@SubStringQ.IsUppercase()')
	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, :Where('@SubStringQ.IsUppercase()') )
	# ? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, :W('@SubStringQ.IsUppercase()') )

	# ? Q("").ContainsXT(:SubStrings, []) #--> FALSE
	# ? Q("").ContainsXT([], :SubStrings) #--> FALSE

StopProfiler()

/*-----------

StartProfiler()

Q("_-♥-_-♥-_-♥-_") {

	RemoveXT("-", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	RemoveXT([ "/","\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
	? Content()
	#--> __/♥\__/♥\__/♥\__
}
# Executed in 0.06 second(s)

StopProfiler()

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	RemoveXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__/♥\__♥__
}

StopProfiler()
# Executed in 0.06 second(s)


/*-----------------

StartProfiler()

Q("__♥__/♥\__/♥\__") {

	RemoveXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__/♥\__/♥\__♥__") {

	RemoveXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.07 second(s)

load "stzlib.ring"


/*===================

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

