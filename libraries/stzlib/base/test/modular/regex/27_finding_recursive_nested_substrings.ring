# Narrative
# --------
# FINDING RECURSIVE (NESTED) SUBSTRINGS
#
# Extracted from stzRegexTest.ring, block #27.

load "../../../stzBase.ring"


pr()

str = "(a(b(c(x)(y))d(z))e)"

rx("(?<outer>\((?<inner>[^()]+|(?R))*\))") {

	? MatchNested("(a(b(c(x)(y))d(z))e)")
	#--> TRUE

	? @@NL( NestedMatches() )
	#--> [
	# 	"(a(b(c(x)(y))d(z))e)",
	# 	"(b(c(x)(y))d(z))",
	# 	"(c(x)(y))",
	# 	"(x)",
	# 	"(y)",
	# 	"(z)"
	# ]

	? @@( FindNested() )		# Or FindNestedMatches()
	#--> [ 1, 3, 5, 7, 10, 15 ]

	? @@NL( FindNestedZZ() )
	#--> [
	# 	[ 1, 20 ],
	# 	[ 3, 18 ],
	# 	[ 5, 13 ],
	# 	[ 7, 9 ],
	# 	[ 10, 12 ],
	# 	[ 15, 17 ]
	# ]
}

pf()
# Executed in 0.05 second(s) in Ring 1.22
