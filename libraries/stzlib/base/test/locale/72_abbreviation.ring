# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #72.

load "../../stzBase.ring"

pr()

#  Defining a locale from just a country

o1 = new stzLocale([ :Country = "Niger" ])
# Or simply: o1 = new stzLocale(:Niger)

? o1.Abbreviation()	#--> fr_NE
? o1.LanguageName()	#--> french
? o1.CountryName()	#--> niger

pf()
# Executed in 0.04 second(s) in Ring 1.23
