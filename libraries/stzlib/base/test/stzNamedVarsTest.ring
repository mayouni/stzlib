load "../stzbase.ring"

/*==== #narration DYNAMIC CONSTRUCTION OF VARIABLE NAMES

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

/*---
*/
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

/*----

pr()

Vr([ :x, :y, :z ]) '=' Vl([ -1, 0, 1 ])
? v([ :x, :y, :z ])
#--> [ -1, 0, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*----

pr()

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])
? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20

/*---

pr()

Vr([ :names ]) '=' Vl([ [ "Hussein", "Haneen", "Teebah" ] ])
? @@( v(:names) )
#--> [ "Hussein", "Haneen", "Teebah" ]

pf()
# Executed in 0.01 second(s).

/*---

pr()

? @@( tempval() )
#--> ""
? @@( oldval() )
#--> ""

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
#--> mansour

? @@( tempvarname() ) # same as tempvar()
#--> name

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.20

/*---

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*---

pr()

Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :say = null, :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ])

? @@( v(:name3) )
#--> ""

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*---

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v(:name)
#--> ERROR: Undefined named variable!

pf()

/*---

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v([ :name1, :name2, :name7 ])
#--> ERROR: Undefined named variable!

pf()

/*---

pr()

Vr([ :name, :grades, :age ]) '=' Vl([ "Mansour", [10, 12, 15], 47 ])
? @@( v(:grades) )
#--> [ 10, 12, 15 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*---

pr()

Vr( "a" : "z" ) '=' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.11 second(s) in ring 1.21

/*--- #narration NAMING UNNAMED OBJECTS AND MAKING THEM FINDABLE

pr()

# By default, a softanza object is created with no name
# (actually, with a name called :@noname)

oGreeting = new stzString("Hi!")
? oGreeting.VarName()
#--> @noname

# You can name the object afterward, like this:
oGreeting.SetVarName(:oGreeting) # Or RenameIt()
# and than you can read the name:
? oGreeting.VarName()
#--> ogreeting

# Or you can create the named object in the same time as the object
# it self, by providing a hashlist like this:

oHello = new stzString(:oHello = "Hello Ring!")
# and than you can read the name:
? oHello.VarName() + NL
#--> ohello

# In both cases, we have now objects that we can refer to by their
# names we gave them in our code. And so, we can find them inside a list!

o1 = new stzList([ "one", oGreeting, 12, oGreeting, Q("two"), oHello, 10 , Q(10) ])

? @@( o1.FindObjects() )
#--> [ 2, 4, 5, 6, 8 ]

? @@( o1.ObjectsZ() ) + NL # Or ObjectsAndTheirPositions()
#--> [
#	[ "ogreeting", [ 2, 4 ] ],
#	[ "@noname",  [ 5, 8 ] ],
#	[ "ohello",    [ 6 ]    ]
# ]

? @@( o1.FindObject(:oGreeting) )
#--> [ 2, 4 ]

? @@( o1.FindObject(:oHello) )
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

? @@( o1.TheseObjectsZ([ :@noname, :oHello ]) ) + NL
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
#--> [ "ogreeting", "ogreeting", "ohello" ]

? o1.NumberOfNamedObjects()
#--> 3

? o1.ObjectsVarNamesU()
#--> [ "ogreeting", "ohello" ]

? o1.NumberOfUniqueNamedObjects()
#--> 2

#--

? @@NL( o1.NamedObjects() ) + NL
#--> [ "ogreeting", "ogreeting", "ohello" ]

? @@NL( o1.UnamedObjects() )
#--> [ "ogreeting", "ohello" ]

pf()
# Executed in 0.16 second(s) in Ring 1.23

/*---

pr()

o1 = new stzString(:nation = "Niger")

? ClassName(o1)
#--> stzstring

? IsNamedObject(o1)
#--> TRUE

? ObjectName(o1)
#--> nation

#----

o1 = new stzString("Niger")

? ISNamedObject(o1)
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

/*---

pr()

o1 = new stzString(:nation = "Niger") # A named object
? o1.VarName()
#--> nation

o1.RenameIt(:country) # Or SetVarName()
? o1.VarName()
#--> country

pf()
# Executed in 0.01 second(s).

/*--- #ring

pr()

oMyPoint = new Point
aInnerList = [1, 2, 3]

aList = [ 22, ref(oMyPoint), "B", ref(aInnerList) ]

? find(aList, 22) 		#--> 1
? find(aList, "B")		#--> 3
? find(aList, aInnerList) 	#--> 2
? find(aList, oMyPoint)		#--> 4

pf()

class Point { x=10 y=10 z=10 }

# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

oFriend = StzNamedObjectQ(:oFriend = new Person("Mahmoud"))

aMyList = [ 10, oFriend, "hello", [1, 2,3 ], oFriend, [1, 2, 3], "HELLO" ]

? @@( @Find(aMyList, 10 ) )          # --> [1]
? @@( @Find(aMyList, "hello") )      # --> [3]
? @@( @Find(aMyList, [1, 2, 3]) )    # --> [4, 6]
? @@( @Find(aMyList, oFriend) )      # --> [2, 5]

? ""

? @@( @FindCS(aMyList, "HELLO", FALSE) )  # --> [3, 7]
? @@( @FindCS(aMyList, "HELLO", TRUE) )   # --> [7]

pf()

class Person
    name = ""
    def init(cName)
        name = cName

# Executed in 0.04 second(s) in Ring 1.23
