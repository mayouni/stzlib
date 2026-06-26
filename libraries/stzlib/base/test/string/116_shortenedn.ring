# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #116.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Shorten/Shortened family"):
# ShortenedN(2) returns the string UNCHANGED (should be "12...21"), and
# ShortenedXT(0, 2, " {...} ") drops the leading chars ("  {...} 21" instead of
# "12 {...} 21"). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").ShortenedN(2)            #--> expected "12...21"
? Q("1234567890987654321").ShortenedXT(0, 2, " {...} ") #--> expected "12 {...} 21"

pf()
