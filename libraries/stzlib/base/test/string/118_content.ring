# Narrative
# --------
# Shortening the MIDDLE: keep N chars from each side joined by an ellipsis
# (ShortenedN/Shortened/...Using return; Shorten/ShortenN mutate).
#
# Extracted from stzStringTest.ring, block #118.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("1234567890987654321")
o1.Shorten()
? o1.Content() #--> 123...321

o1 = new stzString("1234567890987654321")
o1.ShortenN(5)
? o1.Content() #--> 12345...54321

pf()
