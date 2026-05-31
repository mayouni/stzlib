# Narrative
# --------
# #TODO locale casing error
#
# Extracted from stzlocaletest.ring, block #19.

load "../../../stzBase.ring"


pr()

oLocale = StzLocaleQ("cmn-CN")
? oLocale.Name()	# Should return China locale but returns C Locale

#--> This induces stzLocale in error:

? StzLocaleQ("cmn_CN").CountryName()	# returns NULL but should return China!

#--> TODO: Verify this bug for all the other locales (see next code)

pf()
