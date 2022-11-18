load "stzlib.ring"

/*-------

? Stz(:Number, :Class)
#--> "stznumber"
# You can also say: ? StzNumberClass()

? @@S(Stz(:Number, :Attributes))
#--> [ "@oobject", "@cobjectvarname", "@cnumber" ]
# You can also say: ? StzNumberAttributes()

? Stz(:Number, :Methods)
#--> [ "init", "content", "initialcontent", "copy", ... ]
# You can also say: ? StzNumberMethods()

/*-------

? Q("A").NTimes(3) # Or RepeatedNTimes(3)
#--> "AAA"

? @@S( Q([1,2]).NTimes(3) ) # Or RepeatedNTimes(3)
#--> [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ] ]

? Q(10).NTimes(3) # Or RepeatedNTimes(3)
#--> [ 30, 30, 30 ]

# Don't confuse with
? Q(10).Times(3)
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



/*============ INFERRING TYPES: Q() & QQ()

Q("ring") {
	? Type()	#--> "OBJECT"
	? IsAnObject()	#--> TRUE
	? StzType()	#--> "stzstring"
}

/*------------

Q(6) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stznumber"
}

/*------------

Q(1:3) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
}

QQ(1:3) {
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistofnumbers"
}

/*------------

Q("A":"C"){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
}

QQ("A":"C"){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistofstrings"
}

/*------------

Q([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
}

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistoflists"
}

/*------------

Q([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
}

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlistoflists"
}

/*------------

Q([ "A", 20, "B", 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
}

/*------------

Q([ "A", 20, [ "B" ], 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"
	? @@S( Types() )+NL	#--> [ "STRING", "NUMBER", "LIST", "NUMBER" ]
}

/*------------

Q([ "A", 20, [ "B", 10 ], 30 ]){
	? Type()	#--> "OBJECT"
	? StzType()	#--> "stzlist"

	? @@S( Types() )	#--> [ "STRING", "NUMBER", "LIST", "NUMBER" ]
}

/*==============

? Q(:ListsOfObjects).InfereType() #--> :List

/*--------------

? Q([ 1, 2, 3 ]).IsListOf(:Numbers)		#--> TRUE
? Q([ "A", "B", "C" ]).IsListOf(:Strings)	#--> TRUE

o1 = new stzNumber(10)
? Q([ o1, o1, o1 ]).IsListOf(:StzNumbers)	#--> TRUE

o1 = new stzString("A")
? Q([ o1, o1, o1 ]).IsListOf(:StzStrings)	#--> TRUE

? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:ListsOfNumbers)	#--> TRUE
? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:PairsOfNumbers)	#--> TRUE

/*-------------------

# NOTE: the function is useful for internal features of SoftanzaLib,
# inorder to enable the goal of expressive code.

# In particular, it is used in the stzList.IsListOf(pcType) method.

# From a particular string, it tries to detect the most relevant
# Ring or Softanza type.

# So, Softanza can do its best to infere the type included
# in a string, whatever form the 	string takes: lowercase or
# uppercase, and singular or plural!

? Q('number').InfereType()		# --> :Number
? Q('String').InfereType()		# --> :String

? Q('NuMBer').InfereType()		# --> :Number
? Q('STRING').InfereType()		# --> :String

? Q('numbers').InfereType()		# --> :Number
? Q('STRINGS').InfereType()		# --> :String

? Q(:StzNumber).InfereType()		# --> :StzNumber
? Q(:StzNumbers).InfereType()		# --> :StzNumber

? Q(:ListOfNumbers).InfereType()	# --> :List
? Q(:ListsOfNumbers).InfereType()	# --> :List

? Q(:PairOfNumbers).InfereType()	# --> :List
? Q(:PairsOfNumbers).InfereType()	# --> :List

? Q(:StzListOfNumbers).InfereType()	# --> :StzListOfNumbers
? Q(:StzListsOfNumbers).InfereType()	# --> :StzListOfNumbers

? Q(:ListOfStzStrings).InfereType()	# --> :List
? Q(:ListsOfStzStrings).InfereType()	# --> :List

? Q(:Pair).InfereType()	# --> :List

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
