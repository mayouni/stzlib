load "stzlib.ring"


/*-------------

pron()

o1 = new stzList([ "Ring", "Ruby", "Python" ])

? o1.CommonItems(:With = [ "Julia", "Ring", "Go", "Python" ])
#--> [ "Ring", "Python" ]

proff()
#--> Executed in 0.06 second(s)

/*-------------

pron()

o1 = new stzListOfLists([
	[ "Ring", "Ruby", "Python" ],
	[ "Julia", "Ring", "Go", "Python" ],
	[ "C#", "PHP", "Python", "Ring" ]
])

? o1.CommonItems()
#--> [ "Ring", "Pyhton" ]

proff()
#--> Executed in 0.10 second(s)

/*-------------

pron()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3, "c" ])
? @@S( o1.ToSet() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ], "abc", "bc", "c" ]

proff()
# Executed in 0.12 second(s)

/*-------------

pron()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3, "c" ])

? o1.FindDuplicates()
#--> [ 5, 6, 8, 10 ]
# Executed in 0.11 second(s)

? @@S( o1.ItemsAtPositions([ 5, 6, 8, 10 ]) )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]
# Executed in 0.02 second(s)

? @@S( o1.Duplicates() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]
# Executed in 0.12 second(s)

? @@S( o1.DuplicatesZ() )
#--> [ [ "a", 5 ], [ "ab", 6 ], [ "b", 8 ], [ [ 1, 2, 3 ], 10 ] ]
# Executed in 0.23 second(s)

proff()
# Executed in 0.46 second(s)

/*-------------

pron()

o1 = new stzString("ab")
? @@S( o1.CommonSubStrings(:With = "abc") )
#--> [ "a", "ab", "b" ]

proff()
# Executed in 0.08 second(s)

/*-------------

pron()

aList1 = Q("Ring is nice").SubStrings()
aList2 = Q("I love Ring").SubStrings()

? @@S( Q(aList1).CommonItems(aList2) )
#--> [ "i", " ", "n", "e", "R", "Ri", "Rin", "Ring", "in", "ing", "ng", "g" ]
# Executed in 0.60 second(s)

o1 = new stzListOfLists([ aList1, aList2 ])
? @@S( o1.CommonItems() )
#--> [ "i", " ", "n", "e", "R", "Ri", "Rin", "Ring", "in", "ing", "ng", "g" ]
#--> Executed in 0.64 second(s)

proff()
# Executed in 0.98 second(s)

/*-------------
*/
pron()

o1 = new stzString("Ring is nice")
? @@S( o1.CommonSubStrings(:With = "I love Ring") )
#--> [ " ", "R", "Ri", "Rin", "Ring", "e", "g", "i", "in", "ing", "n", "ng" ]

proff()
# Executed in 0.60 second(s)

/*=============

pron()

? @@("n")	#--> "n"
? @@('n')	#--> "n"
? @@("'n'")	#--> "'n'"
? @@('"n"')	#--> '"n"'

proff()
#--> Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "a", "ab", "abnA", "abAb" ])

? o1.Contains("n")
#--> FALSE

? o1.FindFirst("n")
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*----------

pron()
o1 = new stzList([ "a", "ab", 1:3, "abA", "abAb", 1:3 ])

? o1.ContainsCS("ab", TRUE)
#--> TRUE

? o1.FindFirstCS("AB", FALSE)
#--> 2

? o1.FindLastCS("ABA", FALSE)
#--> 4

? o1.FindFirst(1:3)
#--> 3

? o1.FindLast(1:3)
#--> 6

proff()
# Executed in 0.09 second(s)

/*----------

pron()

o1 = new stzString("abAb")

? o1.NumberOfSubStrings()
#--> 10
# Executed in 0.02 second(s)

? @@S( o1.SubStrings() )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ]
# Executed in 0.04 second(s)

? o1.NumberOfSubStringsCS(FALSE)
#--> 7
# Executed in 0.12 second(s)

? @@S( o1.SubStringsCS(FALSE) )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ]
# Executed in 0.12 second(s)

proff()
#--> Executed in 0.27 second(s)

/*----------

pron()

o1 = new stzString("hello")
? o1.NumberOfSubStrings()
#--> 15

? @@S( o1.SubStrings() )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "l", "lo",
#	"o"
# ]

proff()
# Executed in 0.06 second(s)

/*----------

pron()

o1 = new stzString("hello")
? o1.NumberOfSubStringsCS(FALSE)
#--> 14

? @@S( o1.SubStringsCS(FALSE) )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "lo",
#	"o"
# ]

proff()
# Executed in 0.54 second(s)

/*----------

pron()

o1 = new stzString("*4*34")
? o1.NumberOfSubStrings()
#--> 15

? @@S( o1.SubStrings() )
#--> [
#	"*", "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*",
#	"*3", "*34", "3", "34", "4"
# ]

proff()
# Executed in 0.05 second(s)

/*=============

pron()

o1 = new stzList([ "*", "4", "*", "3", "4" ])
//o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.05 second(s)

#
/*----------

pron()

o1 = new stzList([
	"*", "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.NumberOfDuplicates()
#--> 2

? o1.FindDuplicates()
#--> [10, 15]

? o1.Duplicates()
#--> ["*", 4]

? o1.DuplicatesZ()
#--> [ "*" = 10, "4" = 15 ]

proff()
# Executed in 0.25 second(s)

/*-----------

pron()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.28 second(s)

/*----------

pron()
? "Please wait..."
o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 15

? o1.Duplicates()
#--> [
#	"p", " ", "r", "ri", "rin",
#	"ring", "i", "in", "ing", "n", 
#	"ng", "g", "r", "ri","i"
# ]

proff()
# Executed in 3.33 second(s)

/*----------

pron()

o1 = new stzString("RINGORIALAND")
? o1.ContainsDuplicates()
#--> TRUE

# The number of duplicates is 5:
? o1.NumberOfDuplicates()
#--> 5

# But, if we check their positions we get only 4 positions!
? @@S( o1.FindDuplicates() )
#--> [ 6, 7, 10, 11 ]

# The dupicates are effectively 5:
? @@S( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]

# To find an explication let's use the DuplicatesAndTheirPositions()
# function, or use its short form DuplicatesZ()
? @@S( o1.DuplicatesZ() )
#--> [ [ "R", 6 ], [ "RI", 6 ], [ "I", 7 ], [ "A", 10 ], [ "N", 11 ] ]

# Hence we see that position 6 corresponds to two duplicated substrings: "R" and "RI"                                                                                                                             

proff()
# Executed in 1.57 second(s)

