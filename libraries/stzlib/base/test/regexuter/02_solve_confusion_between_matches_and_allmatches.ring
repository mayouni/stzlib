# Narrative
# --------
# #TODO: solve confusion between Matches() and AllMatches()
#
# Extracted from stzregexutertest.ring, block #2.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

#UPDATE : DONE!

pr()

# A function used internally to simply the stzRegexuter class

? @@( AllMatches("The total was 42 dollars and 13 cents.", "(\d+)") )
#--> [ "42", "13" ]

# For normal use, you can write this instead:

rx("(\d+)") {
	Match("The total was 42 dollars and 13 cents.")

	? @@( Matches() )
	#--> [ "42" ]

	? @@( AllMatches() )
	#--> [ "42", "13" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.22
