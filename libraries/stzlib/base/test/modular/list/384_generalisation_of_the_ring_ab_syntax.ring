# Narrative
# --------
# #narration Generalisation of the Ring "A":"B" syntax
#
# Extracted from stzlisttest.ring, block #384.

load "../../../stzBase.ring"


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
