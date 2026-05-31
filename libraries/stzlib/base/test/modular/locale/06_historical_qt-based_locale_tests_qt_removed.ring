# Narrative
# --------
# HISTORICAL: Qt-based locale tests (Qt removed)
#
# Extracted from stzlocaletest.ring, block #6.

load "../../../stzBase.ring"


pr()

o1 = StzLocaleQ("ja-PW")
? o1.CountryNumber() #--> 108

? StzCountryQ("108").Name() #--> japan

pf()
# Executed in almost 0 second(s) in Ring 1.23
