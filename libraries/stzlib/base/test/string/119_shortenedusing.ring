# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #119.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Shorten/Shortened family"):
# ShortenedUsing(" {...} ") keeps 4 chars per side ("1234 {...} 4321") instead of
# the default 3 ("123 {...} 321"), and ShortenedNUsing(5, " {...} ") drops both
# sides entirely (" {...} " instead of "12345 {...} 54321"). Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").ShortenedUsing(" {...} ")     #--> expected "123 {...} 321"
? Q("1234567890987654321").ShortenedNUsing(5, " {...} ") #--> expected "12345 {...} 54321"

pf()
