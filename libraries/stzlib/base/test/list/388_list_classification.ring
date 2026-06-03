# Narrative
# --------
# #narration LIST CLASSIFICATION
#
# Extracted from stzlisttest.ring, block #388.

load "../../stzBase.ring"


pr()

o1 = new stzList([
	1:5, 3:9, 1:5, 10:15, 3:9, 12:20, 10:15, 1:5, 12:20
])

? @@SP( o1.Classify() )	+ NL # Same as Categorize()
#--> [
#	[ "[ 1, 2, 3, 4, 5 ]",   [1, 3, 8 ] ],	
#	[ "[ 3, 4, 5, 6, 7, 8, 9 ]",   [2, 5 ] ],
#	[ "[ 10, 11, 12, 13, 14, 15 ]", [4, 7 ] ],
#	[ "[ 12, 13, 14, 15, 16, 17, 18, 19, 20 ]", [6, 9 ]
#    ]

#NOTE that lists are transformed to strings so we can use them
# as keys for idenfifying their positions in the hash string.

# Hence we can say:

? @@( o1.Klass("[ 1, 2, 3, 4, 5 ]") ) + NL
#--> [1, 3, 8 ]

# Here, I used "K" because "Class" is a reserved name by Ring.
# If you don't like that, use Category() instead.

# If you prefer getting the classes in "short form" (i.e. "1:5"
# instead of normal form "[1, 2, 3, 4, 5 ]", then use this:

? @@SP( o1.ClassifySF() ) + NL #--> "@C" for "Contiguous" or "Continuous"
#--> [
#	[ "1:5",   [1, 3, 8 ] ],	
#	[ "3:9",   [2, 5 ] ],
#	[ "10:15", [4, 7 ] ],
#	[ "12:20", [6, 9 ]
#    ]

? @@( o1.ClassesSF() ) + NL
#--> [ "1:5", "3:9", "10:15", "12:20" ]
	
? @@( o1.KlassSF("1:5") )
#--> [1, 3, 8]

pf()
# Executed in 0.42 second(s).
