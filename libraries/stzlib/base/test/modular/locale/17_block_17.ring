# Narrative
# --------
# #TODO
#
# Extracted from stzlocaletest.ring, block #17.

load "../../../stzBase.ring"


pr()

? StzLocaleQ("sm-AS").Abbreviation()	#--> "C" but should be "sm_AS"
? StzLocaleQ([ :Country = :american_samoa ]).Abbreviation()	#--> "C" but should "sm_AS"

pf()
# Executed in 0.01 second(s) in Ring 1.23
