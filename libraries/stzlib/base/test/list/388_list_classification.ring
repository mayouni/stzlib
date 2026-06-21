# Narrative
# --------
# Classifies the members of a list of integer ranges into distinct
# classes, grouping equal members and reporting where each class occurs.
#
# The list holds short-form ranges like 1:5 and 3:9, repeated at several
# positions. Classify() expands each range to its normal form (e.g.
# "[ 1, 2, 3, 4, 5 ]") and uses that string as a key, mapping it to the
# list of positions where it appears (1-based). Because Ring reserves
# "Class", the accessor is named Klass() (or Category()); Klass(cKey)
# returns the positions for one class. The *SF variants keep the compact
# short form "1:5" as the key instead of the expanded normal form, and
# ClassesSF() lists just the short-form class keys. KlassSF("1:5") then
# returns that class's positions.
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
