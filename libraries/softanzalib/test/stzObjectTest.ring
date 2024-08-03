load "stzlib.ring"

/*--------------

pron()

? NullObject().Name()
#--> @nullobject

? Q(NullObject()).IsNamedObject()
#--> TRUE

#--

? TrueObject().Name()
#--> @trueobject

? Q(TrueObject()).IsNamedObject()
#--> TRUE

#--

? FalseObject().Name()
#--> @falseobject

? Q(FalseObject()).IsNamedObject()
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*--------------

pron()

StzNamedObjectQ(:myobj = TrueObject()) {

	? Name()
	#--> :myobj

	? StzType()
	#--> :stznumber

}

# Executed in 0.03 second(s)

/*==============

pron()

? @@( StzNullObjectQ() )
#--> @noname

? @@([ StzNullObjectQ() ])
#--> [ @noname ]

? @@([ 1:3, StzNullObjectQ(), "a":"b", StzFalseObjectQ() ])
#!--> [ [ 1, 2, 3 ], @noname, [ "a", "b" ], @noname ]

proff()
# Executed in 0.09 second(s)

/*==================

pron()

? fabs(-5) #--> 5	Ring function
? Abs(-5)  #--> 5	Softanza function

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

? StzNumberQ("-5.23456").Absolute()
#--> "5.23456"

proff()
# Executed in 0.17 second(s)

/*==================

pron()

# There is a difference in Softanza between IsEither() and IsEitherA().
# The first checks for VALUES while the second checks for TYPES:

o1 = new stzNumber(5)
? o1.IsEither(5, :Or = 12)		#--> TRUE
? o1.IsEitherA(:Number, :Or = :String)	#--> TRUE

o1 = new stzList(1:3)
? o1.IsEither(1:3, :Or = 2:7) 		#--> TRUE
? o1.IsEitherA(:List, :Or = :String)	#--> TRUE

o1 = new stzString("ring")
? o1.IsEither("ring", :or = "ruby")	#--> TRUE
? o1.IsEitherA(:String, :Or = :List)	#--> TRUE

proff()
# Executed in 0.06 second(s)

/*================== ToNumber() and ToNumberW()

pron()

? Q(5).ToNumber()
#--> 5

? Q("5").ToNumber()
#--> 5

? Q([ "a", "b", "c" ]).ToNumber()
#--> 3

proff()
# Executed in 0.03 second(s)

/*------------------

StartProfiler()

? Q(-5).ToNumberW('{ @number = Q(@number).Abs() }')
#--> 5

? Q(5).ToNumberW('{ @number = @number + 5 }')
#--> 10

? QR([ -1, 2, -3, -4, 5 ], :stzListOfNumbers).ToNumberW('{ @number = This.Sum() }')
#--> -1

StopProfiler()
#--> Executed in 0.12 seconds seconds.

/*------------------

StartProfiler()

? Q("Ring").ToNumberW('{
	@number = len(@string)
}')
#--> 4

? Q("Ring").ToNumberXT('{
	@number = Q(@string).NumberOfCharsW("Q(@char).IsLowercase()")
}')
#--> 3

? Q("Ring").ToNumberXT('{
	@number = Q(@string).UnicodesQR(:stzListOfNumbers).Sum()
}')
#--> 400

# In fact:
	? @@( Q("Ring").Unicodes() )
	#--> [ 82, 105, 110, 103 ]

	? Q("Ring").ToNumberXT('{
		@number += Q(@char).Unicode()
	}')
	#--> 400

StopProfiler()
#--> Executed in 0.30 seconds seconds.

/*------------------

pron()

? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }') # Or ToNumberXT()
#--> 3

? Q([ "a", "b", "c" ]).ToNumberW('{
	@number = QR(@list, :stzListOfChars).UnicodesQR(:stzListOfNumbers).Sum()
}')
#--> 294

# In fact:
? QR(["a", "b", "c"], :stzListOfChars).Unicodes() #--> [97, 98, 99]

? Q([ "Me", "and", "You!" ]).ToNumberW('{ @number += len(@item) }')
#--> 9

# In fact:
? Q([ "Me", "and", "You!" ]).Yield('len(@item)')
#--> [2, 3, 4]

proff()
# Executed in 0.21 second(s)

/*=================

pron()

? Q(StzTypesXT()).IsHashList()
#--> TRUE

? StzHashListQ(StzTypesXT()).FindValue('stzchars')
#--> 17

proff()
#--> Executed in 0.06 second(s)

/*-----------------

pron()

? PluralOfThisStzType(:stzchar)
#--> "stzchars"

? StzTypeToPlural(:stzchar)
#--> "stzchars"

? PluralToStzType(:stzchars)
#--> "stzchar"

proff()
# Executed in 0.06 second(s)

/*-----------------

pron()

? Q("2").IsA([ :Number, :Or = :String, :Or = :List ])
#--> TRUE
# Same as: ? Q("2").IsOneOfTheseTypes([ :Number, :String, :List ])

? Q([10, 20]).IsA([ :List, :Pair, :ListOfNumbers, :PairOfNumbers ])
#--> TRUE

? Q("str").IsAList()
#--> FALSE

? Q("str").IsANumber()
#--> FALSE

? Q("str").IsAString()
#--> TRUE

? Q("5").IsNumberInString()
#--> TRUE

? Q("str").IsA(:String)
#--> TRUE

? Q("str").IsA(:StzString)
#--> TRUE

? Q("str").IsAn(:Object)
#--> TRUE

? Q("2").IsAString()
#--> TRUE

? Q("2").IsA(:String)
#--> TRUE

? Q("2").IsA(:NumberInString)
#--> TRUE

? Q("2").IsEitherA(:Number, :Or = :String)
#--> TRUE

? Q("2").IsOneOfThese([ 3, "2", 5 ])
#--> TRUE

? Q([ 10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

proff()
# Executed in 0.15 second(s)

/*=======

pron()

o1 = new stzList([ 6, -2, 9, 5, -10 ])
? o1.EachItemIsEitherA(:Positive, :Or = :Negative, :Number)
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*------ #TODO

pron()

? Q(["a", 3, "c"]).IsAQ(:list).Of([ :Numbers, :and = :strings ])

proff()

/*------

pron()

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA( :Number, :Or, :String )
#--> TRUE

proff()
# Executed in 0.14 second(s)

/*------ #TODO

pron()

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, [ :Lowercase, :Latin, :String ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, :String )

? o1.EachItemIsEitherA( :Number, :Or, [ :Lowercase, :Latin, :String ])

proff()

/*------

pron()

o1 = new stzList([ 120, "1250", 54, "452" ])
? o1.EachItemIsEither( :Number, :Or, :NumberInString )
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*------ #TODO

pron()

o1 = new stzList([ 2, 4, 8, "-129", 10, "-100.45" ])
? o1.EachItemIsEither([ :Positive, :Even, :Number ], :Or, [ :Negative, :NumberInString ] )

proff()

/*------------

pron()

? Q([10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

? Q([10, 20, 30 ]).Is(:ListOfNumbers)
#--> TRUE

? Q([ "1", "2", "3" ]).EachItemIsA([ :String, :NumberInString, :Char ])
#--> TRUE


proff()
# Executed in 0.03 second(s)

/*--------------------

pron()

o1 = new stzNumber(12500)

? o1.Is(:StzNumber)
#--> TRUE

? o1.Is(:String)
#--> FALSE

proff()
# Executed in 0.03 second(s)

/*--------------------

pron()

o1 = new stzString("hello")
? o1.Is(:StzString)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*--------------------

pron()

o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new QString2()
? IsQObject(o1)
#--> TRUE

? IsQtObject(o1)
#--> TRUE

# Both return TRUE --> Flexible syntax!

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

? HowManyStzClasses()
#--> 60

? HowManyRingQtClasses()
#--> 368

proff()
# Executed in 0.03 second(s)

