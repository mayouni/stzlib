# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #117.

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").Shortened()
#--> 123...321

? Q("1234567890987654321").ShortenedN(5)
#--> 12345...54321

? Q("1234567890987654321").ShortenedXT(0, 3, " ... ")
#--> 123 ... 321

pf()
# Executed in 0.04 second(s)
