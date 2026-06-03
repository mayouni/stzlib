# Narrative
# --------
# Use of IsBeforeGroup
#
# Extracted from stzregexmakertest.ring, block #54.

load "../../stzBase.ring"


pr()

o1 = new stzRegexMaker
o1 {
	AddCharacterClass(:word)	# Match word characters first
	AddCharacterClass(:space)	# Then space
	DefineGroup("num", "\d+")	# Then capture number

	? Pattern()
	#--> [\w]+[\s]+(?P<num>\d+)	# Correct order
}

rx("[\w]+[\s]+(?P<num>\d+)") {

	? Match("hello 123")
	#--> TRUE

	? Match("test 456")
	#--> TRUE

	? Match("123 hello")
	#--> FALSE

	? Match("test")
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.22
