# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #70.

load "../../../stzBase.ring"


o1 = new stzLocale([ :Language = "portuguese", :Script = "Latn", :Country = "BR" ])
? o1.Abbreviation()		#--> pt_BR
? o1.LanguageName()		#--> portuguese
? o1.CountryName()		#--> brazil
? o1.CountryNumber() 	#--> 30

pf()
# Executed in 0.04 second(s) in Ring 1.23
