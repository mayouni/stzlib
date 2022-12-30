load "stzlib.ring"

/*==================

? fabs(-5) #--> 5	Ring function
? Abs(-5)  #--> 5	Softanza function

/*------------------

? StzNumberQ("-5.23456").Absolute()
#--> "5.23456"

/*==================

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

/*==================

? Q(5).ToNumber()
#--> 5

? Q("5").ToNumber()
#--> 5

? Q([ "a", "b", "c" ]).ToNumber()
#--> 3

/*------------------

StartProfiler()

? Q(-5).ToNumberXT('{ @number = Q(@number).Abs() }')
#--> 5

? Q(5).ToNumberXT('{ @number = @number + 5 }')
#--> 10

? QR([ -1, 2, -3, -4, 5 ], :stzListOfNumbers).ToNumberXT('{ @number = This.Sum() }')
#--> -1

StopProfiler()
#--> Executed in 0.07 seconds seconds.

/*------------------

StartProfiler()

? Q("Ring").ToNumberXT('{
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
	? @@S( Q("Ring").Unicodes() )
	#--> [ 82, 105, 110, 103 ]

? Q("Ring").ToNumberXT('{
	@number += Q(@char).Unicode()
}')
#--> 400

StopProfiler()
#--> Executed in 0.24 seconds seconds.

/*------------------

? Q([ "a", "b", "c" ]).ToNumberXT('{ @number = len(@list) }')
#--> 3

? Q([ "a", "b", "c" ]).ToNumberXT('{
	@number = QR(@list, :stzListOfChars).UnicodesQR(:stzListOfNumbers).Sum()
}')
#--> 294

# In fact:
? QR(["a", "b", "c"], :stzListOfChars).Unicodes() #--> [97, 98, 99]

? Q([ "Me", "and", "You!" ]).ToNumberXT('{ @number += len(@item) }')
#--> 9

# In fact:
? Q([ "Me", "and", "You!" ]).Yield('len(@item)') #--> [2, 3, 4]

/*----------------

o1 = new stzList([ 1, 2, 3 ])
? o1.ToNumberXT('
	@number = YieldAndCumulateXT("@item", :ReturnLast)
')
#--> 6

/*-----------------

o1 = new stzList([ "one", "two", "three" ])
? o1.ToNumber()
#--> 3

? o1.ToNumberXT('
	@number = YieldAndCumulateXT("len(@item)", :ReturnLast )
')
#--> 11

/*=================

? Q(StzTypesXT()).IsHashList()
#--> TRUE

? StzHashListQ(StzTypesXT()).FindValue('stzchars')
#--> 17

/*-----------------

? PluralOfThisStzType(:stzchar)
#--> "stzchars"

? StzTypeToPlural(:stzchar)
#--> "stzchars"

? PluralToStzType(:stzchars)
#--> "stzchar"

/*-----------------

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

/*------------ TODO: Check error

# Using a ChainOfTruth (started with "_" and ended with "_":

? _([10, 20, 30 ]).IsA(:ListOfNumbers)._
#--> TRUE

# The chain of truth is more useful when we chain more checks
# in the same time:

? _([ :name = "mio", :age = 12 ]).
	IsA(:List).
	IsA(:HashList).
	IsA(:Pair)._
#--> TRUE

/*--------------------

? StzClasses()

/*--------------------

o1 = new stzNumber(12500)
? o1.Is(:StzNumber)
? o1.Is(:String)

/*--------------------

o1 = new stzString("hello")
? o1.Is(:StzString)

/*--------------------

o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

/*--------------------

o1 = new Person { name = "Ali" age = 32 job = "Developer" }

# NOTE: if you provide the name of the object in a string (as :o1),
# then you can get the variable name of the object using ObjectVarName()

StzObjectQ( :o1 ) {

	? "ID: " + ObjectUID() + NL

	? "Object Name: " + ObjectVarName() + NL

	? "Object class: " + ObjectClassName() + NL

	? "Attributes:"
	? ObjectAttributes()

	? "Values:"
	? ObjectValues()

	? "Attributes and their values:"
	? ObjectAttributesAndValues()

	? "Methods:"
	? ObjectMethods()

	? "Object listified:"
	? Listify()

}

class Person
	name
	age
	job

	def init(cName)
		name = cName

	def show()
		? "Name : " + name
		? "Age  : " + age
		? "Job  : " + job

/*----------------

o1 = new QString()
? IsQObject(o1)
? IsQtObject(o1)

# Both return TRUE --> Flexible syntax!

/*----------------

? len(RingQtClasses())

o1 = new stzString("n")

? IsConstraintObjectParam(o1)
? IsConstraintObjectParam(:In = o1)
? IsConstraintObjectParam(:InObject = o1)
? IsConstraintObjectParam(:On = o1)
? IsConstraintObjectParam(:OnObject = o1)
