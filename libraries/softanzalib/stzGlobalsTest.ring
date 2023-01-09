load "stzlib.ring"

/*===================
*/
# The following is an exploration of the comprative performance
# of for loops and for/in loops.

# If we iterate over a list of 200 thousand numbers using for/in,
# and without doing anything inside the loop, Ring does it in
# approximately 0.40 seconds (note that would depend of the actual
# hardawre configuration but what we are alayzing here are
# the proposrtional differences not the actual values):

	StartTimer()
	
	aList = 1 : 200_000
	for n in aList
		// do nothing
	next
	
	? ElapsedTime()

# Let's compare it with a for loop:

	StartTimer()
	
	aList = 1 : 200_000

	for i = 1 to len(aList)
		// do nothing
	next
	
	? ElapsedTime()

# It's done in say 0.35 seconds. Not a big difference!

# Now, what if we omit the call of the function len() from the loop declaration
# and put in a variable, like this:

	StartTimer()
	
	aList = 1 : 200_000
	nLen = len(aList)
	for i = 1 to nLen
		// do nothing
	next
	
	? ElapsedTime()

# It's executed in 0.05 seconds! Say 8 times more performant then for/in!

# But wait, in the for/in snippet above, we used the variable aList = 1 : 200_000
# and then called it in the loop declaration like this : for n in aList, right?

# So, what if we omit that and use the data 1:200_000 directly like this:

	StartTimer()
	
//	for n in 1 : 200_000
		// do nothing
//	next
	
	? ElapsedTime()

# Wow! It's sooo slow!! I aborted the process after more then 30 minutes...

# So, this is the first thing we should learn:
# NEVER USE A FUNCTION CALL IN THE LOOP DECLARATION.

# Now, let's take a step towards reality, and do something
# inside the loop:

	StartTimer()

	aList = 1 : 200_000
	nLen = len(aList)
	nSum = 0

	for i = 1 to nLen 
		nSum += aList[i]
	next

	? ElapsedTime()

# For loop made it so quickly in 0.09 seconds! What about for/in loops?

	StartTimer()

	aList = 1 : 200_000
	nSum = 0

	for n in aList 
		nSum += n
	next

	? ElapsedTime()

# It's about 0.39 seconds, say 3 times slower then for loops.

# Now, what if we challenge for/in loop with what it is normally made for:
# the possibility of changing the items values while looping over them...

# To do so, we want to update the item n by the value (n + 2 * n):

	StartTimer()

	aList = 1 : 200_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()

# Done in 0.41 seconds (less then a second), which is quiet nice!
# Will for loop win the battle as usual? Let's see...

	StartTimer()

	aList = 1 : 200_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()

# Oh! For loop made it in 0.11 seconds, 3 times faster!

# Let's try it for a list as large as 1 million items:
# for/in loop performs  it in more then 5 seconds (5.46s)...

	StartTimer()

	aList = 1 : 1_000_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()

# While for loop performs it in less then a second! (0.80s):

	StartTimer()

	aList = 1 : 1_000_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()

# this time, it's 7 times faster!

# Then, this is the second thing we should learn, when performance is
# a critical requirement to your algorithm:
# ALWAYS USE THE FOR LOOP INSTEAD OF THE FOR/IN LOOP

/*===================

? Stz(:Number, :Class)
#--> "stznumber"
# You can also say: ? StzNumberClass()

? @@S(Stz(:Number, :Attributes))
#--> [ "@oobject", "@cobjectvarname", "@cnumber" ]
# You can also say: ? StzNumberAttributes()

? Stz(:Number, :Methods)
#--> [ "init", "content", "initialcontent", "copy", ... ]
# You can also say: ? StzNumberMethods()

/*=========

? Q("A").RepeatedNTimes(3) # Or Repeated(3)
#--> "AAA"

? @@S( Q([1,2]).RepeatedNTimes(3) ) # Or Repeated(3)
#--> [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ] ]

? Q(10).RepeatedNTimes(3) # Or Repeated(3)
#--> [ 30, 30, 30 ]

# Don't confuse it with
? Q(10).Times(3)
#--> 30

/*===========

# Some features come to empower metaprogramming

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
#	- you define a variable and add the "=" operator ("o1 =" for example)
#	- you use "new" keyword
#	- you specify the name of the class describing the object
#	- you put the values of the required params


o1 = new_stz(:String, "hi") # now you have the stzString object created
? o1.Uppercased() #--> "HI3"

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

/*=============

? Q("(,,)").Check(:That = 'StzCharQ(@Char).IsPunctuation()')
#--> TRUE

/*============ INFERRING TYPES: Q() & QQ()
# NOTE: Unlike Ring, Softanza return type in lowercase.

Q("ring") {
	? Type()	#--> "object"
	? IsAnObject()	#--> TRUE
	? StzType()	#--> "stzstring"
}

/*------------

Q(6) {
	? Type()	#--> "object"
	? StzType()	#--> "stznumber"
}

/*------------

Q(1:3) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ(1:3) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlistofnumbers"
}

/*------------

Q("A":"C"){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ("A":"C"){
	? Type()	#--> "object"
	? StzType()	#--> "stzlistofstrings"
}

/*------------

Q([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

# Now we start infering type at the second level:

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlistoflists"
}


/*------------

Q([ "A", 20, "B", 30 ]) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ([ "A", 20, "B", 30 ]) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@S( Types() )
	#--> [ "string", "number", "string", "number" ]
}

/*------------

Q([ "A", 20, [ "B" ], 30 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@S( Types() )
	#--> [ "string", "number", "list", "number" ]
}

/*------------

Q([ "A", 20, [ "B", 10 ], 30 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@S( Types() )
	#--> [ "string", "number", "list", "number" ]
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

# The InfereType() function is useful for internal features
# of SoftanzaLib, in order to enable the goal of expressive code.

# In particular, it is used in the stzList.IsListOf(pcType) method.

# From a particular string, it tries to detect the most relevant
# Ring or Softanza type.

# So, Softanza can do its best to infere the type included
# in a string, whatever form the string takes: lowercase or
# uppercase, and singular or plural!

? Q('number').InfereType()		#--> :Number
? Q('String').InfereType()		#--> :String

? Q('NuMBer').InfereType()		#--> :Number
? Q('STRING').InfereType()		#--> :String

? Q('numbers').InfereType()		#--> :Number
? Q('STRINGS').InfereType()		#--> :String

? Q(:StzNumber).InfereType()		#--> :StzNumber
? Q(:StzNumbers).InfereType()		#--> :StzNumber

? Q(:ListOfNumbers).InfereType()	#--> :List
? Q(:ListsOfNumbers).InfereType()	#--> :List

? Q(:PairOfNumbers).InfereType()	#--> :List
? Q(:PairsOfNumbers).InfereType()	#--> :List

? Q(:StzListOfNumbers).InfereType()	#--> :StzListOfNumbers
? Q(:StzListsOfNumbers).InfereType()	#--> :StzListOfNumbers

? Q(:ListOfStzStrings).InfereType()	#--> :List
? Q(:ListsOfStzStrings).InfereType()	#--> :List

? Q(:Pair).InfereType()			#--> :List

/*=================

? ComputableForm(4) # or use the abbreviated form @@(4)
# --> 4

? ComputableForm("Ring")
#--> "Ring"

? ComputableForm([ 1, 2, "a" ])
#--> [
#	1,
#	2,
#	"a"
#]

? ComputableFormSimplified([ 1, 2, "a" ]) # or use the abbreviated form @@S(...)
#--> [ 1, 2, "a" ]


/*================
*/
# Look at theses statements and guess their results:

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

Surprised?

The point is that Unicode assigns unique code to Chars and
not to their visual glyfs. To give a clear example:

"O", "Ο", and "О" seam the same for us, and for the particular
font we use in our system to render them, but from a unicode
standpoint, they are different.

If you try to get their unicode code points, you find them
respectively: 79, 927, and 1054.

In fact, the first is Latin "O", the second is Greek "Ο", and
the third is Cyrillic "О".


