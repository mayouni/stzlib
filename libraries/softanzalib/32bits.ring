load "stzlib.ring"

/*=========== @narration
*/

pron()

# Do you know that case sensitivity is supported in Softanza,
# not only on stzString but also on stzLits ?!

# Look how we can fin an item case-sensitively:

o1 = new stzList([ "emm", "EMM", "eMm", "EMM" ])

? o1.Find("EMM") # Same as FindCS("EMM", :CS = TRUE)
#--> [ 2, 4 ]

? o1.FindCS("EMM", :CS = FALSE)
#--> [ 1, 2, 3, 4 ]

# In fact, all items are equal when case sensitivity is deactivated!
# In the same way, the size of the list can be counted in a case-sensity way:

? o1.NumberOfItems()
#--> 4

? o1.NumberOfItemsCS(FALSE)
#--> 1

# Now, softanza digs deeper and applies CaseSensitiviy on some other
# non trivial corners of the stzList class : the Content() method!

? o1.Content() # Same as ContentCS(TRUE)
#--> [ "emm", "EMM", "eMm", "EMM" ]

? o1.ContentCS(FALSE)
#--> [ "emm" ]

proff()
# Executed in 0.05 second(s)

/*======= A stzNarration
*/
pron()

o1 = new stzString("123456789")

? o1.Section(3, 5)
#--> "345"

? o1.Section(5, 3)
#--> "345"

? o1.SectionXT(5,3)
#--> "543"

//? o1.Section(-2, -4)
#--> Error message: n1 and n2 must be inside the list.

? o1.SectionXT(-4, -2)
#--> 678

? o1.SectionXT(-2, -4)
#--> 876

proff()
# Executed in 0.03 second(s)

/*======= A stzNarration
*/

pron()

o1 = new stzList(1:9)

? o1.Section(3, 5)
#--> "345"

? o1.Section(5, 3)
#--> "345"

? o1.SectionXT(5,3)
#--> "543"

//? o1.Section(-2, -4)
#--> Error message: n1 and n2 must be inside the list.

? o1.SectionXT(-4, -2)
#--> 678

? o1.SectionXT(-2, -4)
#--> 876

proff()
# Executed in 0.03 second(s)

/*=======

pron()

# The fellowing two code snippets illustrate the use of two similar functions.
# Try to read the code, see the output and identify the difference between them...

# First snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])
	
? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]
	
# Second snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 1, 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "♥", "php", "♥♥", "ruby", "♥", "python", "♥♥", "csharp", "♥" ]

# Read how Google Bard answered the question:
# Link: https://bard.google.com/share/fb5fb52af8de

proff()
# Executed in 0.03 second(s)

/*========

pron()

o1 = new stzList([ "♥", 2, "♥", "♥", 5, "♥" ])
o1.ReplaceByMany("♥", [ 1, 3, 4, 6 ])
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.05 second(s)

/*=====

pron()

	# This example shows how deactivating checking params could enhance
	# performance. By default, the feature is on, and depending on the
	# function you are using, more or less params semantics are checked.
	
	# So, in the case:
	
	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , :By = "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]
	
proff()
# Executed in 0.18 second(s)

/*---

# But if you disable params checking and restartd the same code:

pron()

	CheckParamsOff()

	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , :By = "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]

proff()
# Executed in 0.06 second(s)

/*=====

pron()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceAnyItemsAtPositions([ 1, 3, 4, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "♥♥♥", "softanza" ]

proff()
# Executed in 0.07 second(s)

/*===

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 3, 5, 7, 9], "ring", :By = [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

proff()
#--> Executed in 0.06 second(s)

/*-------

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

proff()
#--> Executed in 0.02 second(s)

/*-----

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])
# Or you can say: o1.ReplaceItemAtPositions([ 3, 5, 7], "ring", :ByMany = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

proff()
#--> Executed in 0.06 second(s)

/*------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥", "♥♥♥" ] )

? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥♥♥", "php", "softanza", "♥", "softanza" ]

proff()
# Executed in 0.03 second(s)

/*=======

pron()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceItemsAtPositionsByMany([ 1, 3, 4, 6 ], [ "ring", "softanza" ] , [ "♥", "♥♥" ])
		
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥", "♥♥", "php", "♥♥" ]

proff()
# Executed in 0.06 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥", "php", "softanza", "♥♥", "softanza" ]
#	^                        ^    ^                        ^

proff()
# Executed in 0.02 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	[ "ring", "softanza" ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#       1    2       3     4    5     6      7    8     9
#--> [ "♥", "ruby", "♥", "♥♥", "♥", "php", "♥♥", "♥♥", "♥" ]
#	^                  ^    ^                 ^
#                    ^                       ^          ^

proff()
# Executed in 0.04 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza", "ring", "softanza", "php", "softanza", "ring", "python"
])

o1.ReplaceAnyItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8 ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥♥", "♥", "♥♥", "php", "♥", "♥♥", "python" ]

proff()
# Executed in 0.03 second(s)

/*=======

pron()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceAnyItemAtPositions([ 1, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

proff()
# Executed in 0.06 second(s)

/*---------

pron()

//CheckParamOff()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceItemAtPositions([ 1, 5 ], "ring", :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

proff()
# Executed in 0.16 second(s)
# NOTE : turn CheckParamsOff() to get 0.03

/*========

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceAnyItemAt(3, :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceItemAt(3, "♥", :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replace. Otherwise, nothing
# will happen. In fact:

o1.ReplaceItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*---

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceItemAt(3, "♥", "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replace. Otherwise, nothing
# will happen. In fact:

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])
o1.ReplaceItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*===

pron()

o1 = new stzList([ "a", "+", "b", "-", "c", "/", "d", "=", "0" ])
o1.ReplaceMany( ["+", "-", "/" ], :by = "*" )
? o1.Content()	
#--> [ "a", "*", "b", "*", "c", "*", "d", "=", "0" ]

proff()
#--> Executed in 0.04 second(s)

/*---

pron()
o1 = new stzList([ "ring", "php", "ruby", "ring", "python", "ring" ])
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content()
#--> [ "♥", "php", "ruby", "♥♥", "python", "♥♥♥" ]

proff()
# Executed in 0.03 second(s)

/*---

pron()
o1 = new stzList([ "ring", "ring", "ruby", "ring", "python", "ring" ])
o1.ReplaceItemByManyXT("ring", [ "♥", "♥♥" ])
	
? @@( o1.Content() )
#--> [ "♥", "♥♥", "ruby", "♥", "python", "♥♥" ]

proff()
# Executed in 0.02 second(s)

/*====
*/
pron()

o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [ [ "A", [ ] ], [ "B", [ [ 2, 1 ] ] ], [ "C", [ [ 1, 1 ], [ 3, 1 ] ] ] ]

proff()

/*-----
*/
pron()

? Intersection([ "A":"C", "A":"C", "A":"C" ])
#--> [ 1, 2, 3 ]

? Intersection([ "A":"C", "A":"B", "A":"C" ])

proff()

/*---

*/
pron()

o1 = new stzList([ 1, :♥, 3, 4, :♥, :♥ ])
anPos = o1.Find(:♥)
#--> [ 2, 5, 6 ]

o1.ReplaceByMany(:♥, [2, 5, 6])
? o1.Content()

#--> [ 1, 2, 3, 4, 5, 6 ]

proff()

/*===

pron()

o1 = new stzList([ "1", "♥", "♥", "4", "5", "6", "♥", "♥", "9" ])

anPos = o1.Find("♥")
#--> [ 2, 3, 7, 8 ]

o1.ReplaceItemsAtPositions( o1.Find("♥"), :By = "★" )
? @@( o1.Content() )
#--> [ "1", "★", "★", "4", "5", "6", "★", "★", "9" ]

proff()
# Executed in 0.06 second(s)

/*---

pron()

? Chars("SOFTANZA")
#--> [ "S", "O", "F", "T", "A", "Z", "A" ]

proff()

/*---

pron()

o1 = new stzList( Q("1♥♥456♥♥901♥♥4").Chars() )

o1 {

	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 7, 8, 12, 13 ]

	# Doing someting with the positions

	ReplaceItemsAtPositions(anPos, :With = "★")
		? Content()
		#--> 1★★456★★901★★4
	
}

proff()
# Executed in 0.08 second(s)

/*===== FIX

pron()

? Round(2.398)
#--> 2.4

? RoundXT(2.398)
#--> 2.40

? CurrentRound()
#--> 2

? Round([ 2.398, :To = 3 ])

proff()

/*-----
*/
pron()

? Q(2.5).RoundedToXT(3)
#--> '2.500'

? Q(2.75).RoundedToXT(0)
#--> '3'

? Q(2).RoundedTo(3)
#--> '2'

? Q(2).RoundedToXT(3)
#--> '2.000'

? Q(12).RoundedToXT(0)
#--> "12"

proff()
# Executed in 0.05 second(s)
