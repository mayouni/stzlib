# Narrative
# --------
# #TODO
#
# Extracted from stzlocaletest.ring, block #20.

load "../../stzBase.ring"


pr()

// Check the name of China in country names!
? StzLocaleQ([ :Language = :Chinese ]).CountryName() #-->NULL ! Todo: Why?
? StzLocaleQ([ :Country = :China ]).CountryName() #-->NULL ! Todo: Why?

? StzCountryQ(:China).Language() #--> Chinese

pf()
# Executed in 0.01 second(s) in Ring 1.23
