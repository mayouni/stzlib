# Narrative
# --------
# #TODO ERROR: returns NULL!
#
# Extracted from stzlocaletest.ring, block #9.

load "../../stzBase.ring"


pr()

StzLocaleQ([ :Country = :palau ]) {
	? CountryName()	# !--> palau
}

pf()
