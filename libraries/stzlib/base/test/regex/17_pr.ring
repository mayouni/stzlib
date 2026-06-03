# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #17.

load "../../stzBase.ring"


# Match nested parentheses recursively
oRegex = new stzRegex("\((?:[^()]+|(?R))*\)")

# Test string with nested parentheses
cTest = "(a(b(c)d)e)"

# Checking recursive match

? oRegex.MatchRecursive(cTest) # Or MatchRecursive
#--> TRUE

# Showing all nested matches and depth()

? @@NL( oRegex.RecursiveMatchInfo() ) + NL
#--> [
#	[ "isrecursive", TRUE ],
#	[ "depth", 1 ],
#	[ "matches", [
#		[ "(a(b(c)d)e)", [ 1, 11 ] ],
#		[ "(b(c)d)", [ 3, 9 ] ],
#		[ "(c)", [ 5, 7 ] ] ]
#	]
# ]

? @@( oRegex.RecursiveValues() ) + NL
#--> [ "(a(b(c)d)e)", "(b(c)d)", "(c)" ]

? @@NL( oRegex.RecursiveValuesZZ() ) + NL
#--> [
#	[ "(a(b(c)d)e)", [ 1, 11 ] ],
#	[ "(b(c)d)", [ 3, 9 ] ],
#	[ "(c)", [ 5, 7 ] ]
# ]

? @@NL( oRegex.RecursiveValuesZ() ) + NL
#--> [
#	[ "(a(b(c)d)e)", 1 ],
#	[ "(b(c)d)", 3 ],
#	[ "(c)", 5 ]
# ]

? @@( oRegex.FindRecursiveValues() ) + NL
#--> [ 1, 3, 5 ]

? @@( oRegex.FindRecursiveValuesZZ() )
#--> [ [ 1, 11 ], [ 3, 9 ], [ 5, 7 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
