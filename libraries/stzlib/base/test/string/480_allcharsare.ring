# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #480.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

? Q("â‘ ②③").AllCharsAre(:CircledNumbers)
#--> TRUE

? Q("â‘ ②③").AllCharsAre([:CircledNumber, :Chars]) #TODO check after reincluding check()
#--> TRUE

pf()
