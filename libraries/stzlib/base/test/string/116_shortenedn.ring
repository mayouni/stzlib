# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #116.
#ERR Error (R14) : Calling Method without definition: shortenedxt

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").ShortenedN(2)
#--> 12...21
		
? Q("1234567890987654321").ShortenedXT(0, 2, " {...} ")
#--> 12 {...} 21

pf()
# Executed in 0.03 second(s)
