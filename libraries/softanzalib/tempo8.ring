load "stzlib.ring"

#-- @narration: long functions names are necessary to Softanza but not to you!

pron()

# When you dig inside Softanza code, you will sometimes encouter functions
# with very long names like for example:

#                         7.9....4.6                3.5....4.2
o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? @@( o1.FindSubStringBoundsUpToNCharsAsSections("Ring", 2) )
#--> [ [ 8, 9 ], [ 14, 15 ], [ 34, 35 ], [ 40, 41 ] ]

# This shouldn't dissiponts you Let me explain why.

# Although the function is clear enough about what its does (in this case:
# finding the substrings bounding the substring "Ring" up to 2 chars), it
# is not made to be used directly by you.

# In fact, those long functions are used internally by other usual functions
# that you will need in practice, while letting the codebase be more readable.

# In our case, you would need this one:

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # You will understand the use of XT() in a moment ;)
#--> [ [ "<<", ">>" ], [ "((", "))" ] ]

# That you should use when you don't want all the bounding sunstrings to be returned
# (in this case all the 3 chars), but only 2 chars of each bound.

# To return all the chars bounding the substring "Ring" you say:

? o1.BoundsOf("Ring")
#--> [ [ "<<<", ">>" ], [ "(((", ")))" ] ]

# NOTE: Now you understand why we used the XT() extension to the name of BoundsOf()
# function, to say its an extended form of the main function, where we can specify
# the number of chars in the bound.

proff()

/*---

pron()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<", ">>"], [ "((", "))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()

proff()

/*---

pron()

# Case 1 : Checking if the string is bounded by ONE substring

o1 = new stzString("_world_")
? o1.IsBoundedBy("_") #--> TRUE

# Case 1 : Checking if the string is bounded by TWO substrings

o1 = new stzString("/world\")
? o1.IsBoundedBy([ "/", "\" ]) #--> TRUE

# Case 3 : Checking if the string is bounded by one (or two)
# substrings INSIDE an other string

? Q("world").IsBoundedBy([ "_", :In = "_world_" ])
#--> TRUE
? Q("world").IsBoundedBy([ ["/","\"], :In = "/world\" ])

# Case 4 :

? Q("_").IsBoundOf("world", :In = "Hello _world_ of Ring!")
#--> TRUE

? Q(["/","\"]).IsBoundOf("world", :In = "Hello /world\ of Ring!")

proff()

/*---

pron()

# In Softanza, if you have a string bounded by some chars,
# you can remove them to keep only the string:

o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

# In case you don't know the bounds, Softanza knows them,
# and can remove them for you:

o1 = new stzString("<<Go!>>")
? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.BoundsRemoved()
#--> "Go!"

proff()
# Executed in 0.24 second(s)

/*----

pron()

? Q(1:7) - These(3:5) # Or AllThese() or EachIn()
#--> [ 1, 2, 6, 7 ]

? Q(1:7) - These(3:5)
proff()


pron()

? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

proff()
# Executed in 0.04 second(s)


/*----

pron()

	a1 = [ "A", "A", "B", "C" ]
	a2 = [ "B", "A", "C", "B", "A", "X" ]

	o1 = new stzListOfLists([ a1, a2 ])
	? @@( o1.IndexBy(:Position) )

proff()
