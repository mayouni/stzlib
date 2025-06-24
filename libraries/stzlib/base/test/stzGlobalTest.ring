load "../stzbase.ring"

/*===

pr()

? IsStzFindable("ring")
#--> FALSE

? IsStzFindable(1:20)
#--> FALSE

? IsStzFindable( Q("ring") ) # because Q() elevates "ring" to a stzString object
#--> TRUE

? IsStzFindable( Q(1:20) ) # because Q() elevates 1:20 to a stzList object
#--> TRUE

? IsStzFindable( ANullObject() ) # it's a stzObject but it is not findable!
#--> FALSE

pf()
# Executed in 0.02 second(s)

/*===

pr()

? 3 : 5
#--> [ 3, 5 ]

? "3" : "5"
#--> [ "3", "4", "5" ]

? 10 : 12
#--> [ 10, 11, 12 ]

? "10" : "12"
#--> "10"

? L(' "10":"12" ')
#--> #--> [ "10", "11", "12" ]

pf()

/*=====

? 0 = ""

? "" = 0

? "0" = 0

? "1" = 1
#--> TRUE

? 1 = "01.0"
#--> TRUE

/*----

pr()

? BothAreEqual(0, "")
#--> FALSE

? BothAreEqual(1, "1")
#--> FALSE

? BothAreEqual([], "")
#--> FALSE

? BothAreEqual(1:3, [1, 2, 3])
#--> TRUE

? BothAreEqual("ring", "ring")
#--> TRUE

 ? BothAreEqual("RING", "ring")
#--> FALSE

? BothAreEqualCS("RING", "ring", FALSE)
#--> TRUE

? BothAreEqual("A":"C", "a":"c")
#--> FALSE

? BothAreEqualCS("A":"C", "a":"c", FALSE)
#--> TRUE

pf()
#--> Executed in 0.01 second(s) in Ring 1.21
#--> Executed in 0.04 second(s) in Ring 1.20

/*----

pr()

? AllHaveSameType([1, "1", 1])
#--> FALSE

pf()

/*----

pr()

? AreEqual([1, 1, 1])
#--> TRUE

? AreEqual([1, "1", 1])
#--> FALSE

? AreEqual([ "ring", "Ring", "RING" ])
#--> FALSE

? AreEqualCS([ "ring", "Ring", "RING" ], FALSE)
#--> TRUE

pf()

/*===

pr()

? BothEndWithANumber( "v1" , "v3" )
#--> TRUE

pf()

/*======== #perf Desabling param checking to enhance performance
#TODO // Generalize this feature to all Softanza functions

# Softanza functions do a lot of work in checking params correctness.
# You can see it by yourself by reading any function code.
# But this comes with a performance cost, especially when you use
# theses functions in loops dealing with large lists.

# For example, the function EuclideanDistance() cheks by default for
# the params to be both lists of numbers of same size:

//? EuclideanDistance(1:3, 1:5)
#!--> Incorrect lists sizes! anNumbers1 and anNumbers2 must both have the same size.

# It does not allow you to use incorrect types:
//? EuclideanDistance('A':'C', 1:3)
#!--> Incorrect param types! anNumbers1 and anNumbers2 must be both lists of numbers.

# And so on.

# Now, if we use the function for a large number of items:

aList1 = 1 : 1_500_000
aList2 = 4 : 1_500_003

pr()

? EuclideanDistance(aList1, aList2)
#--> 3674.23

# A lot.

pf()
# Executed in 19.32 second(s) in Ring 1.22
# Executed take 25.54 seconds in Ring 1.19


/*--- Continue

pr()

# What if we disable the params cheks and see what gain we could obtain:

CheckParamOff()
_bParamCheck = false

aList1 = 1 : 1_500_000
aList2 = 4 : 1_500_003

? EuclideanDistance(aList1, aList2)
#--> 3674.23

# A lot faster!

pf()
# Executed in 0.89 second(s) in Ring 1.22
# Executed in 2.05 second(s) in Ring 1.22

/*============

pr()

for i = 1 to 10_000
	cCode = "str = ''+ i + ' '"
	eval(cCode)
next
# Executed in 8.25 second(s)

pf()

/*----------

pr()

for i = 1 to 1_000
	cCode = "str = ''+ i + ' '"
	eval(cCode)
next
# Executed in 0.88 second(s)

pf()

/*=========== #perf #narration

pr()

# The Ring for loop is quick! Hence it loops 5 million
#  times in a fraction of second:

for i = 1 to 5_000_000
	// Do nothing
next

pf()
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19
# Executed in 0.44 second(s) in Ring 1.17

/*-----

pr()
# Contrariwise, this Ring for/in loop takes too long to complete!
# (500 thousand times and not 5 million like in the example above!)

for n in 1:500_000
	// Do nothing
next

# In Notepad 1.19+, click on the pause button on the right of the Input control
# at the bottom of the Output window to stop the execution;

pf()

/*---- #perf

pr()

# The ForEach alternative, by Softanza, solves the For/in
# weakness and performs the same loop in a second!

@ForEach( :number, :in = 1 : 500_000 ) {
	// Do nothing
}

pf()
# Executed in 1.25 second(s) in Ring 1.21
# Executed in 2.04 second(s) in Ring 1.18

# But ForEach offers more flexibility...

/*----------

pr()

@ForEach( :number, :in = 1:5 ) {

	# The code you want to execute in the loop

	X('
		? v(:number)
	')

}

pf()
# Executed in 0.04 second(s)

/*----------

pr()

@ForEach( [ :name, :age ], :in = [ [ "Teebah", 12], ["Haneen", 8], ["Hussein", 2] ] ) {

	X([ [1, 3], '
		? v(:name) + TAB + v(:age)
	'])
	#--> teebah	12
	#    haneen	8
	#    hussein	2

	? ""
	Xn( 3, '
		? v(:name) + TAB + v(:age)
	')
	#--> Hussein	2

	? ""
	Xn( [1, 3], '
		? v(:name) + TAB + v(:age)
	')
	#--> Teebah	12
	#    Hussein	2

}

pf()
# Executed in 0.05 second(s)

/*----------

pr()

@ForEach( :number, :in = 1:5 ) { X('

	? v(:number)

') }

#--> 1
#    2
#    3
#    4
#    5

pf()
# Executed in 0.04 second(s)

/*----------

pr()

@ForEach( [ :name, :age ], :in = [ [ "teebah", 12], ["haneen", 8], ["hussein", 2] ] ) { X('

	? v(:name) + TAB + v(:age)

') }
#--> teebah	12
#    haneen	8
#    hussein	2

pf()
# Executed in 0.05 second(s) in Ring 1.20

/*----------

pr()

aNumbers = []

@ForEach( :number, :in = 1:100 ) { X('
	aNumbers + v(number)
')}

? ShowShort(aNumbers)
#--> [ 1, 2, 3, "...", 98, 99, 100 ]

pf()
# Executed in 0.30 second(s)

/*-----------

pr()

@ForEach( :name, :in = [ "teeba", "haneen", "hussein" ]) { X('

	? upper( v(:name) )

')}
#--> TEEBA
#--> HANEEN
#--> HUSSEIN

pf()
# Executed in 0.04 second(s)

/*-----------

pr()

@ForEach( [ :Name, :Age ], :In = [ :Heni = 25, :Omar = 32, :Sonia = 14 ] ) { X('
	? name + " " + age
')}
#--> heni 25
#    omar 32
#    sonia 14

pf()
# Executed in 0.04 second(s)

/*============

pr()

? @@([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])
#--> [
#	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*", "*3",
#	"*34", "3", "34", "4"
# ]

pf()
# Executed in 0.05 second(s)

/*-----------

pr()

? @@("n")	#--> "n"
? @@('n')	#--> "n"
? @@("'n'")	#--> "'n'"
? @@('"n"')	#--> '"n"'

pf()
#--> Executed in 0.02 second(s)

/*---------------- Showing the short form of a long list

pr()

? @@( "A" : "Z" ) + NL
#--> [
#	"A", "B", "C", "D",
#	"E", "F", "G", "H",
#	"I", "J", "K", "L",
#	"M", "N", "O", "P",
#	"Q", "R", "S", "T",
#	"U", "V", "W", "X",
#	"Y", "Z"
# ]

# Showing a part of a long list

? @@S( "A" : "Z" ) + NL
#--> [ "A", "B", "C", "...", "X", "Y", "Z" ]

? @@S(1:100_000) + NL
#--> [ 1, 2, 3, "...", 99998, 99999, 100000 ]

# Showing the 2 first items and 2 last items of a long list

? @@SXT(1:50, 2) + NL
#--> [ 1, 2, "...", 49, 50 ]

# Showing the 2 first items and the 3 last items of a long list

? @@SXT(1:50, [2, 3]) + NL
#--> [ 1, 2, "...", 48, 49, 50 ]

pf()
#--> Executed in 0.01 second(s) in Ring 1.21
#--> Executed in 0.10 second(s) in Rin 1.20

/*----------

? Q(1:10).ShowShort()
#--> [ 1, 2, 3, "...", 8, 9, 10 ]

? Q(1:10).ShowShortN(3)

? Q(1:10).ShowShortXT([2, 3])
#--> [ 1, 2, "...", 8, 9, 10 ]

pf()

/*================

pr()

o1 = new stzListOfStrings([ "[ 4, 7 ]", "[ 1, 3 ]", "[ 8, 9 ]" ])
? o1.Sorted()

pf()
#--> Executed in 0.03 second(s)

/*-------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [1,3], [4, 7], [8, 9] ]

pf()
# Executed in 0.07 second(s)

/*------------

pr()

? @@(  Association([ [4, 14, 9], [6, 16] ]) )
#--> [ [ 4, 6 ], [ 14, 16 ], [ 9, "" ] ]

pf()
# Executed in 0.04 second(s)

/*------------

pr()

o1 = new stzString("...emm...eh..emm...eh")

? @@( o1.FindMany([ "emm", "eh" ]) )
#--> [4, 10, 14, 20 ]

? @@(o1.FindManyAsSections([ "emm", "eh" ]))
#--> [ [ 4, 6 ], [ 10, 11 ], [ 14, 16 ], [ 20, 21 ] ]

# Many is used here for clarity, and you can avoid it,
# and let Softanza understand that the provided param
# is a list of strings. Hance, Find() calls FindMany()
# in the bkackground:

? @@( o1.Find([ "emm", "eh" ]) )
#--> [4, 10, 14, 20 ]

? @@(o1.FindAsSections([ "emm", "eh" ])) # Of FindZZ() for short
#--> [ [ 4, 6 ], [ 10, 11 ], [ 14, 16 ], [ 20, 21 ] ]

pf()
# Executed in 0.07 second(s)

/*------------

pr()

o1 = new stzString("...|---|....|--|..--")

? @@( o1.Find("--") )
#--> [ 5, 6, 14, 19 ]

? @@( o1.FindAsSections("--") )
#--> [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.FindAsSection("--") ) # Section without "s"! --> same as FindFirstAsSection()
#--> [ 5, 6 ]

# You can use the ..Z() and ..ZZ() extensions:

? @@( o1.FindZ("--") )
#--> [ 5, 6, 14, 19 ]

? @@( o1.FindZZ("--") )
#--> [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.FindAsSections([ "---", "--" ]) ) + NL
#--> [ [ 5, 6 ], [ 5, 7 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.BoundedBy("|") )
#--> [ "---", "....", "--" ]

? @@( o1.FindSubStringsBoundedByZZ("|") )# Idem
#--> [ [ 5, 7 ], [ 9, 12 ], [ 14, 15 ] ]

pf()
# Executed in 0.10 second(s)

/*------------ #todo write a #narration

pr()

o1 = new stzString("...|---|....|--|..--")

? @@( o1.FindAsSections([ "---", "....", "--" ]) ) + NL
#--> [ [ 5, 6 ], [ 5, 7 ], [ 6, 7 ], [ 9, 12 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.Sections( o1.FindAsSections([ "---", "....", "--" ]) ) ) + NL

#--> [ "--", "---", "--", "....", "--", "--" ]

? @@NL( o1.TheseSubStringsZZ([ "---", "....", "--" ]) )
#--> [
#	[ "---", [ [ 5, 7 ] ] ],
#	[ "....", [ [ 9, 12 ] ] ],
#	[ "--", [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ] ]
# ]

pf()
# Executed in 0.08 second(s)

/*------------

pr()

o1 = new stzString('   str = "  ...  "     and   str !=    "  *** " ')

? @@NL( o1.BoundedBy('"') ) + NL
#--> [
#	"  ...  ",
#	"     and   str !=    ",
#	"  *** "
# ]


? @@( o1.FindAsSections( o1.BoundedBy('"') ) )
#--> [ [ 11, 17 ], [ 19, 39 ], [ 41, 46 ] ]

pf()
# Executed in 0.07 second(s)

/*------------

pr()

? @@('   str = "  ...  "     and   str !=    "  *** " ')
#--> 'str = "  ...  " and str != "  *** "'

pf()
# Executed in 0.02 second(s)

/*----------- #TODO/FUTURE

pr()

o1 = new stzString("SOanzNZA")
o1.ReplaceSection(3, 5, :With@ = 'Q(@char).Uppercased()')
? o1.Content()
#--> SOANZNZA

pf()
# Executed in 1.09

/*===================

StartProfiler()

# The following is an exploration of the comprative performance
# of for loops and for/in loops.

# If we iterate over a list of 200 thousand numbers using for/in,
# and without doing anything inside the loop:

	StartTimer()
	
	aList = 1 : 200_000
	for n in aList
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.07 second(s)

# Let's compare it with a for loop:

	StartTimer()
	
	aList = 1 : 200_000

	for i = 1 to len(aList)
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.04 second(s)

# It's done in say X2 better performance!

# Now, what if we omit the call of the function len() from the loop declaration
# and put in a variable, like this:

	StartTimer()
	
	aList = 1 : 200_000
	nLen = len(aList)
	for i = 1 to nLen
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.03 second(s)

# The X2 factor is maintained in favor of the normal for looo!

# But wait, in the for/in snippet above, we used the variable aList = 1 : 200_000
# and then called it in the loop declaration like this : for n in aList, right?

# So, what if we omit that and use the data 1:200_000 directly like this:

//	StartTimer()
	
//	for n in 1 : 200_000
		// do nothing
//	next
	
//	? ElapsedTime()

# Wow! It's sooo slow!! I aborted the process after more then 10 minutes...

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
	#--> 0.06 second(s)

# For loop made it so quickly in 0.06 seconds! What about for/in loops?

	StartTimer()

	aList = 1 : 200_000
	nSum = 0

	for n in aList 
		nSum += n
	next

	? ElapsedTime()
	#--> 0.09 second(s)

# It's about 0.9 seconds, 30% slower then for loops.

# Now, what if we challenge for/in loop with what it is normally made for:
# the possibility of changing the items values while looping over them...

# To do so, we want to update the item n by the value (n + 2 * n):

	StartTimer()

	aList = 1 : 200_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()
	#--> 0.11 second(s)

# Done in 0.11 seconds (less then a second), which is nice!
# Will for loop win the battle as usual? Let's see...

	StartTimer()

	aList = 1 : 200_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()
	#--> 0.09 second(s)

# Oh! For loop made it in 0.09 seconds, 30% faster!

# Let's try it for a list as large as 1 million items, first with for/in:

	StartTimer()

	aList = 1 : 1_000_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()
	#--> 0.52 second(s)

# And then with a normal for loop:

	StartTimer()

	aList = 1 : 1_000_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()
	#--> 0.47 second(s)

# The difference is not huge, but still for is more performant then for/in!

# Then, this is the second thing we should learn, when performance is
# a critical requirement to your algorithm:

# ALWAYS USE THE FOR LOOP INSTEAD OF THE FOR/IN LOOP

StopProfiler()
# Executed in 0.47 second(s).

/*===================

? Stz(:Number, :Class)
#--> "stznumber"
# You can also say: ? StzNumberClass()

? @@(Stz(:Number, :Attributes))
#--> [ "@oobject", "@cVarName", "@cnumber" ]
# You can also say: ? StzNumberAttributes()

? Stz(:Number, :Methods)
#--> [ "init", "content", "initialcontent", "copy", ... ]
# You can also say: ? StzNumberMethods()

/*=========

? Q("A").RepeatedNTimes(3) # Or Repeated(3)
#--> "AAA"

? @@( Q([1,2]).RepeatedNTimes(3) ) # Or Repeated(3)
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
? Stz(:String, :Attributes) 	#--> [ :@oObject, :@cVarName, :@oQChar ]

# You can even make a filter on the list of methods to return only those
# that verify a given condition:

? Stz(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
#--> [ :isLeftToRight, :IsRightToLeft, ... ]

/*=============

? Q("(,,)").Check(:That = 'StzCharQ(@Char).IsPunctuation()')
#--> TRUE

/*============ INFERRING TYPES: Q() & QQ()
#NOTE: Unlike Ring, Softanza return type in lowercase.

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

	? @@( Types() )
	#--> [ "string", "number", "string", "number" ]
}

/*------------

Q([ "A", 20, [ "B" ], 30 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "list", "number" ]
}

/*------------

Q([ "A", 20, [ "B", 10 ], 30 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "list", "number" ]
}

/*==============

? Q(:ListsOfObjects).InfereType() #--> :List

/*--------------

pr()

? Q([ 1, 2, 3 ]).IsListOf(:Numbers)		#--> TRUE

? Q([ "A", "B", "C" ]).IsListOf(:Strings)	#--> TRUE

o1 = new stzNumber(10)

? Q([ o1, o1, o1 ]).IsListOf(:StzNumbers)	#--> TRUE

o1 = new stzString("A")
? Q([ o1, o1, o1 ]).IsListOf(:StzStrings)	#--> TRUE

? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:ListsOfNumbers)	#--> TRUE
? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:PairsOfNumbers)	#--> TRUE

pf()
#--> Executed in 0.09 second(s).

/*-------------------
*/
pr()

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

pf()
# Executed in 0.03 second(s).

/*=================

pr()

? ComputableForm(4) # or use the abbreviated form @@(4)
#--> 4

? ComputableForm("Ring")
#--> "Ring"

? ComputableForm([ 1, 2, "a" ])
#--> [
#	1,
#	2,
#	"a"
#]

? ComputableForm([ 1, 2, "a" ]) # or use the abbreviated form @@(...)
#--> [ 1, 2, "a" ]

pf()
# Executed in almost 0 second(s).

/*================ #narration: chars looking similar but are different!

# Look at theses statements and guess their results:

StartProfiler()
	
	? "۰" = "٠"	#--> FALSE
	? "۱" = "١"	#--> FALSE
	? "۲" = "٢"	#--> FALSE
	? "۳" = "٣"	#--> FALSE
	? "۸" = "٨"	#--> FALSE		
	? "۹" = "٩"	#--> FALSE

	? Unicode("۱")	#--> 1777
	? Unicode("١")	#--> 1633

	# Surprised?
	
	# The point is that Unicode assigns unique codes to Chars and
	# not to their visual glyfs. To give a clear example:
	
	# "O", "Ο", and "О" appear the same for us, and for the particular
	# font we use in our system to render them, but from a unicode
	# standpoint, they are different.

	? AreEqual([ "O", "Ο", "О" ]) 	#--> FALSE

	# In fact, they are different in uncicodes code points, scripts they
	# represent, and unicode names they have:

	? Unicodes([ "O", "Ο", "О" ]) 	#--> [ 79, 927, 1054 ]
	? Scripts([ "O", "Ο", "О" ]) 	#--> [ :Latin, :Greek, :Cyrillic ]
	? CharsNames([ "O", "Ο", "О" ])
	#--> [
	# 	"LATIN CAPITAL LETTER O",
	# 	"GREEK CAPITAL LETTER OMICRON",
	# 	"CYRILLIC CAPITAL LETTER O"
	# ]

StopProfiler()
# Executed in 0.14 second(s) on Ring 1.21
# Executed in 0.18 second(s) on Ring 1.20

