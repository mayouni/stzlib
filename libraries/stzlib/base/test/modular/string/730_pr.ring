# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #730.

load "../../../stzBase.ring"


StzStringQ("original text before hashing") {

	Hash(:MD5)
	? Content()
	#--> 8ffad81de2e13a7b68c7858e4d60e263

}

pf()
# Executed in 0.02 second(s).
