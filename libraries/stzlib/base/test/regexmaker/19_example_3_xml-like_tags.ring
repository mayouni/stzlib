# Narrative
# --------
# Example 3: XML-like tags
#
# Extracted from stzregexmakertest.ring, block #19.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

o3 = new stzRecursiveRegexMaker()
o3 {
	EnableNamedRecursion()
	
	AddLevel("tag", "<([^>]+)>")
	AddChildLevel("tag", "content", "[^<>]*")
	AddLevel("close", "</\1>")
	
	? Pattern()
	#--> (?P<tag><([^>]+)>)(?P<content>[^<>]*)</\1>
}

? NL

# Getting pattern information

? @@NL( o3.Info() ) + NL
#--> [
#	[
#		[ "name", "tag" ],
#		[ "pattern", "<([^>]+)>" ],
#		[ "parent", "" ],
#		[ "children", [ 2 ] ],
#		[ "quantifier", "" ]
#	],
#
#	[
#		[ "name", "content" ],
#		[ "pattern", "[^<>]*" ],
#		[ "parent", 1 ],
#		[ "children", [ ] ],
#		[ "quantifier", "" ]
#	],
#
#	[
#		[ "name", "close" ],
#		[ "pattern", "</\1>" ],
#		[ "parent", "" ],
#		[ "children", [ ] ],
#		[ "quantifier", "" ]
#	]
# ]

? @@(o3.LevelNames()) + NL
#--> [ "tag", "content", "close" ]

? @@(o3.LevelChildren("tag"))
#--> [ "content" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
