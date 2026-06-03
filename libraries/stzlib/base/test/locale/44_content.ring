# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #44.
#ERR Error (R3) : Calling Function without definition: titlecaseinlocale

load "../../stzBase.ring"

pr()

StzStringQ("tunisian dinar") {
	TitlecaseInLocale("fr-FR")
	? Content()
	#--> Tunisian dinar

	TitlecaseInLocale("en-US")
	? Content()
	#--> Tunisian Dinar
}

pf()
