# Narrative
# --------
# # Testing FindLast() on a very large string (~2M chars)
#
# Extracted from stzStringTest.ring, block #239.
#
# DEFERRED (data unavailable): UnicodeData() returns "" in this checkout, so the
# absent-Arabic-word case can't be exercised on the real 2M text. FindLast /
# Contains on a small string are verified in blocks 238/235. Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString( UnicodeDataAsString() ) # intended: 1_897_793 chars
? o1.Contains("جميل")   #--> FALSE (absent)
? o1.FindLast("جميل")   #--> FALSE / 0 (absent)

pf()
