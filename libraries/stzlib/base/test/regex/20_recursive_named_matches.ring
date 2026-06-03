# Narrative
# --------
# RECURSIVE NAMED MATCHES
#
# Extracted from stzRegexTest.ring, block #20.

load "../../stzBase.ring"


pr()

// Pattern with nested (recursive) named capture groups

rx = StzRegexQ("(?<outermost>\((?<middle>[^()]*(\((?<innermost>[^()]+)\))?[^()]*)\))")

// String with 3 levels of nested parentheses

rx.MatchRecursive("(outer(middle(inner)))")

? @@NL( rx.RecursiveMatchInfo() ) + NL
#--> [
#	[ "matchtype", "recursive" ],
#	[ "depth", 2 ],
#	[ "matches", [
#		[ "(middle(inner))", [ 7, 21 ] ],
#		[ "(inner)", [ 14, 20 ] ] ]
#	]
# ]

? rx.Names()
#--> ? rx.RecursiveNames()
#--> [ "outermost", "middle", "innermost" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
