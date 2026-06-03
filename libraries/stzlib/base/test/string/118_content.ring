# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #118.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("1234567890987654321")
o1.Shorten()
? o1.Content()
#--> 123...321

o1 = new stzString("1234567890987654321")
o1.ShortenN(5)
? o1.Content()
#--> 12345...54321

pf()
# Executed in 0.04 second(s)
