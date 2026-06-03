# Narrative
# --------
# Partial Match: URL Validation
#
# Extracted from stzRegexTest.ring, block #11.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("^https?://[\w-]+(\.[\w-]+)*\.\w{2,}$")

? @@NL( o1.PartialMatchInfo("http") ) + NL
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "http" ],
#	[ "section", [ 1, 4 ] ]
# ]

? @@NL( o1.PartialMatchInfo("https://example") )
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "https://example" ],
#	[ "section", [ 1, 15 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
