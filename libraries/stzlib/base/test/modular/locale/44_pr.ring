# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #44.

load "../../../stzBase.ring"


StzStringQ("tunisian dinar") {
	TitlecaseInLocale("fr-FR")
	? Content()
	#--> Tunisian dinar

	TitlecaseInLocale("en-US")
	? Content()
	#--> Tunisian Dinar
}

pf()
