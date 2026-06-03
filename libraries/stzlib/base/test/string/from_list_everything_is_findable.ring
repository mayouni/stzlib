# Narrative
# --------
# #narration: everything is findable
#
# Extracted from stzlisttest.ring, block #17.

load "../../stzBase.ring"


pr()

# A stzString object can be created in one of three ways

# 1. From a normal Ring string

	o1 = new stzString("hello")
	? o1.Uppercased()
	#--> HELLO

# 2. From a string

	o2 = new stzString( "hello" )
	? o2.Uppercased()
	#--> HELLO

# 3. From a pair of strings, the first beeing the name of the object
#    (it's a NAMED OBJECT then, made specifically to making objects findable!),
#    and the second beeing the value of the string:

	o3 = new stzString( :o3 = "hello" )
	? o3.Uppercased()
	#--> HELLO

# You want to see how NAMED OBJECTS can be findable? Ok.
# Let's consider the following list :

aMyList = [ "Hi", o1, "how", 1:3, o2, "are", o3, "you?", 1:3, o3, 99 ]

# In Ring, you can find the string "how" like this:

? find(aMyList, "how") # or StzFind() if you want
#--> 3

# And find the number 99 like this:
? find(aMyList, 99)
#--> 11

# But you can't find a list:

	//? find(aMyList, 1:3)
	#--> ERROR: Bad parameter type!

# Nor an object:

	//? find(aMyList, o1)
	#--> ERROR: Bad parameter type!

# In Softanza, you can find numbers and strings as usual, but also you
# can find a list, any list, and an object if this object is created as
# a Softanza NAMED object (like o3 above)...

# Let's check, first, how a list can be found inside a list:

	? Q(aMyList).Find(1:3) # Reminder : Q() elevates aMyList to a stzList object
	#--> [ 4, 9 ]

# Now let's find the o3 named object:

	? o3.IsNamedObject()
	#--> TRUE

	? Q(aMyList).Find(o3)
	#--> [ 7, 10 ]

# Of course, Softanza can't find an object if it is not named!

	? o2.IsNamedObject()
	#--> FALSE
	
	//? Q(aMyList).Find(o2)
	#--> ERROR: Line 689 Can't find an unnamed object!

pf()
# Executed in 0.03 second(s)
