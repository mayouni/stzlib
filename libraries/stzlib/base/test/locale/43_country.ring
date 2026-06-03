# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #43.
#ERR Error (R14) : Calling Method without definition: islatinscript

load "../../stzBase.ring"

pr()

StzLocaleQ([ :Language = :English ]) {
	? Country()
	#--> united_states

	? ToTitlecase("in search of lost time")
	#--> In Search Of Lost Time
}

pf()
# Executed in 0.15 second(s) in Ring 1.23
# Executed in 0.78 second(s) in Ring 1.18
