# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #22.

load "../../stzBase.ring"

pr()

str = "(a(b(c(x)(y))d(z))e)"

rx("(?<outer>\((?<inner>[^()]+|(?R))*\))") {

	# Let's make a normal match

	? Match(str)
	#--> TRUE

	# What kind of match?

	? MatchType()
	#--> :MatchEntireContent

	# With which options?

	? @@( MatchOptions() )
	#--> [ "dotmatchesall" ]

	# Get them togethor (match type and options)

	? @@( MatchTypeXT() ) + NL
	#--> [ "matchentirecontent", "dotmatchesall" ]

	# And see the matches it captures (along with their positions)

	? @@NL( MatchesZZ() ) + NL
	#--> [
	# 	[ "(a(b(c(x)(y))d(z))e)", [ 1, 20 ] ],
	# 	[ "e", [ 19, 19 ] ]
	# ]

	? NL + "---" + NL

	# Now we make rather a recursive (nested) match

	? MatchRecursive(str) + NL	# Or MatchNested()
	#--> TRUE

	? @@( MatchTypeXT() ) + NL
	#--> [ "matchentirecontent", "recursivematch" ]

	# And check what it matches to in the string

	? @@NL( RecursiveMatchesZZ() ) + NL
	#--> [
	# 	[ "(a(b(c(x)(y))d(z))e)", [ 1, 20 ] ],
	# 	[ "(b(c(x)(y))d(z))", [ 3, 18 ] ],
	# 	[ "(c(x)(y))", [ 5, 13 ] ],
	# 	[ "(x)", [ 7, 9 ] ],
	# 	[ "(y)", [ 10, 12 ] ],
	# 	[ "(z)", [ 15, 17 ] ]
	# ]

}

pf()
# Executed in 0.03 second(s) in Ring 1.22
