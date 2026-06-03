# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #54.

load "../../stzBase.ring"


StzLocaleQ("ru_RU") {
	? CountryName()			#--> russia
	? CountryNativeName()	#--> Россия
	? LanguageName()		#--> russian
	? LanguageNativeName()	#--> русский
}

pf()
# Executed in 0.03 second(s) in Ring 1.23
