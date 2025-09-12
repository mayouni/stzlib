load "../stzbase.ring"

/*---

pr()

? stzlen("softanza")
#--> 8

? stzleft("softanza", 4)
#--> soft

? stzright("softanza", 4)
#--> anza

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Ring's del(): modifies the list variable bur returns nothing

aList = [ "one", "two", "x", "three" ]
? @@( del(aList, 3) ) #--> NULL
? @@(aList) #--> [ "one", "two", "three" ]

# Softanza alternative: Modidies the list variable and returns it at the same time()
? ""
aList = [ "one", "two", "x", "three" ]
? @@( ring_del(aList, 3) ) #--> [ "one", "two", "three" ]
? @@(aList) #--> [ "one", "two", "three" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--

pr()

# Ring's default substr(): returns new string, str unchanged

str = "I love pizza"
? substr(str, "pizza", "couscous")
#--> I love pizza

? str
#--> I love pizza

# Softanza: updates and returns in one step

str = "I love pizza"
str = ring_substr2(str, "pizza", "couscous")
? str
#--> I love couscous

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- stzExtCode #todo quick-narration

pr()

# Softanza simplifies the use of substr() which has
# many forms in Ring and outside Ring (if you ar generating
# code from LLMs that are ususally influenced by pyhton and
# C syntax of substr()). You only need
# to add @ before substr() and let Softanza manage
# all the possible cases:

# Case 1 : Replacing a substring by an other

? @substr("one five three", "five", "two")
#--> one two three

# Case 2 : Finding the first occurrence of a substring
? @substr("one two three", "two", []) # [] can also be 0
#--> 5

# Case 3 : Getting a section from the string
? @substr("one two three", 6, 8)
#--> two

# Case 4 : Finding the first occurrence of a substring
# starting at a give position

? @substr("one two three two", "two", 10)
#--> 15

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*====

pr()

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

pf()

# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------ #ring #perf

pr()

? @@NL( sort([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]
], 2) )

pf()
#-->
'
[
	[ "Bob", 89 ],
	[ "Roy", 100 ],
	[ "Dan", 120 ]
]

'
# Executed in almost 0 second(s) in Ring 1.21
#--> Executed in 0.03 second(s) in Ring 1.20

/*------------

pr()

? @@NL( StzListOfListsQ([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]

]).SortedOnDown(2) )
#--> [
#	[ "Dan",      120 ],
#	[ "Roy",      100 ],
#	[ "Bob",       89 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------

pr()

? Min([2, 3])
#--> 2

? Max([2, 3])
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*------------

pr()

CheckParamsOff()

o1 = new stzTable([

	:NAME =  [ "Bob", "Dan", "Roy" ],
	:SCORE = [ 89, 120, 100 ]

])

? o1.Shwo() 	// #NOTE this is a mispelled form of Show()
#-->
'
╭──────┬───────╮
│ Name │ Score │
├──────┼───────┤
│ Bob  │    89 │
│ Dan  │   120 │
│ Roy  │   100 │
╰──────┴───────╯
'

o1.SortOnDown(:SCORE) # Or SortOnInDescending()

? o1.Show()
#-->
'
╭──────┬───────╮
│ Name │ Score │
├──────┼───────┤
│ Dan  │   120 │
│ Roy  │   100 │
│ Bob  │    89 │
╰──────┴───────╯
'

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.10 second(s) in Ring 1.21


/*==== #narration SQL SUPPORT IN SOFTANZA EXTERNAL CODE

pr()

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

		:id    = SMALLINT, 	// #TODO // SQL datatypes are not supported yet
		:name  = VARCHAR(30),
		:score = SMALLINT

		])

	};

	# At this level, and in the background, Softanza creates a named stzTable
	# oject we can call using the small function v() and check its structure:

	v(:persons).Show() + NL
	#-->
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│    │      │       │
	╰────┴──────┴───────╯
	'

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
	#-->
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│  1 │ Bob  │    89 │
	│  2 │ Dan  │   120 │
	│  3 │ Tim  │    56 │
	╰────┴──────┴───────╯
	'

	# Let's add more rows

	@VALUES([
		[ 4, 'Roy', 100 ],
		[ 5, 'Sam', 78 ]
	])

	? v(:persons).Show()
	#--> 
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│  1 │ Bob  │    89 │
	│  2 │ Dan  │   120 │
	│  3 │ Tim  │    56 │
	│  4 │ Roy  │   100 │
	│  5 │ Sam  │    78 │
	╰────┴──────┴───────╯
	'

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
	@WHERE( 'score > 80' ) // #TODO // check WHERE_( 'name = "Dan"' );

	])

	? v(:sql) # Or you can say ? v(:sqlData)
	#--> [
	# 	[ "Bob",  89 ],
	# 	[ "Dan", 120 ],
	# 	[ "Roy", 100 ]
	# ]

	# To get the stzTable object you can say:

	? v(:sqlTable).Show() # Or ? v(:sqlObject)
	#-->
	'
	╭──────┬───────╮
	│ Name │ Score │
	├──────┼───────┤
	│ Bob  │    89 │
	│ Dan  │   120 │
	│ Roy  │   100 │
	╰──────┴───────╯
	'

# SQL code to sort the table by score (on the column score of the stzTable object)

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
	#-->
	'
	╭──────┬───────╮
	│ Name │ Score │
	├──────┼───────┤
	│ Dan  │   120 │
	│ Roy  │   100 │
	│ Bob  │    89 │
	╰──────┴───────╯
	'

pf()
# Executed in 0.22 second(s) in Ring 1.23
# Executed in 0.32 second(s) in Ring 1.21
# Executed in 2.07 second(s) in Ring 1.20

/*==============

pr()

for i = 1 to 3
	Vr([ :x, :y, :z ]) '=' Vl([ i, 2*i, 3*i ])
next


? @@( v([ :x, :y, :z ]) )
#--> [ 3, 6, 9 ]

? @@( VarVal([ :x, :y, :z ]) ) # Or VrVl()
#--> [ [ "x", 3 ], [ "y", 6 ], [ "z", 9 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.20

/*-------------

pr()

Vr([ :x, :y, :z ]) '=' Vl([ -1, 0, 1 ])
? v([ :x, :y, :z ])
#--> [ -1, 0, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*-------------

pr()

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])
? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*----------- #narration DYNAMIC CONSTRUCTION OF VARIABLE NAMES


	pr()

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

	# For me, in particular, this feature is made to enable some
	# advanced features in Near Natural Language programming.

	# Let's show how this works with a simple example.

	# Our objective is to declare 10 variables (name1, name2, ...,
	# name10), along with their respective values 10, 20, ...100

	# As you can see, there is an interesting common pattern between
	# our variables names and their values:
	# 	- the names end with a dynamic part: the numbers 1 to 10
	# 	- the values are all multiple of 10 by the numbers 1 to 10

	# And so, we can dynamically use a loop with an index number i,
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
	? v(:name3)
	#--> 30

	# We get the name of the variable and its value by
	# adding the xt extension to the v() small function:

	? @@( vxt( :name3 ) )
	#--> [ "name3", 30 ]

	# We can get all the variables along with their values

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

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.37 second(s) in Ring 1.21

/*======== PHP

pr()
	
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
	# In Ring, with StzLib, we write quite
	# the same code:
	
		$(:job = "programmer")
		$(:var = "job")
	
		echo( $(:var) )
		#--> job
		echo( $$(:var) )
		#--> programmer
	
	# And we can also say (using named variables feature):
	
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

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.11 second(s) in Ring 1.21

/*========

pr()

# In Perl (Raku) language we write:
"
	rand = 0.7;
	say rand < 0.5 ?? 'Yes' !! 'No';
	#--> No
"

# In Ring with Softanza we also write:

	rand = 0.7;
	say { b(rand < 0.5) '??' bt('Yes') '!!' bf('No') };
	#--> No

	# b ~> boolean condition
	# bf ~> FALSE case
	# bt ~> TRUE case

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21

/*----------

pr()
	n = -12;
	vr(:sign) '=' b(n > 0) '?' bt("positive") '!!' bf("negative");
	printf( v(:sign) );
	#--> negative
pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*----------

pr()

o1 = new stzList([ 2, 4, 8 ])
? o1.EachItemIsA(:Number)
#--> TRUE
? o1.ItemsAre([ :Positive, :Even, :Numbers ])
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20

/*===== ObjectName() and ClassName()

pr()

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

#TODO // Reflect...
# Does any normal object (not necessarilty a stzObject) containing an
# @cVarName attribute and an ObjectVarName() method should be
# considered as potentially named ?

# In fact, the actual implementation ignores those objects completely
# and assign a @noname to them --> they are considered UnnamedObject!

pf()
# Executed in 0.01 second(s).

/*------------

pr()

o1 = new stzString(:nation = "Niger") # A named object
? o1.VarName()
#--> nation

o1.RenameIt(:country) # Or SetVarName()
? o1.VarName()
#--> country

pf()
# Executed in 0.01 second(s).

/*------------ #narration NAMING UNNAMED OBJECTS AND MAKING THEM FINDABLE

pr()

# By default, a softanza object is created with no name
# (actually, with a name called :@noname)

greeting = new stzString("Hi!")
? greeting.VarName()
#--> @noname

# You can name the object afterward, like this:
greeting.SetVarName(:greeting) # Or RenameIt()
# and than you can read the name:
? greeting.VarName()
#--> greeting

# Or you can create the named object in the same time as the object
# it self, by providing a hashlist like this:

hello = new stzString(:hello = "Hello Ring!")
# and than you can read the name:
? hello.VarName() + NL
#--> hello


# In both cases, we have now objects that we can refer to by their
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

? @@( o1.FindObject(:greeting) )
#--> [ 2, 4 ]

? @@( o1.FindObject(:hello) )
#--> [ 6 ]

? @@( o1.FindNamedObjects() )
#--> [ 2, 4, 6 ]

	# ? @@( o1.NamedObjectsZ() ) #TODO

? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]

	# //? @@( o1.UnnamedObjectsZ() ) #TODO

# ? @@( o1.FindTheseObjects([ :greeting, :hello ]) ) #TODO
#--> [ 2, 4, 6 ]

# ? @@( o1.FindTheseObjects([ :@noname, :hello ]) ) + NL #TODO
#--> [ 5, 6, 8 ]

? @@( o1.TheseObjectsZ([ :@noname, :hello ]) ) + NL
#--> [
#	[ "@noname", [ 5, 8 ] ],
#	[ "hello", [ 6 ] ]
# ]

#--

? @@( o1.FindStzObjects() ) + NL
# [ 2, 4, 5, 6, 8 ]

#--

? @@( o1.FindQObjects() )
#--> [ ]

#--


? @@( o1.FindNonStzObjects() )
#--> [ ]

#--

? o1.ObjectsVarNames()
#--> [ :greeting, :greeting, :hello ]

? o1.NumberOfNamedObjects()
#--> 3

? o1.ObjectsVarNamesU()
#--> [ :greeting, :hello ]

? o1.NumberOfUniqueNamedObjects()
#--> 2

#--

? @@NL( o1.NamedObjects() ) + NL
#--> [ :greeting, :greeting, :hello ]

? @@NL( o1.UnamedObjects() )
#--> [ greeting, hello ]

pf()
# Executed in 0.17 second(s) in Ring 1.23

/*------------

pr()

Vr( "a" : "z" ) '=<~' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.11 second(s) in ring 1.21

/*----
*/
pr()

aList = [1,2,3]
//p1 = new point { x=10 y=20 z=30 }
p1 = [ "x", "y", "z"  ]
? type(ref(p1))
aList + ref(p1)
aList + 5
? find(aList,p1)

pf()

class point x y z



/*======


pr()
? @@( split("::2", ":") )
#--> [ "", '', '2' ]

? @@( @split("::2", ":") )
#--> [ "", '', '2' ]

? @@( StzStringQ("::2").SplitAt(":") )
#--> [ "", '', '2' ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21

/*==== Using a Python code inside Ring ===

pr()

# Reversing a list, the Python way

? Q(1:5)['::-1']
#--> [ 5, 4, 3, 2, 1 ]

# Getting a part of the list (from 2 to 8) with a step of 2

? Q(1:10)['2:8:2']
#--> [ 2, 4, 6, 8 ]

pf()
# Executed in 0.01 second(s).

/*------------

pr()

# Reversing a list, in Python code:
'
range(1, 5)[::-1]
#--> [ 4, 3, 2, 1 ]
'

# Doing it in Ring, Python-way:

? range1Q([ 1, 5 ])['::-1']
#--> [ 4, 3, 2, 1 ]

pf()
# Executed in 0.01 second(s).

/*============

#NOTE: examples taken from this article:
# https://note.nkmk.me/en/python-range-usage

pr()

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
	#--> TRUE

pf()
# Executed in 0.01 second(s).

/*--------------

pr()

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

pf()
# Executed in 0.02 second(s).

/*--------------

pr()

# In python, we get the integer part of the division using the // operator

'345 // 100'
#--> 3

# In Ring, we can simulate this Python syntax by saying:

? Q(345)['// 100']
#--> 3

pf()
# Executed in 0.01 second(s).

/*---------------

pr()

# In Python, this code concatenates a list of items into a string
# using a given separator:

# ' + '.join([ "a", "b", "c" ])
#--> a + b + c

# In Ring, with Softanza, we can use the same code like this:

? Q(' + ').join([ "a", "b", "c" ])
#--> a + b + c

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*--------------

pr()

? range(3)
#--> [ 0, 1, 2 ]

? range1(3)
#--> [ 1, 2, 3 ]

? range([ -3, 4, 2 ])
#--> [ -3, -1, 1, 3 ]

? range1([ -3, 4, 2 ])
#--> [ -3, -1, 1, 3 ]

pf()
# Executed in almost 0 second(s).

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

pr()

	a = 1:5
	b = 4:8
	
	? euc_dist_(a,b)
	#--> 6.71

pf()
# Executed in almost 0 second(s) in Ring 2.21
# Executed in 0.03 second(s) in ring 1.20

def euc_dist_(a,b)':' # we put the : char between two ''
	s = 0.0
	n = len(a)

	for i in range1(n)':'
	# We use range1() to make it start from 1
	# We can also leave range() and add i++

		dist = a[i] - b[i]
		s += dist * dist
	next

	return sqrt(s)

# NOTE this euc_dis() function has beeen added to Softanza.
# To avoid conflict, I added here an _ after the function name.

/*-------------- #ai #bardai #ERROR check it

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
	
	# Using Softanza External Code facility, we can run quiet the same
	# Python code in Ring:
	
	pr()
	
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
	
	pf()
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

pr()

	? range(3)
	#--> [ 0, 1, 2 ]
	
	? range([-3, 3+1, 2])
	#--> [ -3, -1, 1, 3 ]
	
pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*============= #ring #perf #flex

pr()

# Ring print2str() is more performant than Softanza Interpolate (based on Qt)

freind_name = "Mahmoud"
country_name = "Tunisia"

? print2str("Welcome #{freind_name} in your country #{country_name}!")

# It's more flexible (it evaluates expressions like #{2000+19}),
# supports \n escape chars, and accepts non latin texts:

اسم_صديق = "محمود"
اسم_بلد = "تونس"

? print2str("مرحبا بك #{اسم_صديق} في بلدك #{اسم_بلد} !")

#TODO // Use it in Interpolate() function

pf()
# Executed in 0.01 second(s).

/*------------

pr()

freind_name = "Mahmoud"
country_name = "Mahmoud"

? Interpolate("Welcome {freind_name} in your country {country_name}!")

اسم_صديق = "محمود"
اسم_بلد = "تونس"

? Interpolate("مرحبا بك {اسم_صديق} في بلدك {اسم_بلد} !")

pf()
# Executed in 0.03 second(s).

/*------------

pr()

# f-strings are a feature in Python for interpolating string
# content, by dynmalically evaluating variables inside it:

	'
	bestlang = "Python"
	print(f"My best language is {bestlang}!")
	#--> My best language is Python!
	'

# the same syntax can be used in Ring with Softanza like this:

	bestlang = "Ring"
	print( f("My best language is {bestlang}!") )
	#--> My best language is Ring!

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20

/*================ #todo #error

pr()

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
#TODO ERROR check it
	? v([ :x, :y, :z ])
	#--> [ 10, 20, 30 ]
	
	? v([ :x, :z ])
	#--> [ 10, 30 ]
	
	? v([ :x, :x, :z, :y ])
	#--> [ 10, 10, 30, 20 ]

pf()
# Executed in 0.05 second(s)

/*----------------

pr()

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

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*--------------

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*--------------

pr()

Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :say = null, :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ])

? @@( v(:name3) )
#--> _NULL_

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*--------------

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v(:name)
#--> ERROR: Undefined named variable!

pf()

/*--------------

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v([ :name1, :name2, :name7 ])
#--> ERROR: ndefined named variable!

pf()

/*--------------

pr()

Vr([ :name, :grades, :age ]) '=' Vl([ "Mansour", [10, 12, 15], 47 ])
? @@( v(:grades) )
#--> [ 10, 12, 15 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*--------------

pr()

Vr([ :names ]) '=' Vl([ [ "Hussein", "Haneen", "Teebah" ] ])
? @@( v(:names) )
#--> [ "Hussein", "Haneen", "Teebah" ]

pf()
# Executed in 0.01 second(s).

/*--------------

pr()

? @@( tempval() )
#--> _NULL_
? @@( oldval() )
#--> _NULL_

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

pf()
# Executed in 0.02 second(s).

/*============ TERNARY OPERATOR

pr()

# In Python we can use ternary operator like this:
	'
	something = TRUE // or FALSE
	value = "foo" if something else "bar"
	'

# As you might imagine, its equivalent in pure Ring is:
	something = TRUE // or FALSE
	
	if something = TRUE
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
#ERR #todo check it
	bSomething = FALSE
	vr([ :value ]) '=' vl([ "foo" ]) _if(bSomething) _else([ "bar" ])
	? v(:value)
	#--> bar

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*--------------

pr()

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

pf()
# Executed in 0.01 second(s).

/*============

pr()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

#ERR #TODO check it
	bPositive = FALSE
	Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
	? @@( v([ :x, :y, :z ]) )
	#--> [ -1, -2, -3 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.20

/*-------------- #ERR #TODO check it

	pr()
	
	bPositive = FALSE
	V([ :x = 10, :y = 20 ]) _if(bPositive) _else([ -10 ])
	
	? v([:x, :y])
	#--> [ -10, 20 ]
	
	pf()

/*-------------- #ERR #TODO check it

	pr()
	
	bPositive = FALSE
	V([ :x = 10, :y = 20 ]) _if(bPositive) _else([ -10, -20 ])
	
	? v([:x, :y])
	#--> [ -10, -20 ]
	
	pf()

/*--------------

pr()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

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

/*==== Using a PHP code inside Ring  #=== #ERROR #TODO

# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
	echo(min(0, 150, 30, 20, -8, -200));  #--> -200
	echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

StartProfiler()

	echo( Min([0, 150, 30, 20, -8, -200]) );   #--> -200	#ERROR #TODO
	echo( Max([0, 150, 30, 20, -8, -200]) );   #--> 150

	#NOTE that the only difference is to put the numbers in a list
	# by bounding them by [ and ], inside the min() and max() functions

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

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
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.20

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
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20
