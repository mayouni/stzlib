# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #118.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Shorten/Shortened family"): the
# mutating Shorten() leaves the string UNCHANGED (should become "123...321") and
# ShortenN(5) yields "12..." (should be "12345...54321"). Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("1234567890987654321")
o1.Shorten()
? o1.Content() #--> expected "123...321"

o1 = new stzString("1234567890987654321")
o1.ShortenN(5)
? o1.Content() #--> expected "12345...54321"

pf()
