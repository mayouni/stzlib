# Narrative
# --------
# #TODO check it
#
# Extracted from stzlisttest.ring, block #103.

load "../../../stzBase.ring"


pr()

? IsChar("🌞")
#!--> FALSE
#~> Should return TRUE!

? StzCharQ("🌞").Content()
#!--> Can not create char object!
#~> Should be able to create it...

pf()
