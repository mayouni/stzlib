# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #71.

load "../../stzBase.ring"


# Defining a locale from just a language

o1 = new stzLocale([ :Language = "romanian" ])
# Or simply: o1 = new stzLocale("romanian")

? o1.Abbreviation()		#--> ro_RO
? o1.Abbreviation() + NL	#--> ro_RO

? o1.LanguageNumber()		#--> 95
? o1.LanguageName() + NL	#--> romanian

? o1.CountryNumber()		#--> 177
? o1.CountryName()			#--> romania

pf()
# Executed in 0.04 second(s) in Ring 1.23
