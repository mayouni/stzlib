load "../stzbase.ring"

/*--------
*/
pr()

o1 = new Person
? attributes(o1) # A Ring function
#--> [ "age", "job" ]

# Softanza functions

? HowManyAttributes(o1)

? HasAttribute(o1, "age")
#--> TRUE

? HasAttribute(o1, "nothing")

pf()

class Person
	name
	age
	job

/*--------------

pr()

? NullObject().Name()
#--> @nullobject

? Q(NullObject()).IsNamedObject()
#--> TRUE

#--

? TRUEObject().Name()
#--> @trueobject

? Q(TrueObject()).IsNamedObject()
#--> TRUE

#--

? FALSEObject().Name()
#--> @falseobject

? Q(FalseObject()).IsNamedObject()
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*--------------

pr()

StzNamedObjectQ(:myobj = TRUEObject()) {

	? Name()
	#--> :myobj

	? StzType()
	#--> :stznumber

}

# Executed in 0.03 second(s)

/*==============

pr()

? @@( StzNullObjectQ() )
#--> @noname

? @@([ StzNullObjectQ() ])
#--> [ @noname ]

? @@([ 1:3, StzNullObjectQ(), "a":"b", StzFalseObjectQ() ])
#!--> [ [ 1, 2, 3 ], @noname, [ "a", "b" ], @noname ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20

/*==================

pr()

? fabs(-5) #--> 5	Ring function
? Abs(-5)  #--> 5	Softanza function

pf()
# Executed in 0.03 second(s)

/*------------------

pr()

? StzNumberQ("-5.23456").Absolute()
#--> "5.23456"

pf()
# Executed in 0.17 second(s)

/*==================

pr()

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

pf()
# Executed in 0.06 second(s)

/*================== ToNumber() and ToNumberW()

pr()

? Q(5).ToNumber()
#--> 5

? Q("5").ToNumber()
#--> 5

? Q([ "a", "b", "c" ]).ToNumber()
#--> 3

pf()
# Executed in 0.03 second(s)

/*------------------

StartProfiler()

? Q(-5).ToNumberW('{ @number = Q(@number).Abs() }')
#--> 5

? Q(5).ToNumberW('{ @number = @number + 5 }')
#--> 10

? QRT([ -1, 2, -3, -4, 5 ], :stzListOfNumbers).ToNumberW('{ @number = This.Sum() }')
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
	@number = Q(@string).UnicodesQRT(:stzListOfNumbers).Sum()
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

pr()

? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }') # Or ToNumberXT()
#--> 3

? Q([ "a", "b", "c" ]).ToNumberW('{
	@number = QRT(@list, :stzListOfChars).UnicodesQRT(:stzListOfNumbers).Sum()
}')
#--> 294

# In fact:
? QRT(["a", "b", "c"], :stzListOfChars).Unicodes() #--> [97, 98, 99]

? Q([ "Me", "and", "You!" ]).ToNumberW('{ @number += len(@item) }')
#--> 9

# In fact:
? Q([ "Me", "and", "You!" ]).Yield('len(@item)')
#--> [2, 3, 4]

pf()
# Executed in 0.21 second(s)

/*=================

pr()

? Q(StzTypesXT()).IsHashList()
#--> TRUE

? StzHashListQ(StzTypesXT()).FindValue('stzchars')
#--> 17

pf()
#--> Executed in 0.06 second(s)

/*-----------------

pr()

? PluralOfThisStzType(:stzchar)
#--> "stzchars"

? StzTypeToPlural(:stzchar)
#--> "stzchars"

? PluralToStzType(:stzchars)
#--> "stzchar"

pf()
# Executed in 0.06 second(s)

/*-----------------

pr()

? RingTypes()
? StzTypes()

? @IsRingOrStzType(:PairOfNumbers)

pf()

/*-----------------

pr()

? Q("2").IsA([ :Number, :String, :List ])
#--> FALSE

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

? Q("2").IsAXT([ :NumberInString ])
#--> TRUE

? Q("2").IsA(:NumberInString)
#--> TRUE

? Q("2").Is(:NumberInString)
#--> TRUE

? Q("2").Is(:NumberInString)
#--> TRUE

#--> TRUE

? Q("2").IsEitherA(:Number, :Or = :String)
#--> TRUE

? Q("2").IsOneOfThese([ 3, "2", 5 ])
#--> TRUE

? Q([ 10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.21

/*=======

pr()

o1 = new stzList([ 6, -2, 9, 5, -10 ])
? o1.EachItemIsEitherA(:Positive, :Or = :Negative, :Number)
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*------ #TODO

pr()

? Q(["a", 3, "c"]).IsAQ(:list).Of([ :Numbers, :and = :strings ])

pf()

/*------

pr()

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA( :Number, :Or, :String )
#--> TRUE

pf()
# Executed in 0.14 second(s)

/*------ #TODO

pr()

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, [ :Lowercase, :Latin, :String ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, :String )

? o1.EachItemIsEitherA( :Number, :Or, [ :Lowercase, :Latin, :String ])

pf()

/*------

pr()

o1 = new stzList([ 120, "1250", 54, "452" ])
? o1.EachItemIsEither( :Number, :Or, :NumberInString )
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*------ #TODO

pr()

o1 = new stzList([ 2, 4, 8, "-129", 10, "-100.45" ])
? o1.EachItemIsEither([ :Positive, :Even, :Number ], :Or, [ :Negative, :NumberInString ] )

pf()

/*------------

pr()

? Q([10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

? Q([10, 20, 30 ]).Is(:ListOfNumbers)
#--> TRUE

? Q([ "1", "2", "3" ]).EachItemIsA([ :String, :NumberInString, :Char ])
#--> TRUE


pf()
# Executed in 0.03 second(s)

/*--------------------

pr()

o1 = new stzNumber(12500)

? o1.Is(:StzNumber)
#--> TRUE

? o1.Is(:String)
#--> FALSE

pf()
# Executed in 0.03 second(s)

/*--------------------

pr()

o1 = new stzString("hello")
? o1.Is(:StzString)
#--> TRUE

pf()
# Executed in 0.03 second(s)

/*--------------------

pr()

o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new QString2()
? IsQObject(o1)
#--> TRUE

? IsQtObject(o1)
#--> TRUE

# Both return TRUE --> Flexible syntax!

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

? HowManyStzClasses()
#--> 60

? HowManyRingQtClasses()
#--> 368

pf()
# Executed in 0.03 second(s)

