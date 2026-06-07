# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #716.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

# TQ is an abbreviation of StzTextQ()

? TQ("عربي").Script()
#--> arabic

? TQ("ring").Script()
#--> latin

pf()
# Executed in 0.06 second(s).
