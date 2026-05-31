# Narrative
# --------
# Partial Match: Email Validation
#
# Extracted from stzRegexTest.ring, block #9.

load "../../../stzBase.ring"


pr()

o1 = new stzRegex("^[\w\.-]+@[\w\.-]+\.\w{2,}$")

? @@NL( o1.PartialMatchInfo("user") ) + NL
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "user" ],
#	[ "section", [ 1, 4 ] ]
# ]

? @@NL( o1.PartialMatchInfo("user@example") )
# [
#	[ "matchtype", "partial" ],
#	[ "matched", "user@example" ],
#	[ "section", [ 1, 12 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
