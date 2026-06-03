# Narrative
# --------
# pf()
#
# Extracted from stzlocaletest.ring, block #13.

load "../../stzBase.ring"


StzLocaleQ("zh-CN") {		
	? CountryName()				#--> china
	? LanguageName()			#--> literary_chinese
	? Currency()				#--> Chinese Yuan
	? CurrencyAbbreviation()	#--> CNY
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.18
