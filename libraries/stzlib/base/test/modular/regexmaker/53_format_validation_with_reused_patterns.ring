# Narrative
# --------
# Format validation with reused patterns
#
# Extracted from stzregexmakertest.ring, block #53.

load "../../../stzBase.ring"


pr()

rxm() {
	DefineGroup("num", "\d{2}")     # Define 2-digit pattern
	AddLiteral("/")
	ReuseGroupPattern("num")        # Reuse same pattern
	AddLiteral("/")
	ReuseGroupPattern("num")        # Reuse again

	? Pattern()
	#--> (?P<num>\d{2})/(?:\d{2})/(?:\d{2})

}

# Let's check the patter against some valid and valid dates

rx("(?P<num>\d{2})/(?:\d{2})/(?:\d{2})") {
	? Match("12/34/56")
	#--> TRUE

	? Match("1/2/3")
	#--> FALSE

	? Match("12/3/45")
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.22
