# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #479.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

? QQ("â‘ ").IsCircledNumber()
#--> TRUE

# or QQ("â‘ ").IsCircledDigit() if you wana embrace the semantics of Unicode

pf()
# Executed in 0.03 second(s).
