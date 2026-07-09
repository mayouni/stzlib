# Narrative
# --------
# Find -> ReplaceAnyItemsAtPositions, the same idiom as #56 but driven from a
# string's characters and run inside an object-scope { } block.
#
# Q("1♥♥456♥♥901♥♥4").Chars() builds a stzList of single characters; inside
# the o1 { ... } block the unqualified Find/ReplaceAnyItemsAtPositions/Content
# calls all target o1. Find("♥") locates the six ♥ characters and they are
# replaced in place by "★". The :With and :By labels are interchangeable here.7
#
# Extracted from stzlisttest.ring, block #57.

load "../../stzBase.ring"

pr()

o1 = new stzList( Q("1♥♥456♥♥901♥♥4").Chars() )

o1 {

	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 7, 8, 12, 13 ]

	# Doing someting with the positions

	ReplaceAnyItemsAtPositions(anPos, :With = "★")
		? Content()
		#--> [ "1","★","★","4","5","6","★","★","9","0","1","★","★","4" ]
	
}

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.06 second(s) before
