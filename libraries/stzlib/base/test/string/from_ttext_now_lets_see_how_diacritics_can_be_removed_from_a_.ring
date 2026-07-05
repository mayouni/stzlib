load "../../stzBase.ring"
load "../_narrated.ring"

# DiacriticsRemoved strips accents from Latin and Arabic alike.
# Extracted from stzTtexttest.ring, block #9.

Scenario("Removing diacritics")
	Then("a French sentence loses its accents",
		StzStringQ("C'était un énoncé accentuée, à vrai-dire, extrâ!").DiacriticsRemoved(),
		"C'etait un enonce accentuee, a vrai-dire, extra!")
	Then("an Arabic greeting loses its harakat",
		StzStringQ("السَّلَامُ عَلَيْكُمْ").DiacriticsRemoved(),
		"السلام عليكم")
EndScenario()

Summary()
