# Narrative
# --------
# Match duplicated words
#
# Extracted from stzregexmakertest.ring, block #51.

load "../../../stzBase.ring"


pr()

rxm() {
	AddWordBoundary(:start)
	DefineGroup("word", "\w+")      # Define word group
	AddCharacterClass(:space)
	MatchSameContentAs("word")      # Must match same word
	AddWordBoundary(:end)

	? Pattern()
	#--> \b(?P<word>\w+)[\s]*(?P=word)\b
}

# Examples of matches using the constructed pattern

rx("\b(?P<word>\w+)[\s]*(?P=word)\b") {

	? Match("the the")
	#--> TRUE

	? Match("hello hello")
	#--> TRUE

	? Match("the that the")
	#--> FALSE

	? Match("hello word")
	#--> FALSE

}

pf()
# Executed in 0.02 second(s) in Ring 1.22
