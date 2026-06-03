# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #19.

load "../../stzBase.ring"

pr()

rx = StzRegexQ("\((.*\((.*)\))\)")  // A pattern to match nested parentheses

rx.MatchRecursive("f1(f2(f3(x))")

? @@NL( rx.RecursiveMatchInfo() )
#--> [
#	[ "isrecursive", TRUE ],
#	[ "depth", 2 ],
#	[ "matches", [
#		[ "(f2(f3(x))", [ 3, 12 ] ],
#		[ "(f3(x))", [ 6, 12 ] ] ]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
