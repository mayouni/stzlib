# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #119.

load "../../stzBase.ring"


? Q("1234567890987654321").ShortenedUsing(" {...} ")
#--> 123 {...} 321

? Q("1234567890987654321").ShortenedNUsing(5, " {...} ")
#--> 12345 {...} 54321

pf()
# Executed in 0.03 second(s)
