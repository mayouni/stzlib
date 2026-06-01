# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #505.

load "../../../stzBase.ring"


# Here is a fluent chain of actions that starts from
# the word "LIFE" and ends at the word "L ♥ F E"

? Q("LIFE").
	LowercaseQ().
	SpacifyQ().

	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().

	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).

	Content() + NL
	#--> L ♥ F E

# We can see what happened internally interms of updates
# by adding the H suffix to the Q() while using History()

? @@NL(
	QH("LIFE").
	LowercaseQ().
	SpacifyQ().

	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().

	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).

	History()
) + NL
#--> [
#	"LIFE",
#	"life",
#	"l i f e",
#
#	[ "l", "i", "f", "e" ],
#	[ "L", "I", "F", "E" ],
#	[ "L", "I", "F", "E" ],
#
#	"L I F E",
#	"L ♥ F E"
# ]

# Or we add an HH() suffix if we need more inforamtion
# about the types of intermediate objects updated
# the execution time those update have taken, and
# their size in memory in bytes (inside the Ring VM)

? @@NL(
	QHH("LIFE").
	LowercaseQ().
	SpacifyQ().
	CharsQ().

	RemoveSpacesQ().
	UppercaseQ().
	JoinQ().

	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).
	History()
) + NL
#--> [
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "life", "stzstring", 0.02, 435 ],
#	[ "l i f e", "stzstring", 0.04, 435 ],
#
#	[ [ "l", " ", "i", " ", "f", " ", "e" ], "stzlist", 0, 322 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0, 319 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "L I F E", "stzstring", 0.02, 435 ],
#
#	[ [ "with", "♥" ], "stzlist", 0, 322 ],
#
#	[ "L ♥ F E", "stzstring", 0.01, 435 ]
# ]

# NOTE that only the methods that update the objects are traced!

# The extensive output of the QHH() small function can be tuned
# at your will, showing only the information you need.

# The idea is to add a suffix of one letter to each data:
# V to Value, T to Type, M to Time, and S to Size.

# So if you want to show only the Time and Size, you write:

? @@NL(
	QHHMS("LIFE").	# M for Time and S for Size
	LowercaseQ().
	SpacifyQ().
	CharsQ().

	RemoveSpacesQ().
	UppercaseQ().
	JoinQ().

	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).
	History()
) + NL
#--> [
#	[ 0, 435 ],
#	[ 0.02, 435 ],
#	[ 0.04, 435 ],
#	[ 0, 322 ],
#	[ 0, 319 ],
#	[ 0.01, 319 ],
#	[ 0, 319 ],
#	[ 0.01, 319 ],
#	[ 0, 319 ],
#	[ 0, 435 ],
#	[ 0.02, 435 ],
#	[ 0, 322 ],
#	[ 0.01, 435 ]
# ]

# And if you want to show Value, Type and Size, you write:

? @@NL(
	QHHVTS("LIFE").	# V for Value, T for Type and S ofr Size
	LowercaseQ().
	SpacifyQ().
	CharsQ().

	RemoveSpacesQ().
	UppercaseQ().
	JoinQ().

	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).
	History()
)
#--> [
#	[ "LIFE", "stzstring", 435 ],
#	[ "life", "stzstring", 435 ],
#	[ "l i f e", "stzstring", 435 ],
#	[ [ "l", " ", "i", " ", "f", " ", "e" ], "stzlist", 322 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 319 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 319 ],
#	[ "LIFE", "stzstring", 435 ],
#	[ "L I F E", "stzstring", 435 ],
#	[ [ "with", "♥" ], "stzlist", 322 ],
#	[ "L ♥ F E", "stzstring", 435 ]
# ]

pf()
# Executed in 0.60 second(s) in Ring 1.22
