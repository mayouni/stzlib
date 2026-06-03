# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #480.

load "../../stzBase.ring"

pr()

? Q("â‘ ②③").AllCharsAre(:CircledNumbers)
#--> TRUE

? Q("â‘ ②③").AllCharsAre([:CircledNumber, :Chars]) #TODO check after reincluding check()
#--> TRUE

pf()
