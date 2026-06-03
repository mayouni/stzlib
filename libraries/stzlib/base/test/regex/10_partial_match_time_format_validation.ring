# Narrative
# --------
# Partial Match: Time Format Validation
#
# Extracted from stzRegexTest.ring, block #10.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("^\d{2}:\d{2}:\d{2}$")

? @@NL( o1.PartialMatchInfo("12") ) + NL
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "12" ],
#	[ "section", [ 1, 2 ] ]
# ]

? @@NL( o1.PartialMatchInfo("12:34") )
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "12:34" ],
#	[ "section", [ 1, 5 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
