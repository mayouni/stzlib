# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #664.
#ERR Error (R3) : Calling Function without definition: titlecasedinlocale

load "../../stzBase.ring"

pr()

StzStringQ("in search of lost time") {

	? TitlecasedInLocale("en-US")
	#--> In Search Of Lost Time

	? CapitalisedInLocale("en-US")
	#--> In Search Of Lost Time
}

StzStringQ("Ã  la recherche du temps perdu") {

	? TitlecasedInLocale("fr-FR")
	#--> À la recherche du temps perdu

	? CapitalisedInLocale("fr-FR")
	# !--> À la Recherche du Temps Perdu
}

pf()
# Executed in 0.39 second(s) in Ring 1.22
