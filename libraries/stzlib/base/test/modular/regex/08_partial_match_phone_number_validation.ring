# Narrative
# --------
# Partial Match: Phone Number Validation
#
# Extracted from stzRegexTest.ring, block #8.

load "../../../stzBase.ring"


pr()

o1 = new stzRegex("^\d{3}-\d{3}-\d{4}$")

? @@NL( o1.PartialMatchInfo("123") ) + NL
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "123" ],
#	[ "section", [ 1, 3 ] ]
# ]

? @@NL( o1.PartialMatchInfo("123-456") )
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "123-456" ],
#	[ "section", [ 1, 7 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
