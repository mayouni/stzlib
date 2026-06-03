# Narrative
# --------
# HTML tag matching
#
# Extracted from stzregexmakertest.ring, block #52.

load "../../stzBase.ring"


pr()

rxm() {
	DefineGroup("tag", "<([a-z]+)>")   # Include < > in the tag pattern
	AddCharacterClass(:any)            # Add .* for content
	MatchOppositeTagAs("tag")         

	? Pattern()
	#--> (?P<tag><([a-z]+)>)</(?P=tag)>
}

rx("(?P<tag><([a-z]+)>).*</\2>") {

	? Match("<div>content</div>")
	#--> TRUE

	? Match("<p>text</p>")
	#--> TRUE

	? Match("<div>text</p>")
	#--> FALSE

	? Match("<div>text</span>")
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.22
