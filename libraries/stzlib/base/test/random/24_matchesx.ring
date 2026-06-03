# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #24.
#ERR Error (R14) : Calling Method without definition: islistofchars

load "../../stzBase.ring"

pr()

? NothingInQQX([ "aee@net", "@com.com", "--?mail@org" ]).MatchesX(rxp(:eMail))
#--> TRUE

? NothingInQQX([ "aee@net", "@com.com", "--?mail@org", "info@mail.com" ]).MatchesX(rxp(:eMail))
#--> FALSE

? EveryThingInQQX([ "hello@mail.com", "info@mail.org" ]).MatchesX(rxp(:eMail))
#--> TRUE

? EveryThingInQQX([ "hello@mail.com", "info@mail.org", "~;@com" ]).MatchesX(rxp(:eMail))
#--> FALSE

pf()
# Executed in 0.06 second(s) in Ring 1.22
