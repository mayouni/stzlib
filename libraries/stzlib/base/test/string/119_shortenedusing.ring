# Narrative
# --------
# Shortening the MIDDLE: keep N chars from each side joined by an ellipsis
# (ShortenedN/Shortened/...Using return; Shorten/ShortenN mutate).
#
# Extracted from stzStringTest.ring, block #119.
#

load "../../stzBase.ring"

pr()

? Q("1234567890987654321").ShortenedUsing(" {...} ")     #--> 123 {...} 321
? Q("1234567890987654321").ShortenedNUsing(5, " {...} ") #--> 12345 {...} 54321

pf()
