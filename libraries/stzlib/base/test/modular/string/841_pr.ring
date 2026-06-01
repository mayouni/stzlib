# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #841.

load "../../../stzBase.ring"


o1 = new stzLocale("ar-Arab") # Default arabi country is egypr
? o1.CountryName()
#--> egypt

o1 = new stzLocale("AR-Arab-tn")
? o1.CountryName()
#--> tunisia

o1 = new stzLocale("AR-tn")
? o1.CountryName()
#--> tunisia

o1 = new stzLocale("TN-Arab") # TN here means the TswaNa language in South Africa!
? o1.CountryName()
#--> south_africa

? o1.Language()
#--> tswana

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.22
