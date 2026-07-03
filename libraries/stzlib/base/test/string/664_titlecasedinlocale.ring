# Narrative
# --------
#
# NOTE (audit, 2026-07-03): DEFERRED -- TitlecasedInLocale/CapitalisedInLocale
# need the locale rules (fr-FR keeps particles lowercase and only caps the
# sentence head); current impl caps every word regardless of locale. Belongs
# to the stzLocale module pass (with 650). Mojibake literals repaired.
# pr()
#
# Extracted from stzStringTest.ring, block #664.

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
