# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #42.

load "../../stzBase.ring"


StzLocaleQ([ :Language = :French ]) {
	? Country()
	#--> france

	? ToTitlecase("in search of lost time")
	#--> In search of lost time
}

pf()
# Executed in 0.14 second(s) in Ring 1.23
# Executed in 0.78 second(s) in Ring 1.18
