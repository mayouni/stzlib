# Narrative
# --------
# Generalises Ring's built-in "A":"B" contiguous-char range to any Unicode block.
#
# Ring natively expands a string range like "A":"F" into the sequence of
# in-between chars, but only for ASCII. Softanza keeps that familiar form
# for ASCII (StzListQ("A":"F") yields A..F) and adds a general solution:
# the L(' "x" : "y" ') helper parses a quoted range expression and walks
# the codepoints, so an Arabic range like "ا":"ج" expands to its contiguous
# Unicode letters. Both lists are then ordinary Softanza lists, queryable
# with Content() and ItemAtPosition(), proving the two forms are interchangeable.
#
# Extracted from stzlisttest.ring, block #384.

load "../../stzBase.ring"


pr()

# In Ring, you can declare a "contiguous" list of chars
# from "A" to "F" like this:

StzListQ("A":"F") {
	? Content()
	#--> [ "A", "B", "C", "D", "E", "F" ]

	? ItemAtPosition(4) + NL #--> "D"
}

# This beeing working only for ASCII chars, Softanza comes
# with a general solution for any "contiguous" UNIOCDE char:

StzListQ( L(' "ا" : "ج" ') ) {
	? Content()
#	#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

	? ItemAtPosition(4)
#	#o--> "ت"
}

pf()
# Executed in 0.07 second(s) in Ring 1.21
