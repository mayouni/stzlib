# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #21.

load "../../stzBase.ring"

pr()

oRegex = new stzRegex("(?<outer>\((?<inner>[^()]+|(?R))*\))")
oRegex.MatchRecursive("(a(b(c)d)e)")

# Getting the recursive math info without considering named groups
# (RecursiveMatch, for short)

? @@NL( oRegex.RecursiveMatchInfo() ) + NL
#--> [
#	[ "matchtype", "recursive" ],
#	[ "depth", 3 ],
#	[ "matches", [
#		[ "(a(b(c)d)e)", [ 1, 11 ] ],
#		[ "(b(c)d)", [ 3, 9 ] ],
#		[ "(c)", [ 5, 7 ] ]
#	] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
