# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #47.

load "../../stzBase.ring"


? StzLocaleQ("ar_eg").CountryPhoneCode()
#--> "+20"

? StzLocaleQ([ :Country = :Niger ]).CountryPhoneCode()
#--> +227

? StzLocaleQ(:Niger).CountryPhoneCode()
#--> +227

pf()
# Executed in 0.01 second(s) in Ring 1.23
