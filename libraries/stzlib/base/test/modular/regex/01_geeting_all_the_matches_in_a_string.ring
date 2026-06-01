# Narrative
# --------
# #  GEETING ALL THE MATCHES IN A STRING  #
#
# Extracted from stzRegexTest.ring, block #1.

load "../../../stzBase.ring"

#---------------------------------------#
pr()

rx("(\d+)") {

	# Currently we can say()

	? Match("The total was 42 dollars and 13 cents.")
	#--> TRUE

	# What I want is to write

	? @@( AllMatches() )
	#--> [ "42", "13" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.22
