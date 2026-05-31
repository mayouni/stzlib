# Narrative
# --------
# FINDING CAPTURED MATCHES
#
# Extracted from stzRegexTest.ring, block #24.

load "../../../stzBase.ring"


pr()

rx("Name: (?<name>.*), Age: (?<age>\d+)") {

	? Match("Name: John, Age: 30")
	#--> TRUE

	? @@( Matches() )
	#--> [ "John", "30" ]

	? @@( FindMatches() )
	#--> [ 7, 18 ]

	? @@( FindMatchesZZ() )
	#--> [ [ 7, 10 ], [ 18, 19 ] ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.22
