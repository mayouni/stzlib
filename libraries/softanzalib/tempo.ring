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

/*===============

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

/*===------------
*/
StartProfiler()

Q("Ring ***programming language.") {

	RemoveXT("***", :Before = "***programming")
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.02 second(s)

/*-----------

StartProfiler()

Q("__♥)__♥)__♥)__") {

	RemoveXT( ")", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

StartProfiler()

Q("__♥__♥)__♥__") {

	RemoveXT( ")", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__♥)__♥__♥__") {

	RemoveXT( ")", :BeforeFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__♥)__") {

	RemoveXT( ")", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*===------------

StartProfiler()

Q("__♥__♥__♥__") {

	RemoveXT(" ", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------
*/
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

