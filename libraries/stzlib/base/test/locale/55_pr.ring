# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #55.

load "../../stzBase.ring"


StzLocaleQ("en_US") {
	? CountryName()			#--> united_states
	? CountryNativeName()	#--> United States
	? LanguageName()		#--> english
	? LanguageNativeName()	#--> American English
}

pf()
# Executed in 0.03 second(s) in Ring 1.23
