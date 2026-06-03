# Narrative
# --------
# Partial Match: Detailed match information for UI feedback
#
# Extracted from stzRegexTest.ring, block #5.

load "../../stzBase.ring"

pr()

o1 = new stzRegex("hello\d{3}")

? @@NL(o1.PartialMatchInfo("hello12"))
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "hello12" ],
#	[ "section", [ 1, 7 ] ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
