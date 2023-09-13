load "stzlib.ring"

/*----------

pron()

o1 = new stzList([ 2, 4, 8 ])
? o1.EachItemIsA(:Number)
#--> TRUE
? o1.EachItemIsA([ :Positive, :Even, :Number ]) # ItemsAreEither, AllItemsAreEither...
#--> TRUE

proff()

/*----------
*/
pron()

o1 = new stzList([ 6, -2, 9, 5, -10 ])
? o1.EachItemIsEitherA(:Positive, :Or = :Negative, :Number )
#--> TRUE

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA( :Number, :Or, :String )
#--> TRUE

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, [ :Lowercase, :Latin, :String ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, :String )

? o1.EachItemIsEitherA( :Number, :Or, [ :Lowercase, :Latin, :String ])

/*
o1 = new stzList([ 120, "1250", 54, "452" ])
? o1.EachItemIsEither( :Number, :Or = :NumberInString )

o1 = new stzList([ 2, 4, 8, "-129", 10, "-100.45" ])
? o1.EachItemIsEither([ :Positive, :Even, :Number ], :Or = [ :Negative, :NumberInString ] )
*/

proff()

/*===== ObjectName() and ClassName()

pron()

o1 = new stzString(:nation = "Niger")

? ClassName(o1)
#--> stzstring

? ObjectIsNamed(o1)
#--> TRUE

? ObjectName(o1)
#--> nation

#----

o1 = new stzString("Niger")

? ObjectIsNamed(o1)
#--> FALSE

? ObjectName(o1)
#--> @noname

# TODO: Reflect...
# Does any normal object (not necessarilty a stzObject) containing an
# @cVarName attribute and an ObjectVarName() method should be
# considered as potentially named ?

# In fact, the actual implementation ignores those objects completely
# and assign a @noname to them --> they are considered UnnamedObject!

proff()

/*------------

pron()

o1 = new stzString(:nation = "Niger")
? o1.VarName()
#--> nation

o1.RenameIt(:country)
? o1.VarName()
#--> country

proff()

/*------------
*/
pron()

# By default, a softanza object is created with no name
# (actually, with a name called :@noname)

greeting = new stzString("Hi!")
? greeting.VarName()
#--> @noname

# You can name the object afterward, like this:
greeting.SetVarName(:greeting)
# and than you can read the name:
? greeting.VarName()
#--> greeting

# Or you can create the named object in the same time as the object
# it self, by providing a hashlist like this:

hello = new stzString(:hello = "Hello Ring!")
# and than you can read the name:
? hello.VarName() + NL
#--> hello

# A third way, is to use Vr() and Vl() small functions, like this:
# ...

# In all cases, we have now objects that we can refer to by their static
# names we gave them in our code. And so, we can find them inside a list!

o1 = new stzList([ "one", greeting, 12, greeting, Q("two"), hello, 10 , Q(10) ])

? @@( o1.FindObjects() )
#--> [ 2, 4, 5, 6, 8 ]

? @@( o1.ObjectsZ() ) + NL # Or ObjectsAndTheirPositions()
#--> [
#	[ "greeting", [ 2, 4 ] ],
#	[ "@noname",  [ 5, 8 ] ],
#	[ "hello",    [ 6 ]    ]
# ]

? @@( o1.FindObject(greeting) )
#--> [ 2, 4 ]

? @@( o1.FindObject(hello) )
#--> [ 6 ]

? @@( o1.FindNamedObjects() )
#--> [ 2, 4, 6 ]

? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]

? @@( o1.FindTheseObjects([ greeting, hello ]) )
#--> [ 2, 4, 6 ]

? @@( o1.FindTheseObjects([ :@noname, hello ]) ) + NL
#--> [ 5, 6, 8 ]

? @@( o1.TheseObjectsZ([ :@noname, hello ]) )

/*
#--

o1.FindStzObjects()

#--

o1.FindQObjects()

#--

o1.FindUnnamedObjects()

#--

o1.FindNonStzObjects()

#--

o1.FindNamedObjects()

#--

o1.ObjectsVarNames()

o1.NamedObjects() # Or OnlyNamedObjects()
? o1.UnnamedObjects()

*/
proff()

/*=========== TODO
*/
pron()
# Exploring the possibility of using named vars to make it
# possible finding objects by name inside a list!

//VrVl( [ :my_name = Q("Mansour"), :my_age = "67" ] )


Vr([ :my_name, :my_age ]) '<~' Vl([ Q("Mansour"), Q(67) ])
? v(:my_name).VarName()

proff()

/*------------

pron()

Vr( "a" : "z" ) '<~' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20

proff()

/*======= Multiple eqality check

pron()

? Q(3+3) = Q(2+4) = Q(9-3) = 6
#--> TRUE

? Q("r"+"ing") = Q("ri"+"ng") = Q("rin"+"g") = "ring"
#--> TRUE

? Q(["♥", "♥"]+"♥") = Q(["♥"]+"♥"+"♥") = ["♥","♥", "♥"]
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*-------

pron()

# Multiple equality checks are possible in many languages
# such as Python, Javascript, Java, C, to name a few.
# In all cases it takes the form :
'
value1 == value2 == value3
'

# Now, this is possible also in Ring:

? Q(3+3) = Q(2+4) = Q(9-3) = 6
#--> TRUE

# In the background, Softanza enables this by overloading
# the "=" operator on a pipe of softanza objects. In the
# current case, they are stzNumber objects:

? Q(3+3).IsEqualToQ(2+4).IsEqualToQ(9-3).IsEqualTo(6)
#--> TRUE

# Let's experiment with the FALSE output:

? Q(3+3) = Q(2+444) = Q(9-3) = 6
#--> FALSE

# Internally, the implementation of the FALSE case
# required the use of a special stzFalseObject.

# While it is not necessary to undersdant it inorder
# to use the syntax shown in this sample, one would gain
# more clarity when it does...

# TODO: Explain the use of stzFalseObject to enable
# managing the FALSE case in multiple eqality check.

proff()

/*======

pron()

? @@( Q("::2").splitat(":") )
#--> [ NULL, NULL, "2" ]

proff()

/*==== Using a Python code inside Ring ===


pron()

# Reversing a list, the Python way

? Q(1:5)['::-1']
#--> [ 5, 4, 3, 2, 1 ]

# Getting a part of the list (from 2 to 8) with a step of 2

? Q(1:10)['2:8:2']
#--> [ 2, 4, 6, 8 ]

proff()

/*------------

pron()

'
range(1, 5)[::-1]
#--> [ 4, 3, 2, 1 ]
'

# Reversing a list, the Python-way:

? range1Q([ 1, 5 ])['::-1']
#--> [ 4, 3, 2, 1 ]

proff()

/*============
*/
# NOTE: examples borrowed from this article:
# https://note.nkmk.me/en/python-range-usage

pron()

# range(n) : 0 <= x < n	--> n not included!

	? range0(3)
	#--> [ 0, 1, 2 ]

	? @@( range0(-3) ) + NL
	#--> []

# range(n1, n2): n1 <= x < n2

	? range0([ 3, 10 ])
	#--> [ 3, 4, 5, 6, 7, 8, 9 ]
	
	? @@( range0([ 10, 3 ]) ) + NL
	#--> []
	
	? range0([ -3, 3 ])
	#--> [-3, -2, -1, 0, 1, 2]
	
	? @@( range0([ 3, -3 ]) )
	#--> []
	
	? range0Q([0, 3]) = range0(3)
	#--> TRUE

# range(n1, n2, step): n1 <= x < n2 (increasing by step)

	? range0([ 3, 10, 2 ])
	#--> [ 3, 5, 7, 9 ]

	? @@( range0([ 10, 3, 2 ]) ) + NL
	#--> []

	? range0([ 10, 3, -2 ])
	#--> [ 10, 8, 6, 4 ]

	? @@( range0([ 3, 10, -2 ]) )
	#--> []

# range(start, stop, 1) is equivalent to range(start, stop)

	? range0Q([ 3, 10, 1 ]) = range0([ 3, 10 ])
	#--> TRUE

# range(0, stop, 1) is equivalent to range(0, stop) and range(stop)

	? range0Q([ 0, 10, 1 ]) = range0Q([ 0, 10 ]) = range0(10)

proff()

/*--------------

pron()

# Used to suppoprt external code from 0-based languages

? range0(3)
#--> [0, 1, 2]

? range0([ 1, 3 ]) 
#--> [1, 2]

? range0([ 2, 8, 3 ])
#--> [2, 5]

# Used in Ring 1-based lists

? range1(3)
#--> [1, 2, 3]

? range1([ 1, 3 ]) 
#--> [1, 2, 3]

? range1([ 2, 8, 3 ])
#--> [2, 5, 8]

# Special accessor (python-like), used here to reverse the list

? range1(':5:-1')
#--> [ 5, 4, 3, 2, 1 ]

? range0(':5:-1')
#--> [ 4, 3, 2, 1, 0 ]

proff()


/*--------------

pron()

# In python, we get the integer part of the division using the // operator

'345 // 100'
#--> 3

# In Ring, we can simulate this Python syntax by saying:

? Q(345)['// 100']
#--> 3

proff()

/*---------------

pron()

# In Python, this code concatenates a list of items into a string using a given separator:

# ' + '.join([ "a", "b", "c" ])
#--> a + b + c

# In Ring, with Softanza, we can use the same code like this:

? Q(' + ').join([ "a", "b", "c" ])
#--> a + b + c

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

? range(3)
#--> [ 0, 1, 2 ]

? range1(3)
#--> [ 1, 2, 3 ]

? range([ -3, 4, 2 ])
#--> [ -3, -1, 1, 3 ]

? range1([ -3, 4, 2 ])
#--> [ -3, -1, 1, 3 ]

proff()

/*--------------

# This Python code calculates the euclidean distance between
# two lists of numbers located in a and b:

'
def dist(a,b):
    s = 0.0
    n = len(a)
    for i in range(n):
        dist = a[i] - b[i]
        s += dist*dist
    return sqrt(s)

a = [ 1, 2, 3, 4, 5 ]
b = [ 4, 5, 6, 7, 8 ]

print(euc_dist(a,b))
#--> 6.71
'

# In Ring, with Softanza, we can reuse nearly the same code,
# like this :

pron()

	a = 1:5
	b = 4:8
	
	? euc_dist(a,b)
	#--> 6.71

proff()
# Executed in 0.03 second(s)

def euc_dist(a,b)':' # we put the : char between two ''
	s = 0.0
	n = len(a)

	for i in range1(n)':'
	# We use range1() to make it start from 1
	# We can also leave range() and add i++

		dist = a[i] - b[i]
		s += dist * dist
	next

	return sqrt(s)

/*--------------

# We asked Bard AI about a python code that performs the
# Google Diff Algortithm (comparing two strings and
# showing their differences)...

# Here is the code proposed by Bard:
'
	def diff(old_string, new_string):
	  """Returns a list of diffs between two strings."""
	  diffs = []
	  i = 0
	  j = 0
	  while i < len(old_string) and j < len(new_string):
	    if old_string[i] == new_string[j]:
	      diffs.append("=")
	      i += 1
	      j += 1
	    elif old_string[i] < new_string[j]:
	      diffs.append("<")
	      i += 1
	    else:
	      diffs.append(">")
	      j += 1
	  return diffs

	def main():
	  old_string = "This is the old string."
	  new_string = "This is the new string."
	  diffs = diff(old_string, new_string)
	  print(diffs)

'
# When executed in Python, the code output is:
#--> [
# 	'=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=',
#	'>', '>',
#	'<', '<', '<', '<', '<', '<', '<', '<', '<', '<'
# ]

# Using Softanza External Code facility, we can run quiet the same Python code in Ring:

pron()

def main()':' 
	old_string = "This is the old string."
	new_string = "This is the new string."

	diffs = diff(old_string, new_string)
	print( @@(diffs) )

	#--> [
	#	"=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=",
	#	">", ">", ">", ">", ">", ">", ">", ">", ">", ">"
	# ]
	#--> TODO: Check the difference in output between Python and Ring+Softanza
	#--> See the difference in meaning attributed by each language to
	#    string cmparaison operators =, < and >

proff()
#Executed in 0.08 second(s)

def diff(old_string, new_string)':' # Here we put : between quotes
	"""Returns a list of diffs between two strings."""

	diffs = []
	i = 1 # Here we changed 0 by 1
	j = 1 # Idem

  	while i < len(old_string) and j < len(new_string)':' # Idem

    		if old_string[i] = new_string[j]
      			diffs = Q(diffs).appendedWith("=") # Here we changed the semantics
     			i += 1
     			j += 1
 
    		but Q(old_string[i]) < new_string[j] # Here we used Q()
      			diffs = Q(diffs).appendedWith("<") # Idem
      			i += 1

   		else':' # Idem
     			diffs = Q(diffs).appendedWith(">") # Idem
     			 j += 1
		ok
	end

 	return diffs

/*-----------

# range() is used for Pyhton-code compatibility

pron()

	? range(3)
	#--> [ 0, 1, 2 ]
	
	? range([-3, 3+1, 2])
	#--> [ -3, -1, 1, 3 ]
	
proff()
# Executed in 0.03 second(s)

/*------------

pron()

# f-strings are a feature in Python for interpolating string
# content, by dynmalically evaluation variables inside it:

	'
	bestlang = "Python"
	print(f"My best language is {bestlang}!")
	#--> My best language is Python!
	'

# the same syntax can be used in Ring with Softanza like this:

	bestlang = "Ring"
	print( f("My best language is {bestlang}!") )
	#--> My best language is Ring!

proff()
# Executed in 0.08 second(s)

/*================

pron()

# In Softanza, you can define many variables and affect
# values to them in one line like this:

V([ :x = 10, :y = 20, :z = 30 ])

# The same thing can be done like this:

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])

# Then, you can get the values by calling the variables
# using their names like this:

? v(:x) #--> 10
? v(:y)	#--> 20
? v(:z) #--> 30

? ""

# Or you can compose them in a list and print them like this:

? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

? v([ :x, :z ])
#--> [ 10, 30 ]

? v([ :x, :x, :z, :y ])
#--> [ 10, 10, 30, 20 ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

# In Python, we can assign multiple values to many variables:
'
	x, y, z = 10, 20, 30

	print(x)
	print(y)
	print(z)
'

# In Ring, with Softanza, we can say it this way:

	Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])

# And then you can call their values like this:

	print( v(:x) )	#--> 10
	print( v(:y) )	#--> 20
	print( v(:z) )	#--> 30

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ])

? @@( v(:name3) )
#--> NULL

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v(:name)
#--> ERR: ndefined named variable!

proff()

/*--------------

pron()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v([ :name1, :name2, :name7 ])
#--> ERR: ndefined named variable!

proff()

/*--------------

pron()

Vr([ :name, :grades, :age ]) '=' Vl([ "Mansour", [10, 12, 15], 47 ])
? @@( v(:grades) )
#--> [ 10, 12, 15 ]

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

Vr([ :names ]) '=' Vl([ [ "Hussein", "Haneen", "Teebah" ] ])
? @@( v(:names) )
#--> [ "Hussein", "Haneen", "Teebah" ]

proff()

/*--------------

pron()

? @@( tempval() )
#--> NULL
? @@( oldval() )
#--> NULL

vr([ :name ]) '=' vl([ "mansour" ])

? v(:name)
#--> mansour

	? @@( tempval() )
	#--> mansour
	? @@( oldval() )
	#--> mansour
	
setV(:name = "cherihen")
? v(:name)
#--> cherihen

	? @@( tempval() )
	#--> cherihen
	? @@( oldval() )
	#--> "mansour"

? @@( tempvarname() ) # same as tempvar()
#--> name

proff()

/*============ TERNARY OPERATOR

pron()

# In Python we can use ternary operator like this:
	'
	something = true // or false
	value = "foo" if something else "bar"
	'

# As you might imagine, its equivalent in pure Ring is:
	something = true // or false
	
	if something = true
		value = "foo"
	else
		value = "bar"
	ok

# But what if we write it, the Pyhton-way, in Ring, using Softanza?

# To to that, we just need to decorate the Python code with vr(), vl(),
# _if() and _else() functions:

bSomething = TRUE
vr([ :value ]) '=' vl([ "foo" ]) _if(bSomething) _else([ "bar" ])
? v(:value)
#--> foo

# And if we turn bSomething to FALSE:

bSomething = FALSE
vr([ :value ]) '=' vl([ "foo" ]) _if(bSomething) _else([ "bar" ])
? v(:value)
#--> bar

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

# Ternary operator in C-style languages (C, C#, Java, Javascript, PHP...)
# variable = (condition) ? value1 : value2;

'
	n = -12;
	sign = (n > 0) ? "postive" : "negative";
	printf(sign);
	#--> negative
'

# The same syntax in Ring (with Softanza)

	n = -12;
	vr(:sign) '=' b(n > 0) '?' bv("positive", "negative");
	printf( v(:sign) );
	#--> negative

proff()

/*============

pron()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

bPositive = FALSE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ -1, -2, -3 ]

proff()
# Executed in 0.12 second(s)

/*--------------

pron()

bPositive = FALSE
V([ :x = 10, :y = 20 ]) _if(bPositive) _else([ -10 ])

? v([:x, :y])
#--> [ -10, 20 ]

proff()

/*--------------

pron()

bPositive = FALSE
V([ :x = 10, :y = 20 ]) _if(bPositive) _else([ -10, -20 ])

? v([:x, :y])
#--> [ -10, -20 ]

proff()

/*--------------

pron()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.07 second(s)

/*===============

# I asked Bard (Google AI) about a code in Python that returns the
# uppercase strings from a given list of strings...

# Bard generated this code wich seems great!

'
	def uppercase_strings(list_of_strings):
		uppercase_strings = []
		
		for string in list_of_strings:
	    		if string.isupper():
	      			uppercase_positions.append(index)

	 	return uppercase_strings
	
	print( uppercase_strings([ "HELLO", "world", "this is", "RING!" ]) )
	#--> { "HELLO", "RING!" ]
	
'

# In Ring, I pasted the same code, organized it the Ring way (functions go at
# the end), and slightly change just one line of code. And then I run it, and
# it works!

	print( uppercase_strings([ "HELLO", "world", "this is", "RING!" ]) )
	#--> { "HELLO", "RING!" ]

	# Here is the function code

	def uppercase_strings(list_of_strings)
		uppercase_strings = []
	
		for str in list_of_strings

			if Q(str).isupper() # str is elevated to a stzString object using Q()
				uppercase_strings = Q(uppercase_strings).appendedWith(str)
				# This line was slightly tweakened, to keep things logical and expressive
			ok
		end
	
		return uppercase_strings

	# All the rest is keot unchanged.

/*==== Using a PHP code inside Ring  #===
	
# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
	echo(min(0, 150, 30, 20, -8, -200));  #--> -200
	echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

StartProfiler()

	echo( Min([0, 150, 30, 20, -8, -200]) );   #--> -200
	echo( Max([0, 150, 30, 20, -8, -200]) );   #--> 150

	# Note that the only difference is to put the numbers in a list
	# by bounding them by [ and ], inside the min() and max() functions

StopProfiler()
# Executed in 0.04 second(s)

/*==== Using a C# code inside Ring  #===

StartProfiler()

	# This is a C# code showing string interpolation:
	'
	int max = int.MaxValue;
	int min = int.MinValue;
	Console.WriteLine($"The range of integers is {min} to {max}");
	'

# And here is the same code translated to Ring:

	int max = int.MaxValue;
	int min = int.MinValue;
	Console.WriteLine( $("The range of integers is {min} to {max}") );
	#--> The range of integers is '-999_999_999_999_999' to '999_999_999_999_999'

	# Note that the only change made to the original C# code is to bound the string with ()
	
StopProfiler()
# Executed in 0.10 second(s)

/*==== USING a JS code inside Ring  #===

# The following JS code translate some string to
# uppercase in a locale sensitive way:
# (you can paste/test it here: https://bit.ly/3WdzMdF)
	"
	console.log('tunis'.toUpperCase());
	//--> TUNIS
	console.log('Iİıi'.toLocaleUpperCase('TR'));
	//--> IİIİ
	console.log('ß'.toLocaleUpperCase('de'));
	//--> SS
	"
# You can write nearly the same code, with almost the
# same JS-style, in Ring, using Softanza:
StartProfiler()

	console.log( Q('tunis').toUpperCase() );
	#--> TUNIS
	
	console.log( Q('Iİıi').toLocaleUpperCase('TR') );
	#--> IİII
	
	console.log( Q('ß').toLocaleUppercase('de') );
	#--> SS

	# Note hat the only difference is to elevate the string to
	# stzString objects using Q()

StopProfiler()
# Executed in 0.05 second(s)
