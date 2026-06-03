# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #14.

load "../../stzBase.ring"


StzCountryQ("china") {
	? country()					#--> china
	? abbreviation()			#--> CN

	? longAbbreviation()		#--> CHN
	# or AbbreviationXT()

	? LocaleAbbreviation()

	? Currency()				#--> chinese_yuan
	? CurrencyAbbreviation()	#--> CNY
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.18
