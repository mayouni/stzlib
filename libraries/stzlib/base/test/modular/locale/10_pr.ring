# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #10.

load "../../../stzBase.ring"


StzLocaleQ("ar-TN") {
	? CountryName()		#--> tunisia
	? LanguageName()	#--> arabic
}

StzLocaleQ("fr-TN") {
	? CountryName()		#--> tunisia
	? LanguageName()	#--> french
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
