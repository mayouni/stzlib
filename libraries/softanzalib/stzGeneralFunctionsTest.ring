load "stzlib.ring"

? NTimes(3, "A")
#--> "AAA"

? @@S( NTimes(3, [1,2]) )
#--> [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ] ]

? NTimes(3, 10)
#--> 30

/*-------

# Some features come to empower metaprogramming in Softanza.

# In softanza, creating new objects is made using the new keyword.
# So if you want to make a new stzString you say:

o1 = new stzString("hi")

# and when you want to make a stzList you say:

o1 = new stzList(1:3)

# But, sometimes, you need more flexibility in defining what kind
# of object you need to create. In practice, this would happen,
# when the type object to be creaded can not be known statically
# in the code, but in the runtime depending on a given value.

# To do it, Softanza comes with the new_stz() function that embraces
# the same mental model of the Ring new keyword:
#	- you define a variable and add the = operator (o1 = for example)
#	- you use new keyword
#	- you specify the name of the class describing the object
#	- you put the values of the required params


o1 = new_stz(:String, "hi") # now you have the stzString object created
? o1.Uppercased() #--> "HI3

o1 = new_stz(:List, 1:3)
? o1.NumberOfItems() #--> 3

# Also, you may need to have the list of methods or attributes of a given
# object or class). Of course, you can use Ring methods() function.
# but this requires you to create a Softanza object before and then pass
# it to the function, like this:

o1 = new stzString("blablabla")
? methods(o1)

# In Softanza, you are not obliged to create any object, just say:
? Stz(:Char, :Methods)		#--> [ ... ]

# or if you want to have the attributes:
? Stz(:String, :Attributes) 	#--> [ :@oObject, :@cObjectVarName, :@oQChar ]

# You can even make a filter on the list of methods to return only those
# that verify a given condition:

? Stz(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
#--> [ :isLeftToRight, :IsRightToLeft, ... ]

/*----

? Q("(,,)").Check(:That = 'StzCharQ(@Char).IsPunctuation()')
#--> TRUE

/*----
/*
? Q("(9, 7, 8)").DataType()	#--> :String

? QQ("(9, 7, 8)").DataType()
? QQ("3 + 2 = 5").DataType()

/*------------ // TODO

? Q("12500$USD").DataType()	#!--> :Number

/*------------

? Q("5").DataType()	#--> "string"	because its elevated to a stzString object
? QQ("5").DataType()	#--> "number"	because its elevated to a stzNumber object

? Q(1:3).DataType()	#--> "number"

/*============ INFERING TYPES: Q() & QQ()

Q("ring") {
	? Type()	#--> "OBJECT"
	? IsAnObject()	#--> TRUE

	? StzType()	#--> "stzstring"
	? DataType()+NL	#--> "string"
}

/*------------

Q(6) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stznumber"
	? DataType()+NL	#--> "number"
}

/*------------

Q(1:3) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "list"
}

QQ(1:3) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistofnumbers"
	? DataType()+NL	#--> "number"
}

/*------------

Q("A":"C"){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "string"
}

QQ("A":"C"){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistofstrings"
	? DataType()+NL	#--> "string"
}

/*------------

Q([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "list"
}

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistoflists"
	? DataType()+NL	#--> "list"
}

/*------------

Q([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "list"
}

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistoflists"
	? DataType()+NL	#--> "list"
}

/*------------

Q([ "A", 20, "B", 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "hybrid"

	? @@S( DataTypes() )	#--> [ "string", "number", "string", "number" ]
	? @@S( Types() )+NL	#--> [ "STRING", "NUMBER", "STRING", "NUMBER" ]
}

/*------------

Q([ "A", 20, [ "B" ], 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "hybrid"

	? @@S( DataTypes() )	#--> [ "string", "number", "string", "number" ]
	? @@S( Types() )+NL	#--> [ "STRING", "NUMBER", "LIST", "NUMBER" ]
}

/*------------

Q([ "A", 20, [ "B", 10 ], 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "hybrid"

	? @@S( DataTypes() )	#--> [ "string", "number", "hybrid", "number" ]
	? @@S( Types() )	#--> [ "STRING", "NUMBER", "LIST", "NUMBER" ]
}

/*============ INFERING TYPES: Q() and QQ()
/*
# The Q() function elevates a value to its corresponding ring type.
# so Q(5) gives a stzNumber object, Q("m") gives a stzString object,
# Q([]) gives a stzList object, and finally Q(obj) gives a stzObject.

# There are three interesting information about types in a Softanza object:
#	- Type(): the type of the object returned by Q(), and it's always "OBJECT"
#		  (note that we stay confrom with Ring type() function)
#	- StzType() : the name of the softanza class related to the object
#	- DataType(): the type of data included inside the value.

# We will understand all that using the following samples.

Q("m") {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzstring"
	? DataType()+NL	#--> "string"

	#--> Read it like this: this an object,
	# from the class stzString, containg
	# data of type string.
}

# Nice! The "m" string is elevated to a stzString object, and now all the
# features of stzString are in your hands!

# We are going just to uppercase it, so we add these lines:
Q("m") {
	# ... #
	Uppercase()
	Show() #--> "M"
}

# Ok! "M" is a string but also a char, and Softanza has a powerful class
# to manage chars called stzChar...

# Do you want to get the unicode number of the letter char?
# And its unicode name? Or may ya want to get its script and defautl
# language? Or even try to turn it altogether (ie invert it) and
# see what happens...

# You can do this and more by elevating the string "M" to a stzChar object.
# No need of using the new stzChar("M") syntax because QQ() does just that!

QQ("m") {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzchar"	# Now we switched from stzString to stzChar

	? DataType()	#--> "string"	# What is returned by Datatype() is
					# always one of the 4 native Ring types!
	
	Uppercase()	#--> Becomes "M"

	? Unicode()	#--> 114
	? Name()	#--> LATIN SMALL LETTER R
	? Script()	#--> :Latin
	? Language()	#--> :English

	Turn()
	Show()		#--> "Ɯ"

	# Are you curious to know the name of that inverted char?
	? Name()	#--> LATIN CAPITAL LETTER TURNED M
}

/*----------------- Q(), QQ(), and QQQ() <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Q("[1, 2, 3]") {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzstring"
	? DataType()+NL	#--> "string"
}

QQ("[1, 2, 3]") {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "number"
}

QQQ("[1, 2, 3]") {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistofnumbers"
	? DataType()+NL	#--> "number"
}

Q(["A", "B", "C"]) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "string"
}

Q(["A", 1, "B", 2]) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? DataType()+NL	#--> "hybrid"
	? DataTypes()	#--> [ "string", "number", "string", "number" ]
}

/*==============

? InfereDataTypeFromString(:ListsOfObjects) #--> :List

/*--------------

? Q([ 1, 2, 3 ]).IsListOf(:Numbers)		#--> TRUE
? Q([ "A", "B", "C" ]).IsListOf(:Strings)	#--> TRUE

o1 = new stzNumber(10)
? Q([ o1, o1, o1 ]).IsListOf(:StzNumbers)	#--> TRUE

o1 = new stzString("A")
? Q([ o1, o1, o1 ]).IsListOf(:StzStrings)	#--> TRUE

? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:ListsOfNumbers)	#--> TRUE
? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:PairsOfNumbers)	#--> TRUE

/*------------------- InfereDataTypeFromString

# NOTE: the function is useful for internal features of SoftanzaLib,
# inorder to enable the goal of expressive code.

# In particular, it is used in the stzList.IsListOf(pcType) method.

# From a particular string, it tries to detect the most relevant
# Ring or Softanza type.

# So, Softanza can do its best to infere the datatype included
# in a string, whatever form the string takes: lowercase or
# uppercase, and singular or plural!

? InfereDataTypeFromString('number')	# --> :Number
? InfereDataTypeFromString('String')	# --> :String

? InfereDataTypeFromString('NuMBer')	# --> :Number
? InfereDataTypeFromString('STRING')	# --> :String

? InfereDataTypeFromString('numbers')	# --> :Number
? InfereDataTypeFromString('STRINGS')	# --> :String

? InfereDataTypeFromString(:StzNumber)	# --> :StzNumber
? InfereDataTypeFromString(:StzNumbers)	# --> :StzNumber

? InfereDataTypeFromString(:ListOfNumbers)	# --> :List
? InfereDataTypeFromString(:ListsOfNumbers)	# --> :List

? InfereDataTypeFromString(:PairOfNumbers)	# --> :List
? InfereDataTypeFromString(:PairsOfNumbers)	# --> :List

? InfereDataTypeFromString(:StzListOfNumbers)	# --> :StzListOfNumbers
? InfereDataTypeFromString(:StzListsOfNumbers)	# --> :StzListOfNumbers

? InfereDataTypeFromString(:ListOfStzStrings)	# --> :List
? InfereDataTypeFromString(:ListsOfStzStrings)	# --> :List

/*-------------------

# Getting the data type of the value(s) histed in the provided container:

? Q(5).DataType()		#--> :Number
? Q("Ring").DataType()	+ NL	#--> :String

? Q(1:3).DataType()		#--> :Number
? Q("A":"C").DataType()	+ NL	#--> :String

? Q(["A",1]).DataType()		#--> :Hybrid
? Q(["A",1]).DataTypes()	#--> [ :String, :Number ]

obj = new stzNullObject
? Q(obj).DataType()	# --> :Object


/*-------------------

? ComputableForm(4) # --> 4
? ComputableForm("Ring") # --> "Ring"
? ComputableForm([ 1, 2, "a" ]) # --> [ 1, 2, "a" ]
// TODO: the case of objects...

/*-------------------

? "۰" = "٠"	# --> FALSE
? "۱" = "١"	# --> FALSE
? "۲" = "٢"	# --> FALSE
? "۳" = "٣"	# --> FALSE
? "۸" = "٨"	# --> FALSE		
? "۹" = "٩"	# --> FALSE
? ""
? Unicode("۱")	# --> 1777
? Unicode("١")	# --> 1633
? ""
? AreEqual([ "O", "Ο", "О" ]) # --> FALSE
? ""
? Unicodes([ "O", "Ο", "О" ]) # --> [ 79, 927, 1054 ]
? Scripts([ "O", "Ο", "О" ]) # --> [ :Latin, :Greek, :Cyrillic ]


/*
The point is that Unicode assigns unique code to Chars and
not to their visual glyfs. To give a clear example:

"O", "Ο", and "О" seam the same for us, and for the particular
font we use in our system to render them, but from a unicode
stand point, they are different.

If you try to get their unicode code points, you find them
respectively: 79, 927, and 1054.

In fact, the first is Latin "O", the second is Greek "Ο", and
the third is Cyrillic "О".
*/

/*
? "٤" = "٤"	# TRUE		01636	01636
? "٥" = "٥"	# TRUE		01637	01637
? "٦" = "٦"	# TRUE		01638	01638
? "٧" = "٧"	# TRUE		01639	01639
*/
