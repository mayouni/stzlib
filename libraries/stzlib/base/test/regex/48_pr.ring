# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #48.

load "../../stzBase.ring"


? pat(:creditCard) + NL
#--> ^\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}$

rx(pat(:cardNumber)) { ? Match("4111-1111-1111-1111") }
#--> TRUE

pf()
