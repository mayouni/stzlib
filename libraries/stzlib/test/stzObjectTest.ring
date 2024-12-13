load "../max/stzmax.ring"

/*--------------

profon

? NullObject().Name()
#--> @nullobject

? Q(NullObject()).IsNamedObject()
#--> _TRUE_

#--

? _TRUE_Object().Name()
#--> @trueobject

? Q(TrueObject()).IsNamedObject()
#--> _TRUE_

#--

? _FALSE_Object().Name()
#--> @falseobject

? Q(FalseObject()).IsNamedObject()
#--> _TRUE_

proff()
# Executed in 0.04 second(s)

/*--------------

profon

StzNamedObjectQ(:myobj = _TRUE_Object()) {

	? Name()
	#--> :myobj

	? StzType()
	#--> :stznumber

}

# Executed in 0.03 second(s)

/*==============

profon

? @@( StzNullObjectQ() )
#--> @noname

? @@([ StzNullObjectQ() ])
#--> [ @noname ]

? @@([ 1:3, StzNullObjectQ(), "a":"b", StzFalseObjectQ() ])
#!--> [ [ 1, 2, 3 ], @noname, [ "a", "b" ], @noname ]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20

/*==================

profon

? fabs(-5) #--> 5	Ring function
? Abs(-5)  #--> 5	Softanza function

proff()
# Executed in 0.03 second(s)

/*------------------

profon

? StzNumberQ("-5.23456").Absolute()
#--> "5.23456"

proff()
# Executed in 0.17 second(s)

/*==================

profon

# There is a difference in Softanza between IsEither() and IsEitherA().
# The first checks for VALUES while the second checks for TYPES:

o1 = new stzNumber(5)
? o1.IsEither(5, :Or = 12)		#--> _TRUE_
? o1.IsEitherA(:Number, :Or = :String)	#--> _TRUE_

o1 = new stzList(1:3)
? o1.IsEither(1:3, :Or = 2:7) 		#--> _TRUE_
? o1.IsEitherA(:List, :Or = :String)	#--> _TRUE_

o1 = new stzString("ring")
? o1.IsEither("ring", :or = "ruby")	#--> _TRUE_
? o1.IsEitherA(:String, :Or = :List)	#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*================== ToNumber() and ToNumberW()

profon

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

profon

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

profon

? Q(StzTypesXT()).IsHashList()
#--> _TRUE_

? StzHashListQ(StzTypesXT()).FindValue('stzchars')
#--> 17

proff()
#--> Executed in 0.06 second(s)

/*-----------------

profon

? PluralOfThisStzType(:stzchar)
#--> "stzchars"

? StzTypeToPlural(:stzchar)
#--> "stzchars"

? PluralToStzType(:stzchars)
#--> "stzchar"

proff()
# Executed in 0.06 second(s)

/*-----------------

profon

? RingTypes()
? StzTypes()

? @IsRingOrStzType(:PairOfNumbers)

proff()

/*-----------------
*/
profon

? Q("2").IsA([ :Number, :String, :List ])
#--> _FALSE_

? Q([10, 20]).IsA([ :List, :Pair, :ListOfNumbers, :PairOfNumbers ])
#--> _TRUE_

? Q("str").IsAList()
#--> _FALSE_

? Q("str").IsANumber()
#--> _FALSE_

? Q("str").IsAString()
#--> _TRUE_

? Q("5").IsNumberInString()
#--> _TRUE_

? Q("str").IsA(:String)
#--> _TRUE_

? Q("str").IsA(:StzString)
#--> _TRUE_

? Q("str").IsAn(:Object)
#--> _TRUE_

? Q("2").IsAString()
#--> _TRUE_

? Q("2").IsA(:String)
#--> _TRUE_

? Q("2").IsAXT([ :NumberInString ])
#--> _TRUE_

? Q("2").IsA(:NumberInString)
#--> _TRUE_

? Q("2").Is(:NumberInString)
#--> _TRUE_

? Q("2").Is(:NumberInString)
#--> _TRUE_

#--> _TRUE_

? Q("2").IsEitherA(:Number, :Or = :String)
#--> _TRUE_

? Q("2").IsOneOfThese([ 3, "2", 5 ])
#--> _TRUE_

? Q([ 10, 20, 30 ]).IsA(:ListOfNumbers)
#--> _TRUE_

proff()
# Executed in 0.10 second(s) in Ring 1.21

/*=======

profon

o1 = new stzList([ 6, -2, 9, 5, -10 ])
? o1.EachItemIsEitherA(:Positive, :Or = :Negative, :Number)
#--> _TRUE_

proff()
# Executed in 0.04 second(s)

/*------ #TODO

profon

? Q(["a", 3, "c"]).IsAQ(:list).Of([ :Numbers, :and = :strings ])

proff()

/*------

profon

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA( :Number, :Or, :String )
#--> _TRUE_

proff()
# Executed in 0.14 second(s)

/*------ #TODO

profon

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, [ :Lowercase, :Latin, :String ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, :String )

? o1.EachItemIsEitherA( :Number, :Or, [ :Lowercase, :Latin, :String ])

proff()

/*------

profon

o1 = new stzList([ 120, "1250", 54, "452" ])
? o1.EachItemIsEither( :Number, :Or, :NumberInString )
#--> _TRUE_

proff()
# Executed in 0.04 second(s)

/*------ #TODO

profon

o1 = new stzList([ 2, 4, 8, "-129", 10, "-100.45" ])
? o1.EachItemIsEither([ :Positive, :Even, :Number ], :Or, [ :Negative, :NumberInString ] )

proff()

/*------------

profon

? Q([10, 20, 30 ]).IsA(:ListOfNumbers)
#--> _TRUE_

? Q([10, 20, 30 ]).Is(:ListOfNumbers)
#--> _TRUE_

? Q([ "1", "2", "3" ]).EachItemIsA([ :String, :NumberInString, :Char ])
#--> _TRUE_


proff()
# Executed in 0.03 second(s)

/*--------------------

profon

o1 = new stzNumber(12500)

? o1.Is(:StzNumber)
#--> _TRUE_

? o1.Is(:String)
#--> _FALSE_

proff()
# Executed in 0.03 second(s)

/*--------------------

profon

o1 = new stzString("hello")
? o1.Is(:StzString)
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*--------------------

profon

o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

proff()
# Executed in 0.03 second(s)

/*----------------

profon

o1 = new QString2()
? IsQObject(o1)
#--> _TRUE_

? IsQtObject(o1)
#--> _TRUE_

# Both return _TRUE_ --> Flexible syntax!

proff()
# Executed in 0.04 second(s)

/*----------------

profon

? HowManyStzClasses()
#--> 60

? HowManyRingQtClasses()
#--> 368

proff()
# Executed in 0.03 second(s)

