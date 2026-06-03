# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #16.

load "../../stzBase.ring"

pr()

StzCountryQ(:american_samoa) {
	? Name()					#--> american_samoa
	? Language()				#--> samaon

	? LanguageAbbreviation()	#--> "sm"
	? Abbreviation()			#--> "AS"

	? LocaleAbbreviation()		#--> "en-AS"
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
