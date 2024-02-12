load "stzlib.ring"

pron()

? Q(' "A" : "E" ').ToList()

proff()

/*====

pron()

o1 = new stzString("ilir")

? o1.Copy().UppercaseQ().SpacifyQ().ReplaceQ(" ", "*").Content()
#--> "I*L*R"

? o1.Content()
#--> "ilir"

proff()
# Executed in 0.10 second(s)

/*====

pron()

o1 = new stzList([ "1", "2", "♥", "4", "5", "♥", "6", "7", "♥", "9" ])

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

proff()
# Executed in 0.03 second(s)

/*----

pron()

o1 = new stzString("12♥45♥67♥9")

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

? @@( o1.AntiFindZZ("♥") )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

proff()

/*====

/*---

*/

pron()

Q( 1:5 + "A" + "B" + 8 + 9 ) {

	Show()
	#--> [ 1, 2, 3, 4, 5, "A", "B", 8, 10 ]

	Randomise()
	? Show()

}

proff()

/*----
pron()

Q("123456789") {

	? @@( ARandomSection() ) + NL # Or ASection() or ASubString etc.
	#--> "234"

	? @@( ARandomSectionZ() ) + NL
	#--> [ "678", [ 6, 8 ] ]

	? @@( SomeRandomSections() ) + NL
	#--> [ "345678", "4567" ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [ [ "3456", 3 ], [ "45", 4 ] ]

	? @@( SomeRandomSectionsZZ() )
	#--> [
	# 	[ "23456", [ 2, 6 ] ],
	# 	[ "12", [ 1, 2 ] ],
	# 	[ "78", [ 7, 8 ] ],
	# 	[ "34", [ 3, 4 ] ],
	# 	[ "89", [ 8, 9 ] ],
	# 	[ "4567", [ 4, 7 ] ],
	# 	[ "56", [ 5, 6 ] ]
	# ]
}

proff()

/*---

pron()

Q([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]) {

	? @@( ARandomSection() ) + NL
	#--> [ "7", "8" ]

	? @@( ARandomSectionZ() ) + NL
	#--> [ [ "3", "4", "5", "6", "7", "8" ], 3 ]

	? @@( ARandomSectionZZ() ) + NL
	#--> [ [ "1", "2", "3", "4", "5", "6" ], [ 1, 6 ] ]


	? @@( SomeRandomSections() ) + NL
	#--> [
	# 	[ "1", "2", "3", "4", "5", "6" ],
	# 	[ "5", "6", "7", "8", "9" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8", "9" ],
	# 	[ "8", "9" ], [ "4", "5", "6" ]
	# ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [
	# 	[ [ "5", "6", "7", "8" ], 5 ],
	# 	[ [ "1", "2", "3", "4", "5", "6", "7" ], 1 ]
	# ]

	? @@( SomeRandomSectionsZZ() ) + NL
	#--> [
	# 	[ [ "6", "7", "8" ], [ 6, 8 ] ],
	# 	[ [ "7", "8" ], [ 7, 8 ] ]
	# ]

	? @@( NRandomSections(2) ) + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ "4", "5", "6" ] ]

	? @@( NRandomSectionsZ(2) ) + NL
	#--> [ [ [ "3", "4", "5", "6" ], 3 ], [ [ "8", "9" ], 8 ] ]

	? @@( NRandomSectionsZZ(2) )
	#--> [
	# 	[ [ "4", "5" ], [ 4, 5 ] ],
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	# ]
}

proff()
# Executed in 0.05 second(s)

/*---

pron()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? NRandomItems(3)
	#--> [ "A", "S", "Z" ]

	? @@( NRandomItemsZ(3) )
	#--> [ [ "S", 1 ], [ "A", 8 ], [ "N", 6 ] ]
}

proff()

/*----

pron()

Q("SOFTANZA") {

	? ARandomPosition()
	#--> 8

	? ARandomChar()
	#--> T

	? ARandomPositionGreaterThan(4)
	#--> 8

	? ARandomCharAfterPosition(4)
	#--> A

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomCharExcept("A")
	#--> S

	? ARandomPositionLessThan(4)
	#--> 2

	? ARandomCharBefore(4)
	#--> S

	? ARandomCharAfter("T")
	#--> N

	? ARandomCharBefore("T")
	#--> S

}

proff()
# Executed in 0.05 second(s)

/*-------

pron()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? ARandomPosition()
	#--> 3

	? ARandomItem()
	#--> S

	? ARandomPositionGreaterThan(4)
	#--> 5

	? ARandomItemAfterPosition(4)
	#--> N

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomItemExcept("A")
	#--> Z

	? ARandomPositionLessThan(4)
	#--> 3

	? ARandomItemBeforePosition(4)
	#--> O

	? ARandomItemAfter("T")
	#--> A

	? ARandomItemBefore("T")
	#--> O

}

proff()
# Executed in 0.04 second(s)

/*========

pron()

o1 = new stzString("Ring Programming Language")

? o1.Section(6, o1.RandomPositionAfter(6) )
#--> Programming Lang

? o1.Section(6, o1.FindNth(3, "g") )
#--> Programming

? o1.Section( :From = "L", :To = "e")
#--> Language

#--

? o1.Range(6, 11)
#--> Programming

? o1.SectionXT(6, :UpToNCHars = 11)
#--> Programming

proff()
# Executed in 0.08 second(s)

/*=========== @narration

pron()

# Do you know that case sensitivity is supported in Softanza,
# not only on stzString but also on stzList ?!

# Look how we can fin an item case-sensitively:

o1 = new stzList([ "emm", "EMM", "eMm", "EMM" ])

? o1.Find("EMM") # Same as FindCS("EMM", :CS = TRUE)
#--> [ 2, 4 ]

? o1.FindCS("EMM", :CS = FALSE)
#--> [ 1, 2, 3, 4 ]

# In fact, all items are equal when case sensitivity is not considered (set to FALSE)!
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

pron()

# In Softanza, you can get a part of a list (or string) using
# Section() function, also called Slice()

o1 = new stzString("123456789")

? o1.Section(3, 5)
#--> "345"

# When you inverse the params so the first is greater then the second,
# nothing happens to the result ( the Section() function is not aware
# of the direction of parsing ) :

? o1.Section(5, 3)
#--> "345"

# You may argue that it would be useful, in this case, to embrace the
# Python-way of returning an inversed string (or list)...

# Softanza does not reject that, and finds it very useful too! But, it just
# requires that you use the extended form of the function, SectionXT() :

? o1.SectionXT(5,3)
#--> "543"

# As you see, the section has been reversed. But you can do more, and use
# negative numbers to order Softanza to start parsing from the end:

? o1.SectionXT(-4, -2)
#--> 678

? o1.SectionXT(-2, -4)
#--> 876

# Rember : if you try these fency things with the more conservative Section()
# methond (without ...XT() extension), and for Softanza to stay simple and
# consitent for the most common use cases, you will get an error:

? o1.Section(-2, -4)
#--> Error message: n1 and n2 must be inside the list.

# Before you leave : All what works for stzString, will work for stzList.
# For our case, just change the first line of the code to use stzList instead
# of stzString, like this :

o1 = new stzList("1":"9")

# Now you can run the code sucessfully withou any modification.

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
*/
pron()
		o1 = new stzString("ring php ruby ring python ring")
		o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
	
		? o1.Content() #--> "♥ php ruby ♥♥ python ♥♥♥"
proff()
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
