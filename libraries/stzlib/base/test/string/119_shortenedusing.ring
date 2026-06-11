# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #119.
#ERR panic: integer part of floating point value out of bounds

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").ShortenedUsing(" {...} ")
#--> 123 {...} 321

? Q("1234567890987654321").ShortenedNUsing(5, " {...} ")
#--> 12345 {...} 54321

pf()
# Executed in 0.03 second(s)
