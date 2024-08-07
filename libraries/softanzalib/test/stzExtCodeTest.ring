load "../stzlib.ring"

/*----------

pron()

Q([ 1, 2, "three", 4, "five" ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> TRUE
}

Q([ 1, 2, 3, 4, 5 ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> FALSE

}

#--> Executed in 0.04 second(s)

proff()

/*------------

pron()

? sort([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]
], 2)

proff()
#--> Executed in 0.03 second(s)

/*------------

pron()

? StzListOfListsQ([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]
]).SortedBy(2)

proff()
#--> Executed in 0.04 second(s)

/*------------

pron()

? Min([2, 3])
#--> 2

? Max([2, 3])
#--> 3

proff()
#--> Executed in 0.07 second(s)

/*------------
*/
pron()

//CheckParamsOff()

o1 = new stzTable([

	:NAME =  [ "Bob", "Dan", "Roy" ],
	:SCORE = [ 89, 120, 100 ]

])

//o1.Shwo() + NL #NOTE this is a mispelled form of Show()

o1.SortInAscending(:SCORE)

? o1.Show()

#-->
# :NAME   :SCORE
# ------ -------
#   Bob      Roy
#    89      100

proff()
# Executed in 0.30 second(s)

/*==== SQL SUPPORT IN SOFTANZA EXTERNAL CODE
*/
pron()

# SQL code to create a table with three columns

'
	CREATE TABLE persons (
		id	SMALLINT,
		name	VARCHAR(30),
		score	SMALLINT,
	);
'

# The Softanza code for creating the same table inside a stzTable object

	@CREATE_TABLE( :persons ) {

		@([

		:id    = SMALLINT, 	#TODO: SQL datatypes are not supported yet
		:name  = VARCHAR(30),
		:score = SMALLINT

		])

	};

	# At this level, and in the background, Softanza creates a named stzTable
	# oject we can call using the small function v() and check its structure:

	v(:persons).Show() + NL
	#--> :ID    :NAME   :SCORE
	#     NULL   NULL    NULL

# SQL code to insert data into the table

'
	INSERT INTO persons ( id, name, score )

	VALUES 	( 1, "Bob",  89 );
		( 2, "Dan", 120 );
		( 3, "Tim",  56 );
'
# Ring code to insert data into the person stzTable object

	@INSERT_INTO( :persons, [ :id, :name, :score ] )

	@VALUES([
		[ 1, 'Bob',  89 ],
		[ 2, 'Dan', 120 ],
		[ 3, 'Tim',  56 ]
	]);

	# Let's check the stzTable object again

	? v(:persons).Show()
	#--> :ID  :NAME  :SCORE
	#      1    Bob      89
	#      2    Dan     120
	#      3    Tim      56

	# Let's add a more one row

	@VALUES([
		[ 4, 'Roy', 100 ],
		[ 5, 'Sam', 78 ]
	])

	? v(:persons).Show()
	#--> :ID  :NAME  :SCORE
	#      1    Bob      89
	#      2    Dan     120
	#      3    Tim      56
	#      4    Roy     100
	#      5    Sam      78

# SQL code to select data from the table in a query called sql

'
	WITH sql AS (

	SELECT name, score
	FROM persons
	WHERE score > 99

	)
'

# The same thing written in Ring code, where sql is a named variable
# containing the list of data returned by the query

	@WITH(:sql).AS([

	@SELECT([ :name, :score ]),
	@FROM( :persons ),
	@WHERE( 'score > 80' ) #TODO: check WHERE_( 'name = "Dan"' );

	])

	? v(:sql) # Or you can say ? v(:sqlData)
	#--> [
	# 	[ "Bob",  89 ],
	# 	[ "Dan", 120 ],
	# 	[ "Roy", 100 ]
	# ]

	# To get the stzTable object you can say:

	? v(:sqlTable).Show() # Or ? v(:sqlObject)
	#--> :NAME   :SCORE
	#    ------ -------
	#     Bob       89
	#     Dan      120
	#     Roy      100

# SQL code to sort the table by score

'
	WITH sql AS (

	SELECT * FROM persons
	ORDER BY Name DESC; # or ASC

	)
'

# In Ring with Softanza

	@WITH(:sql).AS([

	@SELECT('*'), @FROM(:persons),
	@ORDER_BY(:SCORE, :DESC)

	])

	? v(:sqlTable).Show()

proff()
# Executed in 2.07 second(s)

/*==============

pron()

for i = 1 to 3
	Vr([ :x, :y, :z ]) '=' Vl([ i, 2*i, 3*i ])
next


? @@( v([ :x, :y, :z ]) )
#--> [ 3, 6, 9 ]

? @@( VarVal([ :x, :y, :z ]) ) # Or VrVl()
#--> [ [ "x", 3 ], [ "y", 6 ], [ "z", 9 ] ]

proff()
# Executed in 0.11 second(s)

/*-------------

pron()

Vr([ :x, :y, :z ]) '=' Vl([ -1, 0, 1 ])
? v([ :x, :y, :z ])
#--> [ -1, 0, 1 ]

proff()
# Executed in 0.06 second(s)

/*-------------

pron()

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])
? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

# Dynamic construction of variable names

# Softanza makes it possible to contruct variable
# names in a dynamic way.

# This can be helful when you have a large number
# of variables that obey to the same naming pattern
# (example: name1, name2, name3, ..., name100) and you
# want to avoid their declaration in 100 lines of code!

# Or when the names of the variables depend on some data
# that you are going to have only in runtime (part of the
# variable name comes from the ID of the user, or from a
# hashed part of the file name uploaded, etc...).

# Or many other advanced cases related to realtime interactive
# apps, generative video game worlds, machine learning and AI,
# rules and inference engines, and genetic algorithms.

# For me, this feature is made to enable some advanced
# features in Near Natural Language programming.

# Let's show how this works with a simple example...

# Our objective is to declare 5 variables (name1, name2, ...,
# name10), along with their respective values 10, 20, ...100

# As you can see, there an interesting common pattern between
# our variables names and their values:
#	- the names end with a moving part: the numbers 1 to 10
#	- the values are all multiple of 10 by the numbers 1 to 10

# And so, we can dynamically use a loop on an index number i,
# from 1 to 10, and than construct both the names of the variables
# and their values, in one line, like this:

for i = 1 to 10 { Vr( 'name' + i ) '=' Vl( 10 * i ) } 

# We get the name of the variable name3
? v( :name3 )
#--> 30

# You can change the value of name3, like this:
Vr( :name3 ) '=' Vl( 44 )

# check it:
? v(:name3)
#--> 44

# Or you can change it like this:
VrVl( :name3 = 30 )

# We get the name of the variable and its name by
# adding the xt extension to the v() small function:

? @@( vxt( :name3 ) )
#--> [ "name3", 30 ]

# We get all the variables along with their values

for i = 1 to 10 { ? @@(vxt( 'name' + i )) }
#--> [ "name1", 10 ]
#    [ "name2", 20 ]
#    [ "name3", 30 ]
#    [ "name4", 40 ]
#    [ "name5", 50 ]
#    [ "name6", 60 ]
#    [ "name7", 70 ]
#    [ "name8", 80 ]
#    [ "name9", 90 ]
#    [ "name10", 100 ]

proff()
# Executed in 0.37 second(s)

/*========

pron()

# In PHP we use indirection to dynamically
# call the name of a variable, like this:
'
	$job = "programmer"
	$var = "job"

	echo($var) 
	#--> job
	echo($$var)
	#--> programmer
'
# In Ring, with SoftanzaLib, we write quite
# the same code:

	$(:job = "programmer")
	$(:var = "job")

	echo( $(:var) )
	#--> job
	echo( $$(:var) )
	#--> programmer

# And we can also say:

	Vr(:job) '=' Vl("programmer")
	Vr(:var) '=' Vl("job")

	echo( v(:var) )
	#--> job
	echo( vv(:var) )
	#--> programmer

# Or even say:

	Vr(:job) '=' Vl("programmer")
	Vr(:var) '=' Vl("job")

	echo( v(:var) )
	#--> job
	echo( v(v(:var)) )
	#--> programmer

proff()
# Executed in 0.11 second(s)

/*========

pron()

# In Raku (Perl) language we write:
"
	rand = 0.7;
	say rand < 0.5 ?? 'Yes' !! 'No';
	#--> No
"

# In Ring with Softanza we also write:

	rand = 0.7;
	say { b(rand < 0.5) '??' bt('Yes') '!!' bf('No') };
	#--> No

proff()

/*----------

pron()
	n = -12;
	vr(:sign) '=' b(n > 0) '?' bt("positive") '!!' bf("negative");
	printf( v(:sign) );
	#--> negative
proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzList([ 2, 4, 8 ])
? o1.EachItemIsA(:Number)
#--> TRUE
? o1.EachItemIsA([ :Positive, :Even, :Number ]) # ItemsAreEither, AllItemsAreEither...
#--> TRUE

proff()
# Executed in 0.09 second(s)

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

#TODO: Reflect...
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

	? @@( o1.NamedObjectsZ() )

? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]

	? @@( o1.UnnamedObjects() )

? @@( o1.FindTheseObjects([ greeting, hello ]) )
#--> [ 2, 4, 6 ]

? @@( o1.FindTheseObjects([ :@noname, hello ]) ) + NL
#--> [ 5, 6, 8 ]

? @@( o1.TheseObjectsZ([ :@noname, hello ]) )
#--> [
#	[ "@noname", [ 5, 8 ] ],
#	[ "hello", [ 6 ] ]
# ]

/*
#--

o1.FindStzObjects()

#--

o1.FindQObjects()

#--


#--

o1.FindNonStzObjects()

#--

o1.ObjectsVarNames()

o1.NamedObjects() # Or OnlyNamedObjects()
? o1.UnnamedObjects()


proff()

/*=========== TODO

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

#TODO: Explain the use of stzFalseObject to enable
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

#NOTE: examples borrowed from this article:
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
	vr(:sign) '=' b(n > 0) '?' bt("positive") ':' bf("negative");
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

	#NOTE that the only difference is to put the numbers in a list
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

	#NOTE that the only change made to the original C# code is to bound the string with ()
	
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

	#NOTE hat the only difference is to elevate the string to
	# stzString objects using Q()

StopProfiler()
# Executed in 0.05 second(s)
