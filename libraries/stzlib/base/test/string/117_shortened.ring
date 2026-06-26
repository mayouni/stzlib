# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #117.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Shorten/Shortened family"):
# Shortened() returns the string UNCHANGED (should be "123...321"); ShortenedN(5)
# returns "12..." (should be "12345...54321"); ShortenedXT(0, 3, " ... ") drops
# the head (" ... 321" instead of "123 ... 321"). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").Shortened()              #--> expected "123...321"
? Q("1234567890987654321").ShortenedN(5)            #--> expected "12345...54321"
? Q("1234567890987654321").ShortenedXT(0, 3, " ... ") #--> expected "123 ... 321"

pf()
